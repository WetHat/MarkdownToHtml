[System.IO.DirectoryInfo]$SCRIPT:moduleDir = Split-Path -Parent $MyInvocation.MyCommand.Path
[string]$SCRIPT:svgbob = Join-Path $SCRIPT:moduleDir 'svgbob.exe'

# Send utf8 without BOM throught the pipe to external programs
$OutputEncoding =  [Text.UTF8Encoding]::new($false)

<#
.SYNOPSIS
Wrap up markdown preprocessing.

.DESCRIPTION
Consolidates the preprocessed Markdown data for the downstream conversion
pipeline.

.PARAMETER MarkdownLine
One line of Markdown text.

.PARAMETER RelativePath
The path to a Markdown (`*.md`) or HTML (`*.html`) file relative to its
corresponding root configured in `Build.json`. For Markdown files the
root is configured by parameter `"markdown_dir"` for html files it is
`"site_dir"`. This parameter will be used to compute relative resource
and navigation bar links for the HTML page currently
being assembled.

The given path should use forward slash '/' path separators.

.INPUTS
Lines of Markdown text.

.OUTPUTS
A Markdown descriptor object `[hashtable]` with these properties:

| Key            | Value Type | Description                                 |
| :------------- | :--------- | :------------------------------------------ |
| `Markdown`     | [`string`] | The markdown text.                          |
| `RelativePath` | [`string`] | Relative path of the Markdown or html file. |

.EXAMPLE
PS> Get-Content $md -Encoding UTF8 | Convert-X ... | Complete-MarkdownPreprocessor -RelativePath $md.RelativePath

Preprocess Markdown data from a file `$md` using a custom preprocessing function
`Convert-X`. The preprocessed Markdown data is finally re-packaged to further
pipeline processing by `Complete-MarkdownPreprocessor`. `$md` is an _annotated_
`[System.IO.FileInfo]` object whch is either output by `Find-MarkdownFiles`
or assembled by custom code.

.LINK
https://wethat.github.io/MarkdownToHtml/2.5.0/Complete-MarkdownPreprocessor.html
.LINK
`Convert-SvgbobToSvg`
.LINK
`Find-MarkdownFiles`
#>
function Complete-MarkdownPreprocessor {
    [OutputType([hashtable])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [AllowEmptyString()]
        [string]$MarkdownLine,
        [parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [string]$RelativePath
    )
    Begin {
       $markdown = @() # markdown text accumulator
    }
    Process {
        $markdown += $markdownLine # accumulate this line
    }
    End {
         # Create a Markdown descriptor object
         @{
              Markdown     = $markdown -join [System.Environment]::NewLine
              RelativePath = $RelativePath
          }
    }
}

# Regular expression to detect the start of fenced svgbob blocks.
[Regex]$SCRIPT:bobstartRE = New-Object Regex '^([\s>]*)(~~~|```)\s*bob'

<#
.SYNOPSIS
Convert fenced svgbob code blocks to svg images.

.DESCRIPTION
Scans the input data (lines of Markdown text) for svgbob fenced code blocks
and converts them to a Markdown style image link to a svg file containing
the rendered diagram.

Svgbob code blocks define human readable diagrams and are labeled as `bob`.
For example:

~~~ Markdown
˜˜˜ bob
      +------+   .-.   +---+
 o----| elem |--( ; )--| n |----o
      +------+   '-'   +---+
˜˜˜
~~~

The generated svg file is put right next to the HTML file
currently being assembled and named after that HTML file with an unique
index appended.

.PARAMETER SiteDirectory
Location of the static HTML site. The Svg file will be generated relative to this
path.

.PARAMETER RelativePath
Svg file path relative to `SiteDirectory`.

.PARAMETER Options
Svg conversion options. An object or hashtable with follwing properties or keys:

| Property       | Description                                  |
| :------------: | :------------------------------------------- |
| `background`   | Diagram background color (default: white)    |
| `fill_color`   | Fill color for solid shapes (default: black) |
| `font_family`  | Text font (default: monospace)               |
| `font_size`    | Text font size (default 14)                  |
| `scale`        | Diagram scale (default: 1)                   |
| `stroke_width` | Stroke width for all lines (default: 2)      |

When using conversion projects instantiated by `New-StaticHTMLSiteProject` these
parameters are configured in `Build.json` parameter section `svgbob`.

.INPUTS
Lines of Markdown text.

.OUTPUTS
Lines of Markdown text where all fenced code blocks labelled `bob` are
replaced by Markdown style image links to svg files.

.EXAMPLE
PS> Get-Content $md -Encoding UTF8 | Convert-SvgbobToSvg -SiteDirectory $site -RelativePath $relativePath

Read Markdown content from the file `$md` and replace all fenced code blocks
marled as `bob` with Markdown style image links to the svg version of the
diagram. The conversion is performed using default svg rendering options.

Where

`$site`
:   Is the **absolute path** to the HTML site's root directory

`$relativePath`
:   is the **relative path** of the HTML file currently being assembled below
    `$site`.

`$md`
:   represents a file named `test.md` which contains a fenced svgbob diagram.
    ~~~ Markdown
    Some text ...

    ˜˜˜ bob
          +------+   .-.   +---+
     o----| elem |--( ; )--| n |----o
          +------+   '-'   +---+
    ˜˜˜

    Some more text ...
    ~~~

this is converted to:

~~~ Markdown
Some text ...

![Diagram 1.](test1.svg)

Some more text ...
~~~

.NOTES
The svg conversion is performed by the external utility
`svgbob.exe` which is packaged with this module.

.LINK
https://wethat.github.io/MarkdownToHtml/2.5.0/Convert-SvgbobToSvg.html
.LINK
[Svgbob](https://ivanceras.github.io/svgbob-editor/)
#>
function Convert-SvgbobToSvg {
    [OutputType([string])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [AllowEmptyString()]
        [string]$MarkdownLine,
        [parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [string]$SiteDirectory,
        [parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [string]$RelativePath,
        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [object]$Options
    )
    Begin {
        $n = 0
        $bob = $null
        $prefix = [string]::Empty
        $skip = 0
        # svgbob default options
        [string]$background  = 'white'
        [string]$fillColor   = 'black'
        $fontSize            = 14;
        [string]$fontFamily  = 'Monospace'
        $scale               = 1
        $strokeWidth         = 2

        # override with specified options
        if ($options) {
            $value=$options.background
            if ($value) {
                $background = $value
            }
            $value=$options.fill_color
            if ($value) {
                $fillColor = $value
            }
            $value=$options.font_size
            if ($value) {
                $fontSize = $value
            }
            $value=$options.font_family
            if ($value) {
                $fontFamily = $value
            }
            $value=$options.scale
            if ($value) {
                $scale = $value
            }
            $value=$options.stroke_width
            if ($value) {
                $strokeWidth = $value
            }
        }
    }

    Process {
        if ($bob -is [Array]) {
            if ($MarkdownLine -match '[>\s]*(~~~|```)') { # end of drawing
                [System.IO.Fileinfo]$fullpath = Join-Path $SiteDirectory $RelativePath

                $svgname = $fullpath.BaseName + "$n.svg"
                # write link to the svg image in Markdown notation
                Write-Output "${prefix}![Diagram ${n}.]($svgname)"

                # we need to create that site directory upfront so that the
                # svg image can be put there
                if (!$fullpath.Directory.Exists) {
                    $fullpath.Directory.Create()
                }

                $svgfullpath = Join-Path $fullpath.DirectoryName $svgname
                # do the conversion
                $bob | & $SCRIPT:svgbob -o "$svgfullpath" `
                                        --background   $background `
                                        --fill-color   $fillColor `
                                        --font-family  $fontFamily `
                                        --font-size    $fontSize `
                                        --scale        $scale `
                                        --stroke-width $strokeWidth
                $bob = $null # starting over
            } else {
                $bob += $MarkdownLine.Substring($skip) # accumulate svgbob data
            }
        } else {
            $m = $SCRIPT:bobstartRE.Match($MarkdownLine)
            if ($m.Success) { # start capturing svgbob data
                $prefix = $m.Groups[1]
                $skip = $prefix.Length
                $bob = @()
                $n++
            } else {
                Write-Output $MarkdownLine # pass through
            }
        }
    }
}
# SIG # Begin signature block
# MIIFYAYJKoZIhvcNAQcCoIIFUTCCBU0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUn394OtWnAYrp/AxUcNde5b4h
# YYegggMAMIIC/DCCAeSgAwIBAgIQaejvMGXYIKhALoN4OCBcKjANBgkqhkiG9w0B
# AQUFADAVMRMwEQYDVQQDDApXZXRIYXQgTGFiMCAXDTIwMDUwMzA4MTMwNFoYDzIw
# NTAwNTAzMDgyMzA0WjAVMRMwEQYDVQQDDApXZXRIYXQgTGFiMIIBIjANBgkqhkiG
# 9w0BAQEFAAOCAQ8AMIIBCgKCAQEArNo5GzE4BkP8HagZLFT7h189+EPxP0pmiSC5
# yi34ZctnpyFUz+Cv547+MvzAr0uRuLkxn6ArBkVLeHVAB58jenSeLwDFls5gS0I+
# pRJWO9eyyT64EcUSCMlfMLW2q1hzjfFckFR6iFnGp3TkE0s1kQANUNjAR9axC6ju
# 4dpilIupCHW+/0s9aGz7LYuRQGcy3uIL9TURKdBtOsMOBeclUsEoFSEp/0D30E8r
# PNk/VLu57G5H9n3HuX/DSBR2CL8LzOOv981hiS+SCds/pHqjCX9Qj+j47Kv7xZ1i
# ha2fg4AEHDGbL/WJGnTpUKath+EmgmFRlsP7PgnZr4anvGdcdQIDAQABo0YwRDAO
# BgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFKtE
# 8xMwn4kGbe8AzXY0ineK5ToHMA0GCSqGSIb3DQEBBQUAA4IBAQAgaUJkHD9192H7
# OUhf9W3gR0ZkApD5fnPqsIgS91JFQ2fCnonudJinwbODs01yA55uUw4GJUnAKQOx
# 6auVAC5KVzE2dMDbOrBOseoKj12EbzbF509FkVoT5O77NDpFrGErR1zmQ8fd1DXw
# FAFC1x1vpxW7/F6g+xewpqlFKzjkPeEvLgyoUmKMCOnT0JdXS0BfyAyyIfHwvILo
# 2eJWVG2UMioKOJ6vsttTu8mQgVZlfcoF6r81ee3hTEK24aHNR+frHmyrL9UplZxD
# AuoUGVzYdDyOejlLPm+d+ew1d6dTf9QfurRxoKgI6OMOVI3iIIXd6HTiIW4ACwI9
# iUjry3dVMYIByjCCAcYCAQEwKTAVMRMwEQYDVQQDDApXZXRIYXQgTGFiAhBp6O8w
# ZdggqEAug3g4IFwqMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgACh
# AoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAM
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTHCjvHfDjRtyX+41vbj1TxZKd0
# CzANBgkqhkiG9w0BAQEFAASCAQBu2zApGVJEiTjXdB+ZWiyI8XqNwqqjSUEez8mI
# XOlp/ciqLspcTVqnR4u5BRx1dmzW1N5YaE//VQyaWCK/1qJvUJ8IYPwRw3YSk492
# 4kCzzwMNRJWkHLEbfHBMVifZl7q+vuQfdDffT4ZysH75lYZRErKi7Cyg8i/V/xC6
# PhISr+L0PP+ZU9r4+c8nXUcF57wRvds2khFDARiWki0zFWPhv7SnYnB4UsJuC+PZ
# w3XmXQlxORssPue/vfkMb5OLcV1Rhkb4bXvcWi3YwUtKoNaqK4oyUjBXIC95+U2Z
# zJ8Gq3vFcoG64q6ObJCbi4LVFv2S+xe7QVWR2JkvFIY1YHp9
# SIG # End signature block

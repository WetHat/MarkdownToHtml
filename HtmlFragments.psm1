[System.IO.DirectoryInfo]$SCRIPT:moduleDir = Split-Path -Parent $MyInvocation.MyCommand.Path
[string]$SCRIPT:svgbob = Join-Path $SCRIPT:moduleDir 'svgbob.exe'

# Send utf8 without BOM throught the pipe to external programs
$OutputEncoding =  [Text.UTF8Encoding]::new($false)

# Match hyperlinks to Markdown files
$SCRIPT:mdhrefRE = New-Object Regex '(?<=^<a[^>]*href=")([^"]+)\.(md|markdown)(?=["#])'

<#
.SYNOPSIS
Convert fenced svgbob code blocks to svg images.

.DESCRIPTION
Scans the input data (lines of Markdown text) for svgbob fenced code blocks
and converts them to a Markdown style image link to a svg file containing
the rendered diagram.

Svgbob code blocks define human readable diagrams and are labeled as `bob`.
For example:

``` Markdown
~~~ bob
      +------+   .-.   +---+
 o----| elem |--( ; )--| n |----o
      +------+   '-'   +---+
~~~
```

The generated svg file is put right next to the HTML file
currently being assembled and named after that HTML file with an unique
index appended.

.PARAMETER SiteDirectory
Location of the static HTML site. The Svg file will be generated relative to this
path.

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
parameters are usually configured in `Build.json` in section `svgbob` and this
parameter should be omitted for these configurations to take effect.

**Note**: If this parameter is specified, it superseeds the
configuration from `Build.json`.

.INPUTS
HTML fragment objects emitted by `Convert-MarkdownToHTMLFragment` with
the `-Split` switch or equivalent objects.

.OUTPUTS
Lines of Markdown text where all fenced code blocks labelled `bob` are
replaced by Markdown style image links to svg files.

.EXAMPLE
PS> Convert-MarkdownToHTMLFragment -InputObject $md -Split | Convert-SvgbobToSvg -SiteDirectory $site -RelativePath $relativePath

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
:   is a Markdown file `test.md` which contains a fenced svgbob diagram:
    ``` Markdown
    Some text ...

    ~~~ bob
          +------+   .-.   +---+
     o----| elem |--( ; )--| n |----o
          +------+   '-'   +---+
    ~~~

    Some more text ...
    ```

this fragment is converted to:

* A file `test1.svg` which is placed right next to the html file `test.html`
  which is going to be created by `Publish-StaticHtmlSite` in a subsequent
  stage of the conversion pipeline. The numerical postfix is the index of the
  Svgbob diagram in the fragment. The svg image renders as:

  ~~~ bob
       +------+   .-.   +---+
  o----| elem |--( ; )--| n |----o
       +------+   '-'   +---+
  ~~~

* An updated html fragment where the fenced Svgbob diagram is replaced with
  a reference to the svg image.

  ~~~ html
  Some text ...

  <img src='test1.svg' alt='Diagram 1.' />

  Some more text ...
  ~~~

.NOTES
The svg conversion is performed by the external utility
`svgbob.exe` which is packaged with this module.
`svgbob.exe` is a [Rust](https://www.rust-lang.org/)
[crate](https://doc.rust-lang.org/rust-by-example/crates.html) which can be
installed from [lib.rs](https://lib.rs/crates/svgbob_cli).

.LINK
https://wethat.github.io/MarkdownToHtml/2.6/Convert-SvgbobToSvg.html
.LINK
[Svgbob](https://ivanceras.github.io/content/Svgbob.html)
#>
function Convert-SvgbobToSvg {
    [OutputType([hashtable])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateScript({$_.HtmlFragment})]
        [Alias('HtmlFragment')]
        [hashtable]$InputObject,

        [parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [string]$SiteDirectory,

        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [object]$Options
    )
    Begin {
        # svgbob default options
        [string]$background  = 'white'
        [string]$fillColor   = 'black'
        $fontSize            = 14;
        [string]$fontFamily  = 'Monospace'
        $scale               = 1
        $strokeWidth         = 2

        if (!$Options -and ($cfg = $InputObject.EffectiveConfiguration))  {
            # Check the effective configuration for options
            $Options = $cfg.svgbob

        }
        # override with specified options
        if ($Options) {
            $value=$Options.background
            if ($value) {
                $background = $value
            }
            $value=$Options.fill_color
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
        if (!$Options -and ($cfg = $InputObject.EffectiveConfiguration))  {
            # Update options from effective config
            $opts = $cfg.svgbob
            # override with specified options
            $value=$opts.background
            if ($value) {
                $background = $value
            }
            $value=$opts.fill_color
            if ($value) {
                $fillColor = $value
            }
            $value=$opts.font_size
            if ($value) {
                $fontSize = $value
            }
            $value=$opts.font_family
            if ($value) {
                $fontFamily = $value
            }
            $value=$opts.scale
            if ($value) {
                $scale = $value
            }
            $value=$opts.stroke_width
            if ($value) {
                $strokeWidth = $value
            }
        }

        $n = 0
        $bob = $null

        [System.IO.Fileinfo]$fullpath = Join-Path $SiteDirectory $_.RelativePath

        $fragment = $InputObject.HtmlFragment

        for($i=0; $i -lt $fragment.Count; $i++) {
            $itm = $fragment[$i]
            if ($bob -is [Array]) {
                if ($itm -eq '</code>') {
                    # svgbob drawing complete
                    $n++
                    $svgname = $fullpath.BaseName + "$n.svg"
                    # replace the fenced code block by a hyperlink
                    $fragment[$i] = "<img src='$svgname' alt='Diagram ${n}.' />"

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
                }
                else {
                    $bob += [System.Net.WebUtility]::HtmlDecode($itm.TrimEnd())
                    $fragment[$i] = [string]::Empty
                }
            }
            elseif ($itm -eq '<code class="language-bob">') {
                $fragment[$i] = [string]::Empty
                $bob=@() # Enable capturing of svgbob drawing
            }
        }

        $InputObject
    }
}

<#
.SYNOPSIS
Convert Markdown text to HTML fragments.

.DESCRIPTION
Converts Markdown text to HTML fragments using configured
[Markdown extensions](about_MarkdownToHTML.md#supported-markdown-extensions).

.PARAMETER InputObject
The input object can have one of the following types:
* An annotated `[System.IO.FileInfo]` object as emitted by `Find-MarkdownFiles`.
* A plain markdown string [`string`].
* A markdown descriptor object which is a [`hashtable`] with following contents:

  | Key                      | Value Type         | Description                                                   |
  | :----------------------- | :----------------- | :------------------------------------------------------------ |
  | `Markdown`               | [`string`]         | The markdown text.                                            |
  | `RelativePath`           | [`string`]         | Relative path of the Markdown file below the input directory. |
  | `EffectiveConfiguration` | [`PSCustomObject`] | Optional: Build configuration in effect for this fragment     |

.PARAMETER IncludeExtension
Comma separated list of Markdown parsing extension names.
See [Markdown extensions](about_MarkdownToHTML.md#supported-markdown-extensions)
for an annotated list of supported extensions.

.PARAMETER ExcludeExtension
Comma separated list of Markdown parsing extensions to exclude.
Mostly used when the the 'advanced' parsing option is included and
certain individual options need to be removed.

.PARAMETER Split
Split the Html fragment into an Array where each tag is in a separate slot.
This somewhat simplifies Html fragment post-processing.

For example the fragment

~~~ html
<pre><code class="language-PowerShell">PS&gt; Install-Module -Name MarkdownToHTML</pre></code>
~~~

is split up into the array

| Index | Value                                        |
| :---: | :------------------------------------------- |
| 0     | `<pre>`                                      |
| 1     | `<code class="language-PowerShell">`         |
| 2     | `PS&gt; Install-Module -Name MarkdownToHTML` |
| 3     | `</pre>`                                     |
| 4     | `</code>`                                    |

.INPUTS
Markdown text `[string]`, Markdown file `[System.IO.FileInfo]`,
or a markdown descriptor `[hashtable]`.

.OUTPUTS
HTML fragment object with following properties:

| Property                 | Description                                                         |
| :----------------------: | :------------------------------------------------------------------ |
| `Title`                  | Optional page title. The first heading in the Markdown content.     |
| `HtmlFragment`           | The HTML fragment string or array generated from the Markdown text. |
| `RelativePath`           | Passed through from the input object, provided it exists.           |
| `EffectiveConfiguration` | Passed through from the input object, provided it exists.           |

.NOTES
The conversion to HTML fragments also includes:

* Changing links to Markdown files to the corresponding Html files.

  ~~~ Markdown
  [Hello World](Hello.md)
  ~~~

  becomes:

  ~~~ html
  <a href="Hello.html">
  ~~~

* HTML encoding code blocks:

  ~~~ Markdown

  ```xml
  <root>
      <thing/>
  </root>

  ```
  ~~~

  becomes

  ~~~ HTML
  <pre><code class="language-xml">&lt;root&gt;
      &lt;thing/&gt;
  &lt;/root&gt;

  </code></pre>
  ~~~

  which renders as

  ```xml
  <root>
      <thing/>
  </root>

  ```

.EXAMPLE
Convert-MarkdownToHTMLFragment -Markdown '# Hello World'

Returns the HTML fragment object:

    Name               Value
    ----               -----
    HtmlFragment       <h1 id="hello-world">Hello World</h1>...
    Title              Hello World

.EXAMPLE
Convert-MarkdownToHTMLFragment -Markdown '# Hello World' -Split

Returns the HTML fragment object:

    Name               Value
    ----               -----
    HtmlFragment       {<h1 id="hello-world">,Hello World,</h1>,...}
    Title              Hello World

.EXAMPLE
Get-Item -LiteralPath "Convert-MarkdownToHTML.md" | Convert-MarkdownToHTMLFragment

Reads the content of Markdown file `Example.md` and returns a Html fragment object.

    Name               Value
    ----               -----
    Title              Convert-MarkdownToHTML
    HtmlFragment       <h1 id="convert-Markdowntohtml">Convert-MarkdownToHTML</h1>...
    RelativePath       Convert-MarkdownToHTML.md

.LINK
https://wethat.github.io/MarkdownToHtml/2.6/Convert-MarkdownToHTMLFragment.html
.LINK
`Convert-MarkdownToHTML`
.LINK
`Convert-SvgbobToSvg`
.LINK
`Find-MarkdownFiles`
.LINK
`Publish-StaticHtmlSite`
.LINK
`New-HTMLTemplate`
.LINK
[Markdown extensions](about_MarkdownToHTML.md#supported-markdown-extensions)
#>
function Convert-MarkdownToHTMLFragment
{
    [OutputType([hashtable])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateScript({$_ -is [string] -or $_ -is [System.IO.FileInfo] -or $_ -is [hashtable]})]
        [Alias('Markdown')]
        $InputObject,

        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [string[]]$IncludeExtension = @('advanced'),

        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [string[]]$ExcludeExtension = @(),

        [switch]$Split
    )
    BEGIN {
        ## Determine which parser extensions to use
        if ($null -eq $IncludeExtension -or $IncludeExtension.Count -eq 0) {
            $IncludeExtension = @('common') # use _common_ extensions by default
        } elseif ('advanced' -in $IncludeExtension) {
            if ($ExcludeExtension.Count -gt 0) {
               $IncludeExtension = $IncludeExtension | Where-Object { $_ -ne 'advanced'}
               ## add the extensions explicitely so that we can remove individual ones
               $IncludeExtension += $SCRIPT:advancedMarkdownExtensions
            } elseif ($IncludeExtension.Count -gt 1) {
                $IncludeExtension = $IncludeExtension | Where-Object { $_ -ne 'advanced'}
                ## make sure the advanced option comes last
                $IncludeExtension += 'advanced'
            }
        }

        ## make sure the 'attributes' extension is last
        if ('attributes' -in $IncludeExtension) {
            $IncludeExtension = $IncludeExtension | Where-Object { $_ -ne 'attributes' }
            $IncludeExtension += 'attributes'
        }

        # Remove the excluded extensions
        $IncludeExtension = $IncludeExtension | Where-Object { $_ -notin $ExcludeExtension}

        # configure the converter pipeline
        [Markdig.MarkdownPipelineBuilder]$pipelineBuilder = (New-Object Markdig.MarkdownPipelineBuilder)
        Write-Verbose "Using parser extensions $IncludeExtension"
        $pipelineBuilder = [Markdig.MarkDownExtensions]::Configure($pipelineBuilder,[string]::Join('+',$IncludeExtension))

        $pipeline = $pipelineBuilder.Build()
    }

    PROCESS {
        [string]$md = if ($InputObject -is [System.IO.FileInfo]) {
                          Get-Content -LiteralPath $InputObject.FullName -Encoding UTF8 | Out-String
                      } elseif ($InputObject -is [hashtable]) {
                          $InputObject.Markdown
                      } else {
                          $InputObject
                      }
        # Create HTML fragment and split it at tag level.
        #                                                             |----------| <- Html tag
        $fragment = [Markdig.Markdown]::ToHtml($md, $pipeline) -split '(<[^<>]+>)' | Where-Object { $_ }

        # update local markdown links to make them point to HTML
        for($i=0; $i -lt $fragment.Count; $i++) {
            $itm = $fragment[$i]
            if ($itm.StartsWith('<a') -and $itm -notlike '*://*') {
                $fragment[$i] = $SCRIPT:mdhrefRE.Replace($itm,'$1.html')
            }
        }

        if (!$Split) {
            # make it one string
            $fragment = $fragment -join ''
        }

        # assemble the descriptor object
        $htmlDescriptor = @{'HtmlFragment' = $fragment }
        $match = [regex]::Match($md,'^[#\s]*([^\r\n\{]+)')
        if ($match.Success) {
            $htmlDescriptor.Title = $match.Groups[1].Value # first heading
        } elseif ($InputObject.BaseName) {
            $htmlDescriptor.Title = $InputObject.BaseName
        }

        if ($InputObject.RelativePath) {
            $htmlDescriptor.RelativePath = $InputObject.RelativePath
        } elseif ($InputObject.Name) {
            $htmlDescriptor.RelativePath = $InputObject.Name
        }

        if ($InputObject.EffectiveConfiguration) {
            $htmlDescriptor.EffectiveConfiguration = $InputObject.EffectiveConfiguration
        }

        # return the annotated HTML fragment
        $htmlDescriptor
    }
}

# SIG # Begin signature block
# MIIFYAYJKoZIhvcNAQcCoIIFUTCCBU0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUJjA4qWi70vTN/6vl1EqVWtlA
# w6CgggMAMIIC/DCCAeSgAwIBAgIQaejvMGXYIKhALoN4OCBcKjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQN3aESlajxASsdHwnu87LqRiQd
# YjANBgkqhkiG9w0BAQEFAASCAQAZoK4ebCldqXzhDCTgpcL2Bo9nCcHRcXgmoj9a
# d/OAdnAs04VJzQ3g9b5SSJvamEBfzIAnqZPN/H3EYwbNvDgBNEDCwXo4mm7wUyJ5
# TjsxYuzvdqugRJuyXeLbppTrQ7urD8G633Bmcddp/8nOKv+cZe2/xtlLStTso2JB
# 3NuKSgESjdhkfgYzBIV05OLv9AJX1DCT3jdrQkbH9HcVSvQ3cdu07jAEW5nCGi4T
# jvme+wggp7UGB4biklhA7FM7zr+WpGdfKeJHyxoCLdNN88kl4Wd6rwB1k0zvEKfC
# bSK62z+XHhmsZVa3H+N7zqzTuItYvtjNRhmI14js+XWUuekF
# SIG # End signature block

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
parameters are configured in `Build.json` parameter section `svgbob`.

.INPUTS
HTML fragment objects emitted by `Convert-MarkdownToHTMLFragment` or
equivalent objects.

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
    ``` Markdown
    Some text ...

    ~~~ bob
          +------+   .-.   +---+
     o----| elem |--( ; )--| n |----o
          +------+   '-'   +---+
    ~~~

    Some more text ...
    ```

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

  | Key            | Value Type | Description                                                   |
  | :------------- | :--------- | :------------------------------------------------------------ |
  | `Markdown`     | [`string`] | The markdown text.                                            |
  | `RelativePath` | [`string`] | Relative path of the Markdown file below the input directory. |

.PARAMETER IncludeExtension
Comma separated list of Markdown parsing extension names.
See [Markdown extensions](about_MarkdownToHTML.md#supported-markdown-extensions)
for an annotated list of supported extensions.

.PARAMETER ExcludeExtension
Comma separated list of Markdown parsing extensions to exclude.
Mostly used when the the 'advanced' parsing option is included and
certain individual options need to be removed.

.INPUTS
Markdown text `[string]`, Markdown file `[System.IO.FileInfo]`,
or a markdown descriptor `[hashtable]`.

.OUTPUTS
HTML fragment object with following properties:

| Property       | Description                                                     |
| :------------: | :-------------------------------------------------------------- |
| `Title`        | Optional page title. The first heading in the Markdown content. |
| `HtmlFragment` | The HTML fragment string generated from the Markdown text.      |
| `RelativePath` | Passed through from the input object, provided it exists.       |

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
Get-Item -LiteralPath "Convert-MarkdownToHTML.md" | Convert-MarkdownToHTMLFragment

Reads the content of Markdown file `Example.md` and returns a Html fragment object.

    Name               Value
    ----               -----
    Title              Convert-MarkdownToHTML
    HtmlFragment       <h1 id="convert-Markdowntohtml">Convert-MarkdownToHTML</h1>...
    RelativePath       Convert-MarkdownToHTML.md

.LINK
https://wethat.github.io/MarkdownToHtml/2.5.0/Convert-MarkdownToHTMLFragment.html
.LINK
`Convert-MarkdownToHTML`
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
            $htmlDescriptor.Title = $match.Groups[1].Value
        } elseif ($InputObject.BaseName) {
            $htmlDescriptor.Title = $InputObject.BaseName
        }

        if ($InputObject.RelativePath) {
            $htmlDescriptor.RelativePath = $InputObject.RelativePath
        } elseif ($InputObject.Name) {
            $htmlDescriptor.RelativePath = $InputObject.Name
        }

        # return the annotated HTML fragment
        $htmlDescriptor
    }
}

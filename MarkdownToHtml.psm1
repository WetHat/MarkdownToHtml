[System.IO.DirectoryInfo]$SCRIPT:moduleDir = Split-Path -Parent $MyInvocation.MyCommand.Path

[string[]]$SCRIPT:advancedMarkdownExtensions = @(
    'abbreviations' ## .UseAbbreviations()
    'autoidentifiers' ## .UseAutoIdentifiers()
    'citations' ## .UseCitations()
    'customcontainers' ## .UseCustomContainers()
    'definitionlists' ## .UseDefinitionLists()
    'emphasisextras' ## .UseEmphasisExtras()
    'figures' ## .UseFigures()
    'footers' ## .UseFooters()
    'footnotes' ## .UseFootnotes()
    'gridtables' ## .UseGridTables()
    'mathematics' ## .UseMathematics()
    'medialinks' ## .UseMediaLinks()
    'pipetables' ## .UsePipeTables()
    'listextras' ## .UseListExtras()
    'tasklists' ## .UseTaskLists()
    'diagrams' ## .UseDiagrams()
    'autolinks' ## .UseAutoLinks()
    'attributes' ## .UseGenericAttributes();
)

<#
.SYNOPSIS
Create a static HTML site from HTML fragment objects.

.DESCRIPTION
Html fragment objects piped into this function (or passed via the `InputObject`
parameter) are converted into HTML documents and saved to a static Html site
directory.

The Markdown to Html document conversion uses a default or custom template with
stylesheets and JavaScript resources to render Markdown extensions for LaTeX
math, code syntax highlighting and diagrams (see `New-HtmlTemplate`) for details).

.PARAMETER InputObject
An object representing an Html fragment. Ideally this is an output object of
`Convert-MarkdownToHtmlFragment`, but any object will
work provided following properties are present:

`RelativePath`
:   A string representing the relative path to the Markdown file with respect to
    a base (static site) directory.
    This property is automatically provided by:
    * using the PowerShell function `Find-MarkdownFiles`
    * piping a file object `[System.IO.FileInfo]` into
      `Convert-MarkdownToHtmlFragment` (or passing it as a parameter).

`Title`
:   The page title.

`HtmlFragment`
:   A html fragment to be used a main content of the HTML document.

.PARAMETER Template
Optional directory containing the html template file `md-template.html` and its resources
which will be used to convert the Html fragments into standalone Html documents.
If no template directory is specified, a default factory-installed template is used.
For infomations about creating custom templates see `New-HTMLTemplate`.

.PARAMETER ContentMap
Placeholder substitution mappings. This map should contain an entry
for each custom placeholder in the HTML-template (`md-template.html`).

Following default substitution mappings are added automatically unless they
are explicitely defined in the given map:

| Key           | Description                  | Origin                      |
|:------------- | :--------------------------- | :-------------------------- |
| `{{title}}`   | Auto generated page title    | `$inputObject.Title`        |
| `[title]`     | For backwards compatibility. | `$inputObject.Title`        |
| `{{content}}` | HTML content                 | `$inputObject.HtmlFragment` |
| `[content]`   | For backwards compatibility. | `$inputObject.HtmlFragment` |

The keys of this map represent the place holders verbatim, including the
delimiters. E.g `{{my-placeholder}}`. The values in this map can be
* one or more strings
* a script block which takes **one** parameter to which the InputObject is bound.
  The script block should return one or more strings which define the
  substitution value.

  Example:

  ~~~ PowerShell
  {
      param($Input)
      "Source = $($Input.RelativePath)"
  }
  ~~~

.PARAMETER MediaDirectory
An optional directory containing additional media for the Html site
such as images, videos etc.

.PARAMETER SiteDirectory
Directory for the generated HTML files. The Html files will be placed
in the same relative location below this directory as related Markdown document
has below the input directory. If the site directory does not exist it will be created.
If the site directory already exists its files will be retained, but possibly overwitten
by generated HTML files.

.INPUTS
An Html Fragment objects having the properties `RelativePath`,`Title`, `HtmlFragment` , and
optionally `ContentMap`. See the description of the `InputObject` parameter for details

.OUTPUTS
File objects [System.IO.FileInfo] of the generated HTML documents.

.EXAMPLE
Find-MarkdownFiles '...\Modules\MarkdownToHtml' | Convert-MarkdownToHtmlFragment | Publish-StaticHtmlSite -SiteDirectory 'e:\temp\site'

Generates a static HTML site from the Markdown files in '...\Modules\MarkdownToHtml'. This is
a simpler version of the functionality provided by the function `Convert-MarkdownToHtml`.

The generated Html file objects are returned like so:

    Mode                LastWriteTime         Length Name
    ----                -------------         ------ ----
    -a----       15.09.2019     10:03          16395 Convert-MarkdownToHTML.html
    -a----       15.09.2019     10:03          14714 Convert-MarkdownToHTMLFragment.html
    -a----       15.09.2019     10:03           4612 Find-MarkdownFiles.html
    -a----       15.09.2019     10:03           6068 MarkdownToHTML.html
    ...          ...            ...            ...

.LINK
https://github.com/WetHat/MarkdownToHtml/blob/master/Documentation/Publish-StaticHtmlSite.md
.LINK
Convert-MarkdownToHtml
.LINK
Find-MarkdownFiles
.LINK
Convert-MarkdownToHtmlFragment
.LINK
New-HTMLTemplate
#>
function Publish-StaticHtmlSite {
    [OutputType([System.IO.FileInfo])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateScript({$_.RelativePath})]
        [Alias('HtmlFragment')]
        $InputObject,

        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [string]$Template = (Join-Path $SCRIPT:moduleDir.FullName 'Template'),

        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [hashtable]$ContentMap,

        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [string]$MediaDirectory,

        [parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [ValidateNotNull()]
        [string]$SiteDirectory
    )

    BEGIN {
        # Load the template
        [string[]]$htmlTemplate = Get-Content -LiteralPath (Join-Path $Template 'md-template.html')`
                                              -Encoding    UTF8

        # Create the site directory, if neccessary
        $siteDir = Get-Item -LiteralPath $SiteDirectory -ErrorAction:SilentlyContinue
        if (!$siteDir) {
            $siteDir = New-Item -Path $SiteDirectory -ItemType Directory -ErrorAction:SilentlyContinue
        }

        if (!$siteDir) {
            throw("Unable to create site directory: $SiteDirectory")
        }
        Write-Verbose "Publishing to '$siteDir' using HTML template '$Template'."

        # Copy the template resources to the site directory
        Copy-Item -Path "$Template/*" -Recurse -Exclude 'md-template.html' -Destination $siteDir -Force
    }

    PROCESS {
        [System.IO.FileInfo]$htmlFile = Join-Path $siteDir.FullName ([System.IO.Path]::ChangeExtension($InputObject.RelativePath,'html'))
        Write-Verbose  "$($InputObject.RelativePath) -> $($htmlFile.Name)"
        $htmlfile.Directory.Create() # make sure we have all directories
        $relativeResourcePath = '' # relative path to resources at the root of the output directory
        if ($InputObject.RelativePath) {
            foreach ($dir in (Split-Path $InputObject.RelativePath -Parent) -split '\\+') {
                if (![string]::IsNullOrWhiteSpace($dir)) {
                    $relativeResourcePath += '../'
                }
            }
        }
        # prepare the map for content injection
        # we need a pristine map every time
        $map = @{
            '{{title}}'   = $InputObject.Title
            '[title]'     = $InputObject.Title
            '{{content}}' = $InputObject.HTMLFragment
            '[content]'   = $InputObject.HTMLFragment
        }

        # transfer the properties from the given map
        foreach ($k in $ContentMap.Keys) {
            $value = $ContentMap[$k]
            if ($value -is [ScriptBlock]) {
                # Compute the substitution value
                $value = Invoke-Command -ScriptBlock $value -ArgumentList $_ | Out-String
            }
            $map[$k] = $value
        }

        # Inject page content
        $htmlTemplate | ForEach-Object {
            [string]$line = $_

            ## fixup resource pathes in the template header first
            $line = $line -replace '(?<=(href|src)=")(?=[^/][^:"]+")',$relativeResourcePath

            # inject content - we need to make sure that we do not scan injected
            # content for tokens
            $tokenMap = @{}
            foreach ($token in $map.keys) {
                [int]$ndx = $line.IndexOf($token)
                while ($ndx -ge 0)  {
                    $tokenMap[$ndx] = $token;
                    $ndx = $line.IndexOf($token,$ndx+$token.Length)
                }
            }

            # replace the tokens from the back
            $tokenMap.keys | Sort-Object -Descending | ForEach-Object {
                [int]$ndx = $_
                [string]$token = $tokenMap[$ndx]
                $line = $line.Substring(0,$ndx) + $map[$token] + $line.Substring($ndx+$token.Length)
            }

            Write-Output $line
        } `
        | Out-File -LiteralPath $htmlFile -Encoding    utf8
        $htmlFile
    }

    END {
        if ($MediaDirectory) {
          # copy all assets to the site directory
          Copy-Item -Path "$MediaDirectory/*" -Recurse -Exclude '*.md','*.markdown' -Destination $SiteDirectory -Force
        }
    }
}

<#
.SYNOPSIS
Find all Markdown file below a given directory.

.DESCRIPTION
Recursively scans a directory and generates annotated `[System.IO.FileInfo]` objects
for each Markdown file.

.PARAMETER Path
Path to a directory containing markdown files.

.PARAMETER Exclude
Omits the specified markdown files. The value of this parameter qualifies the Path parameter. Enter a path element or
pattern, such as "D*.md". Wildcards are permitted.

.INPUTS
None

.OUTPUTS
A `[System.IO.FileInfo]` object for each Markdown file found below the given directory. The emitted
`[System.IO.FileInfo]` objects are annotated with a note property `RelativePath` which is a string
specifying the relative path of the markdown file below the given directory. The `RelativePath` property is
**mandatory** if `Publish-StaticHtmlSite` is used in the downstream conversion
pipeline.

.EXAMPLE
Find-MarkdownFiles -Path '...\Modules\MarkdownToHtml' | Select-Object -Property Mode,LastWriteTime,Length,Name,RelativePath | Format-Table

Returns following annotated Markdown file objects of type `[System.IO.FileInfo]` for this PowerShell module:

    LastWriteTime        Length Name                       RelativePath
    -------------        ------ ----                       ------------
    13.09.2019 13:56:21  10751  Convert-MarkdownToHTML.md  Documentation\Convert-MarkdownToHTML.md
    13.09.2019 13:56:20   3348  MarkdownToHTML.md          Documentation\MarkdownToHTML.md
    13.09.2019 13:56:21   7193  New-HTMLTemplate.md        Documentation\New-HTMLTemplate.md
    11.09.2019 17:01:13   4455  README.md                  ReferenceData\katex\README.md
    ...                   ...   ...                        ...

.LINK
https://github.com/WetHat/MarkdownToHtml/blob/master/Documentation/Find-MarkdownFiles.md
.LINK
Convert-MarkdownToHtml
.LINK
Convert-MarkdownToHtmlFragment
.LINK
Publish-StaticHtmlSite
.LINK
New-HTMLTemplate
#>
function Find-MarkdownFiles {
    [OutputType([System.IO.FileInfo])]
    [CmdletBinding()]
    param (
        [SupportsWildcards()]
        [parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [ValidateNotNullorEmpty()]
        [string]$Path,
        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [string[]]$Exclude
    )
    Get-Item -Path $Path `
    | ForEach-Object {
        [string]$basePath = $_.FullName.TrimEnd('/\')
        # Compute and attach the relative path
        if ($_ -is [System.IO.DirectoryInfo]) {
            Write-Verbose "Scanning $($basePath)"
            Get-ChildItem -Path $basePath -Recurse -File -Include '*.md','*.Markdown' -Exclude $Exclude `
            | ForEach-Object {
                # capture the relative path of the Markdown file
                [string]$relativePath = $_.FullName.Substring($basePath.Length).Trim('/\').Replace('\','/')
                Add-Member -InputObject $_ -MemberType NoteProperty -Name 'RelativePath' -Value $relativePath
                $_
              }
        } else {
            # Write-Verbose "Found: $_ - $($_.GetType())"
            Add-Member -InputObject $_ -MemberType NoteProperty -Name 'RelativePath' -Value $_.Name
            $_
        }
    }
}

<#
.SYNOPSIS
Convert Markdown text to html fragments.

.DESCRIPTION
Converts Markdown text to HTML fragments using configured Markdown parser extensions.

A parser configuration is a comma separated list of configuration option strings. Currently
avaliable extensions are:

* 'abbreviations': [Abbreviations ](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/AbbreviationSpecs.md)
* 'advanced': advanced parser configuration. A pre-build collection of extensions including:
  * 'abbreviations'
  * 'autoidentifiers'
  * 'citations'
  * 'customcontainers'
  * 'definitionlists'
  * 'emphasisextras'
  * 'figures'
  * 'footers'
  * 'footnotes'
  * 'gridtables'
  * 'mathematics'
  * 'medialinks'
  * 'pipetables'
  * 'listextras'
  * 'tasklists'
  * 'diagrams'
  * 'autolinks'
  * 'attributes'
* 'attributes': [Special attributes](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/GenericAttributesSpecs.md).
   Set HTML attributes (e.g `id` or class`).
* 'autoidentifiers': [Auto-identifiers](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/AutoIdentifierSpecs.md).
`  Allows to automatically creates an identifier for a heading.
* 'autolinks': [Auto-links](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/AutoLinks.md)
   generates links if a text starts with `http://` or `https://` or `ftp://` or `mailto:` or `www.xxx.yyy`.
* 'bootstrap': [Bootstrap](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/BootstrapSpecs.md)
   to output bootstrap classes.
* 'citations': [Citation text](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FigureFooterAndCiteSpecs.md)
   by enclosing text with `''...''`
* 'common': CommonMark parsing; no parser extensions (default)
* 'customcontainers': [Custom containers](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/CustomContainerSpecs.md)
  similar to fenced code block `:::` for generating a proper `<div>...</div>` instead.
* 'definitionlists': [Definition lists](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/DefinitionListSpecs.md)
* 'diagrams': [Diagrams](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/DiagramsSpecs.md)
  whenever a fenced code block uses the 'mermaid' keyword, it will be converted to a div block with the content as-is
  (currently, supports `mermaid` and `nomnoml` diagrams). Resources for the `mermaid` diagram generator are pre-installed and configured.
  See [New-HTMLTemplate](New-HTMLTemplate.md) for customization details.
* 'emojis': [Emoji](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/EmojiSpecs.md) support
* 'emphasisextras': [Extra emphasis](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/EmphasisExtraSpecs.md)
   * strike through `~~`,
   * Subscript `~`
   * Superscript `^`
   * Inserted `++`
   * Marked `==`
* 'figures': [Figures](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FigureFooterAndCiteSpecs.md).
  A figure can be defined by using a pattern equivalent to a fenced code block but with the character `^`.
* 'footers': [Footers](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FigureFooterAndCiteSpecs.md)
* 'footnotes': [Footnotes](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FootnotesSpecs.md)
* 'globalization': [https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/GlobalizationSpecs.md]
  Adds support for RTL (Right To Left) content by adding `dir="rtl"` and `align="right"` attributes to
  the appropriate html elements. Left to right text is not affected by this extension.
* 'gridtables': [Grid tables](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/GridTableSpecs.md)
  allow to have multiple lines per cells and allows to span cells over multiple columns.
* 'hardlinebreak': [Soft lines](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/HardlineBreakSpecs.md)
   as hard lines
* 'listextras': [Extra bullet lists](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/ListExtraSpecs.md),
   supporting alpha bullet a. b. and roman bullet (i, ii...etc.)
* 'mathematics': [Mathematics](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/MathSpecs.md)
  LaTeX extension by enclosing `$$` for block and `$` for inline math. Resources for this extension are pre-installed and configured.
  See [New-HTMLTemplate](New-HTMLTemplate.md) for customization details.
* 'medialinks': [Media support](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/MediaSpecs.md)
  for media urls (youtube, vimeo, mp4...etc.)
* 'nofollowlinks': Add `rel=nofollow` to all links rendered to HTML.
* 'nohtml': [NoHTML](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/NoHtmlSpecs.md)
   allows to disable the parsing of HTML.
* 'nonascii-noescape': Use this extension to disable URI escape with % characters for non-US-ASCII characters in order to
   workaround a bug under IE/Edge with local file links containing non US-ASCII chars. DO NOT USE OTHERWISE.
* 'pipetables': [Pipe tables](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/PipeTableSpecs.md)
  to generate tables from markup.
* 'smartypants': [SmartyPants](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/SmartyPantsSpecs.md)
  quotes.
* 'tasklists': [Task Lists](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/TaskListSpecs.md).
  A task list item consist of `[ ]` or `[x]` or `[X]` inside a list item (ordered or unordered)
* 'yaml': [YAML frontmatter](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/YamlSpecs.md)
  parsing.

.PARAMETER InputObject
The input object can have one of the following of types:
* An annotated `[System.IO.FileInfo]` object as emitted by [`Find-MarkdownFiles`](Find-MarkdownFiles.md).
* A plain markdown string [`string`].
* A markdown descriptor object which is basically a [`hashtable`] whith following contents:
  | Key            | Value Type | Description                                              |
  | :------------- | :--------- | :------------------------------------------------------- |
  | `Markdown`     | [`string`] | The markdown text.                                       |
  | `RelativePath` | [`string`] | Relative path of the html file below the site directory. |

.PARAMETER IncludeExtension
Comma separated list of Markdown parsing extensions to use.

.PARAMETER ExcludeExtension
Comma separated list of Markdown parsing extensions to exclude.
Mostly used when the the 'advanced' parsing option is included and
certain individual options need to be removed.

.INPUTS
Markdown text `[string]`, Markdown file `[System.IO.FileInfo]`, or a markdown descriptor `[hashtable]`.

.OUTPUTS
HTML fragment object with following properties:

| Property       | Description                                                     |
| :------------: | :-------------------------------------------------------------- |
| `Title`        | Optional page title. The first heading in the Markdown content. |
| `HtmlFragment` | The HTML fragment string generated from the Markdown text.      |
| `RelativePath` | Passed through form the input object, provided it exists.       |

.NOTES
The conversion to HTML fragments also includes:
* Changing links to Markdown files to the corresponding Html files.

<blockquote>

~~~ Markdown
[Hello World](Hello.md)
~~~

becomes:

~~~ html
<a href="Hello.html">
~~~

</blockquote>

* HTML encoding code blocks:

<blockquote>

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

</blockquote>

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
https://github.com/WetHat/MarkdownToHtml/blob/master/Documentation/Convert-MarkdownToHTMLFragment.md
.LINK
Convert-MarkdownToHtml
.LINK
Find-MarkdownFiles
.LINK
Publish-StaticHtmlSite
.LINK
New-HTMLTemplate
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
        [string[]]$ExcludeExtension = @()
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
        [string]$fragment = [Markdig.Markdown]::ToHtml($md, $pipeline)

        # properly escape code blocks in the html fragment and rewrite hyperlinks.
        $fragment = ($fragment -split '(<code[^>]*>|</code>)' `
        | ForEach-Object `
            -Begin   {
                        [bool]$encode = $false
                     } `
            -Process {
                        if ($_.StartsWith('<code')) {
                            $encode = $true
                            $_
                        } elseif ($_.StartsWith('</code>')) {
                            $encode = $false
                            $_
                        } elseif ($encode) { ## inside code block
                            [System.Net.WebUtility]::HtmlEncode([System.Net.WebUtility]::HtmlDecode($_))
                        } else { # outside code blocks - rewrite hyperlinks
                            $_ -split '(?<=<a [^>]*)(href="[^"]*")' `
                            | ForEach-Object {
                                if ($_ -match '^href=".*"' -and $_ -notmatch '^href="https?://') {
                                    $_ -replace '(\.md|\.markdown)(?=["#])','.html'
                                } else {
                                    $_
                                }
                              }
                        }
                     })  -Join '' # return just one string
        # guess a title
        $htmlDescriptor = @{'HtmlFragment' = $fragment}
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
        $htmlDescriptor # return the annotated HTML fragmemt
    }
}

<#
.SYNOPSIS
Convert Markdown files into HTML files.

.DESCRIPTION
This function reads all Markdown files from a source folder and converts each
of them to standalone html documents using configurable Markdown extensions and
a customizable HTML template. See `about_MarkdownToHTML` for a list of
supported extensions and customization options.

.PARAMETER Path
Path to Markdown files or directories containing Markdown files.

.PARAMETER Template
Optional directory containing the html template file `md-template.html` and its resources.
If no template directory is specified, a default factory-installed template is used.
For infomations about creating custom templates see `New-HTMLTemplate`.

.PARAMETER IncludeExtension
Comma separated list of Markdown parsing extensions to use (see notes for available extensions).

.PARAMETER ExcludeExtension
Comma separated list of Markdown parsing extensions to exclude.
Mostly used when the the 'advanced' parsing option is included and
certain individual options need to be removed,

.PARAMETER MediaDirectory
An optional directory containing additional media for the Html site
such as images, videos etc. Defaults to the directory given in `-Path`

.PARAMETER SiteDirectory
Directory for the generated HTML files. The Html files will be placed
in the same relative location below this directory as related Markdown document
has below the Markdown source directory.

.INPUTS
This function does not read from the pipe.

.OUTPUTS
File objects `[System.IO.FileInfo]` of the generated HTML files.

.EXAMPLE
Convert-MarkdownToHTML -Path 'E:\MyMarkdownFiles' -SiteDirectory 'E:\MyHTMLFiles'

Convert all Markdown files in `E:\MyMarkdownFiles` and save the generated HTML files
in `E:\MyHTMLFiles`

.EXAMPLE
Convert-MarkdownToHTML -Path 'E:\MyMarkdownFiles' -Template 'E:\MyTemplate' -SiteDirectory 'E:\MyHTMLFiles'

Convert all Markdown files in `E:\MyMarkdownFiles` using
* the 'common' parsing configuration
* the custom template in `E:\MyTemplate`

The generated HTML files are saved to `E:\MyHTMLFiles`.

.EXAMPLE
Convert-MarkdownToHTML -Path 'E:\MyMarkdownFiles' -SiteDirectory 'E:\MyHTMLFiles' -IncludeExtension 'advanced','diagrams'

Convert all Markdown files in `E:\MyMarkdownFiles` using
* the 'advanced' and 'diagrams' parsing extension.
* the default template

The generated HTML files are saved to `E:\MyHTMLFiles`.

.EXAMPLE
Convert-MarkdownToHTML -Path 'E:\MyMarkdownFiles' -MediaDirectory 'e:\Media' -SiteDirectory 'E:\MyHTMLFiles' -IncludeExtension 'advanced','diagrams'

Convert all Markdown files in `E:\MyMarkdownFiles` using
* the 'advanced' and 'diagrams' parsing extension.
* the default template
* Media files (images, Videos, etc.) from the directory `e:\Media`

The generated HTML files are saved to `E:\MyHTMLFiles`.

.NOTES
Currently available Markdown parser extensions are:

* **'abbreviations'**: [Abbreviations ](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/AbbreviationSpecs.md)
* **'advanced'**: advanced parser configuration. A pre-build collection of extensions including:
  * 'abbreviations'
  * 'autoidentifiers'
  * 'citations'
  * 'customcontainers'
  * 'definitionlists'
  * 'emphasisextras'
  * 'figures'
  * 'footers'
  * 'footnotes'
  * 'gridtables'
  * 'mathematics'
  * 'medialinks'
  * 'pipetables'
  * 'listextras'
  * 'tasklists'
  * 'diagrams'
  * 'autolinks'
  * 'attributes'
* **'attributes'**: [Special attributes](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/GenericAttributesSpecs.md).
   Set HTML attributes (e.g `id` or class`).
* **'autoidentifiers'**: [Auto-identifiers](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/AutoIdentifierSpecs.md).
`  Allows to automatically creates an identifier for a heading.
* **'autolinks'**: [Auto-links](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/AutoLinks.md)
   generates links if a text starts with `http://` or `https://` or `ftp://` or `mailto:` or `www.xxx.yyy`.
* **'bootstrap'**: [Bootstrap](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/BootstrapSpecs.md)
   to output bootstrap classes.
* **'citations'**: [Citation text](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FigureFooterAndCiteSpecs.md)
   by enclosing text with `''...''`
* **'common'**: CommonMark parsing; no parser extensions (default)
* **'customcontainers'**: [Custom containers](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/CustomContainerSpecs.md)
  similar to fenced code block `:::` for generating a proper `<div>...</div>` instead.
* **'definitionlists'**: [Definition lists](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/DefinitionListSpecs.md)
* **'diagrams'**: [Diagrams](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/DiagramsSpecs.md)
  whenever a fenced code block uses the 'mermaid' keyword, it will be converted to a div block with the content as-is
  (currently, supports `mermaid` and `nomnoml` diagrams). Resources for the `mermaid` diagram generator are pre-installed and configured.
  See [New-HTMLTemplate](New-HTMLTemplate.md) for customization details.
* **'emojis'**: [Emoji](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/EmojiSpecs.md) support
* **'emphasisextras'**: [Extra emphasis](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/EmphasisExtraSpecs.md)
   * strike through `~~`,
   * Subscript `~`
   * Superscript `^`
   * Inserted `++`
   * Marked `==`
* **'figures'**: [Figures](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FigureFooterAndCiteSpecs.md).
  A figure can be defined by using a pattern equivalent to a fenced code block but with the character `^`.
* **'footers'**: [Footers](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FigureFooterAndCiteSpecs.md)
* **'footnotes'**: [Footnotes](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FootnotesSpecs.md)
* **'globalization'**: [https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/GlobalizationSpecs.md]
  Adds support for RTL (Right To Left) content by adding `dir="rtl"` and `align="right"` attributes to
  the appropriate html elements. Left to right text is not affected by this extension.
* **'gridtables'**: [Grid tables](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/GridTableSpecs.md)
  allow to have multiple lines per cells and allows to span cells over multiple columns.
* **'hardlinebreak'**: [Soft lines](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/HardlineBreakSpecs.md)
   as hard lines
* **'listextras'**: [Extra bullet lists](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/ListExtraSpecs.md),
   supporting alpha bullet a. b. and roman bullet (i, ii...etc.)
* **'mathematics'**: [Mathematics](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/MathSpecs.md)
  LaTeX extension by enclosing `$$` for block and `$` for inline math. Resources for this extension are pre-installed and configured.
  See [New-HTMLTemplate](New-HTMLTemplate.md) for customization details.
* **'medialinks'**: [Media support](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/MediaSpecs.md)
  for media urls (youtube, vimeo, mp4...etc.)
* **'nofollowlinks'**: Add `rel=nofollow` to all links rendered to HTML.
* **'nohtml'**: [NoHTML](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/NoHtmlSpecs.md)
   allows to disable the parsing of HTML.
* **'nonascii-noescape'**: Use this extension to disable URI escape with % characters for non-US-ASCII characters in order to
   workaround a bug under IE/Edge with local file links containing non US-ASCII chars. DO NOT USE OTHERWISE.
* **'pipetables'**: [Pipe tables](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/PipeTableSpecs.md)
  to generate tables from markup.
* **'smartypants'**: [SmartyPants](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/SmartyPantsSpecs.md)
  quotes.
* **'tasklists'**: [Task Lists](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/TaskListSpecs.md).
  A task list item consist of `[ ]` or `[x]` or `[X]` inside a list item (ordered or unordered)
* **'yaml'**: [YAML frontmatter](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/YamlSpecs.md)
  parsing.

**Note**: Some parser options require additional template configuration. See [New-HTMLTemplate](New-HTMLTemplate.md) for details.

Custom templates can be easily generated by [New-HTMLTemplate](New-HTMLTemplate.md).

Markdown conversion uses the [Markdig](https://github.com/lunet-io/markdig)
library. Markdig is a fast, powerful, [CommonMark](http://commonmark.org/) compliant,
extensible Markdown processor for .NET.

.LINK
https://github.com/WetHat/MarkdownToHtml/blob/master/Documentation/Convert-MarkdownToHTML.md
.LINK
https://github.com/lunet-io/markdig
.LINK
http://commonmark.org/
.LINK
https://highlightjs.org/
.LINK
https://mermaidjs.github.io/
.LINK
https://katex.org/
.LINK
`Find-MarkdownFiles`
.LINK
Convert-MarkdownToHtmlFragment
.LINK
Publish-StaticHtmlSite
.LINK
New-HTMLTemplate
#>
function Convert-MarkdownToHTML {
    [OutputType([System.IO.FileInfo])]
    [CmdletBinding()]
    param(
            [SupportsWildcards()]
            [parameter(Mandatory=$true,ValueFromPipeline=$false)]
            [ValidateNotNullorEmpty()]
            [Alias('Markdown')]
            [string]$Path,

            [parameter(Mandatory=$false,ValueFromPipeline=$false)]
            [string]$Template =  (Join-Path $SCRIPT:moduleDir.FullName 'Template'),

            [parameter(Mandatory=$false,ValueFromPipeline=$false)]
            [string[]]$IncludeExtension = @('common'),

            [parameter(Mandatory=$false,ValueFromPipeline=$false)]
            [string[]]$ExcludeExtension = @(),

            [parameter(Mandatory=$false,ValueFromPipeline=$false)]
            [string]$MediaDirectory = $Path,

            [parameter(Mandatory=$true,ValueFromPipeline=$false)]
            [ValidateNotNullorEmpty()]
            [Alias('Destination')]
            [string]$SiteDirectory
        )
    Write-Verbose "$Path -> $SiteDirectory"

    Find-MarkdownFiles -Path $Path -Verbose:$Verbose `
    | Convert-MarkdownToHTMLFragment -IncludeExtension $IncludeExtension `
                                     -ExcludeExtension $ExcludeExtension `
                                     -Verbose:$Verbose `
    | Publish-StaticHtmlSite -MediaDirectory $MediaDirectory `
                             -SiteDirectory $SiteDirectory `
                             -Template $Template `
                             -Verbose:$Verbose
}

<#
.SYNOPSIS
Create a customizable template directory for Markdown to HTML conversion.

.DESCRIPTION
The factory-default conversion template is copied to the destination directory
to seed the customization process.

See `about_MarkdownToHTML` section TEMPLATE CUSTOMIZATION for details about the
customization options.

The HTML template file returned by this function (`md-template.html`) has a
simple structure containing two content placeholders:

`{{title}}`
:   Placeholder for a page title generated from the Markdown content or filename.

`{{content}}`
:   Placeholder for the HTML content fragment generated from Markdown content.

If a more sophisticated HTML template is needed which can also contain custom
placeholders, check out `New-StaticHTMLSiteProject`.

.PARAMETER Destination
Location of the new conversion template directory. The template directory
should be empty or non-existent.

.EXAMPLE
New-HTMLTemplate -Destination 'E:\MyTemplate'

Create a copy of the default template in `E:\MyTemplate` for customization.

.INPUTS
This function does not read from the pipe

.OUTPUTS
The new conversion template directory `[System.IO.DirectoryInfo]`

.LINK
https://github.com/WetHat/MarkdownToHtml/blob/master/Documentation/New-HTMLTemplate.md

.LINK
`New-StaticHTMLSiteProject`

#>
function New-HTMLTemplate {
    [OutputType([System.IO.DirectoryInfo])]
    [CmdletBinding()]
    param(
            [parameter(Mandatory=$true,ValueFromPipeline=$false)]
            [ValidateNotNullorEmpty()]
            [string]$Destination
         )
    $template = Join-Path $SCRIPT:moduleDir.FullName 'Template'
    $assets = Join-Path $SCRIPT:moduleDir.FullName 'Template.assets'
    $outdir = Get-Item -LiteralPath $Destination -ErrorAction:SilentlyContinue

    # Create the site directory
    if ($null -eq $outdir ) {
        $outdir = New-Item -Path $Destination -ItemType Directory -ErrorAction:SilentlyContinue
    }

    if ($null -eq $outdir -or $outdir -isnot [System.IO.DirectoryInfo]) {
        throw("Unable to create directory $Destination")
    }
    ## Copy the template to the output directory
    Copy-Item -Path "${template}/*" -Recurse -Destination $outDir
    Copy-Item -Path "${assets}/*" -Recurse -Destination $outDir -ErrorAction:SilentlyContinue
    $outDir
}
<#
.SYNOPSIS
Create a customizable Markdown to HTML site conversion project.

.DESCRIPTION
The new project is fully functional and ready for building.

A single markdown file (`README.md`) is provided as initial content. It explains
project customization options. It is recommended to build the project by
executing its build script `Build.ps1`. This creates an initial HTML site
containing the HTML version of the README (`html/README.html`) which is more
pleasant to read.

The project directory created by this function has the following structure:

~~~
#                  <- project root
|- html            <- build output (static site)
|- markdown        <- authored Markdown content
|-    '- README.md <- initial content
|- Template        <- template resources
|     |- js        <- javascripts (*.js)
|     |- katex     <- LateX math renderer
|     |- styles    <- stylesheets (*.css)
|     '- md-template.html <- Html page template
|- Build.json      <- project configuration
'- Build.ps1       <- build script
~~~

### The `html` Directory
This build output directory contains the static HTML site. This directory
is overwritten by every build.

### The `markdown` Directory
Contains the Markdown content for this project. Initially only the project's
`README.md` is there.

### The `Template` Directory
Containings the HTML template file and resources for the project.
Read `about_MarkdownToHTML` section 'TEMPLATE CUSTOMIZATION' for more
information. The HTML template (`md-template.html`) in this
directory contains, besides the two standard placeholders `{{title}}` and
    `{{content}}`, following additional placeholders:

`{{nav}}`
:   Placehoder which is replaced by a HTML content fragment
    providing a navigatation section on each page.

`{{footer}}`
:   Placeholder which is replaced by a HTML content fragment
    representing the page footer.

### The `Build.json` Project Configuration File
This file uses [JavaScript Object Notation](https://en.wikipedia.org/wiki/JSON)
format (JSON). Configurable items in this file are:

`markdown_dir` (default: "markdown")
:   Relative path to the Markdown content directory.
    Besides Markdown files, this directory also contains media file such as
    images or videos used by Markdown files.

`site_dir` (default: "html")
:   Relative path to the static HTML site. This directory holds the project
    build result. The contens of this directory will be overwritten on every project
    build.

`HTML_template` (default: "Template")
:   Location of the template resources (`*.css`, `*.js`, etc) needed to build
    the HTML site.

`Exclude` (default: empty)
:   A list of file name pattern to exclude from the build process.

`markdown_extensions` (default: "common","definitionlists")
:   A list of markdown extensions to enable for this project. For a list of
    possible extensions, refer to the documentation of the function
    `Convert-MarkdownToHTMLFragment`.

`footer`
:   Page footer text which gets substituted for the placeholder `{{footer}}` in
    the HTML template `md-template.html`.

`site_navigation`
:   A list of links to be shown in each page's `<nav>` section.
    The list will be substitutes for the placeholder `{{nav}}` in
    the HTML template `md-template.html`. The syntax for navigation
    links is:

    * Links to local pages: `{ "<label>": "<relative path>" }`
    * Links to web pages: `{ "<label>": "http(s)://...." }`
    * Separator Labels: `{ "<label>": "" }`
    * Separator Lines: `{ "---": "" }`

    **Note**: If the extension `autoidentifiers` is configured (default), a
    navigation section with links to the headings on the current page is
    appended automatically to the navigation items configured in this file.

### The Project Build Script `Build.ps1`
The project build script implements the Markdown to HTML conversion time.

If a new placeholder is to be used in the `md-template.html` the mapping of that
placeholder must be defined in this file. By default following mappings are
defined in the _Set-up the content mapping rules_ section:

~~~ PowerShell
# Set-up the content mapping rules
$SCRIPT:contentMap = @{
	# Add additional mappings here...
	'{{footer}}' =  $config.Footer # Footer text from configuration
	'{{nav}}'    = {
		param($fragment)
		# Create the navigation items configured in 'Build.json'
		$config.site_navigation | ConvertTo-NavigationItem -RelativePath $fragment.RelativePath
		# Create navigation items to headings on the local page
        # This required the `autoidentifiers` extension.
		ConvertTo-PageHeadingNavigation $fragment.HTMLFragment | ConvertTo-NavigationItem
	}
}
~~~

.PARAMETER ProjectDirectory
The location of the new Markdown to HTML site conversion project.

.INPUTS
None

.OUTPUTS
The new project directory object `[System.IO.DirectoryInfo]`

.EXAMPLE
New-StaticHTMLSiteProject -ProjectDirectory MyProject

Create a new conversion project names 'MyProject' in the current directory. The
project is ready for build.

.LINK
https://github.com/WetHat/MarkdownToHtml/blob/master/Documentation/New-StaticHTMLSiteProject.md
.LINK
`New-HTMLTemplate`

#>
function New-StaticHTMLSiteProject {
    [OutputType([System.IO.DirectoryInfo])]
    [CmdletBinding()]
    param(
            [parameter(Mandatory=$true,ValueFromPipeline=$false)]
            [ValidateNotNull()]
            [string]$ProjectDirectory
         )
    $diritem = Get-Item -Path $ProjectDirectory -ErrorAction:SilentlyContinue

    if ($diritem) {
        throw "$ProjectDirectory already exists!"
    }

    $diritem = New-Item -Path $ProjectDirectory -ItemType Directory

    # Copy project template to new directory
    Write-Information "Copying project files ..." -InformationAction Continue
    Copy-Item -Path "$moduleDir/ProjectTemplate/*" -Destination $diritem -Recurse
        # copy the standard assets too
    Copy-Item -Path "$moduleDir/Template.assets/*" `
              -Destination "$diritem/Template" `
              -Recurse -ErrorAction:SilentlyContinue

    Write-Information '' -InformationAction Continue
    Write-Information "Project '$($diritem.Name)' ready!" -InformationAction Continue
    Write-Information "1. Run the build script '$ProjectDirectory/Build.ps1'" -InformationAction Continue
    Write-Information "2. Open '$ProjectDirectory/html/README.html' in the browser!" -InformationAction Continue
    $diritem
}

<#
.SYNOPSIS
Convert a navigation specification to a HTML element representing a navigation
link..

.DESCRIPTION
Converts a navigation specification to an HTML an element representing a single
navigation line in a simple vertical navigation bar.

Following kinds of navigation links are supported:
* navigatable links
* separator lines
* labels (without link)

The generated HTML element is assigned to the class `navitem` to enable
styling in `md-styles.css`.

.PARAMETER RelativePath
A path relative to the site root for the HTML document the navigation is to used
for. This relative path is used to adjust the relative links which may be
present in the link specification so that they work from the location of the
HTML page the navifation is build for. The given path should be in HTML notation
and is expected to use forward slash '/' path separators.

.PARAMETER NavSpec
An object or hashtables with one NoteProperty or key. The property or key name
defines the link label, the associated value defines the link target location.

If the link target location of a specification item is the **empty string**, the
item has special meaning. If the name is the '---', a horizontal separator line
is generated. If it is just plain text (or a HTML fragment), a label without
clickable link is generated.

.INPUTS
Objects or hashtables with one NoteProperty or key.

.OUTPUTS
HTML element representing one navigation item for use in a vertical navigation
bar.

.EXAMPLE
ConvertTo-NavigationItem @{'Project HOME'='https://github.com/WetHat/MarkdownToHtml'} -RelativePath 'into/about.md'

Generates a web navigation link to be put on the page `intro/about.md`. Note
the `RelativePath` is not needed for that link. OUtput:

~~~ html
<button class='navitem'>
    <a href="https://github.com/WetHat/MarkdownToHtml">Project HOME</a>
</button><br/>
~~~

.EXAMPLE
ConvertTo-NavigationItem @{'Index'='index.md'} -RelativePath 'intro/about.md'

Generates a relative navigation link to be put on the page `into/about.md`. The
link target is another page `index.md` on the same site, hence the link is
adjusted accordingly.

Output:

~~~ html
<button class='navitem'>
    <a href="../index.html">Index</a>
</button><br/>
~~~

.EXAMPLE
ConvertTo-NavigationItem @{'---'=''} -RelativePath 'intro/about.md'

Generates a separator line. Note that the `RelativePath` is not used.

Output:

~~~ html
<hr class="navitem" />
~~~

.EXAMPLE
ConvertTo-NavigationItem @{'Introduction'=''} -RelativePath 'intro/about.md'

Generates a label. Note that the `RelativePath` is not used.

Output:

~~~ html
<div class='navitem'>Introduction</div>
~~~

.NOTES
This function is typically used in the build script `Build.ps1` to define
the contents of the navigation bar (placeholder `{{nav}}`).
#>
function ConvertTo-NavigationItem {
    [OutputType([string])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [object]$NavSpec,
        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [string]$RelativePath = ''
    )
    PROCESS {
        # Determine the relative navigation path of this page to root
	    $up = '../' * ($RelativePath.Split('/').Length - 1)

	    # create page specific navigation links by making the path relative to
        # the current location specified by `RelativePath`
        $name = if ($NavSpec -is [hashtable]) {
                    $NavSpec.Keys | Select-Object -First 1
                } else {
                    (Get-Member -InputObject $NavSpec -MemberType NoteProperty).Name
                }
	    $link = $NavSpec.$name
	    if ([string]::IsNullOrWhiteSpace($link)) {
		    if ($name.StartsWith('---')) {
			    Write-Output '<hr class="navitem" />' # separator
		    } else {
			    Write-Output "<div class='navitem'>$name</div>" # label
		    }
	    } else {
		    if (!$link.StartsWith('http')){
			    # handle fragment on page

                $hash = $link.IndexOf('#')

                switch ($hash) {
                    {$_ -eq 0 } { # '#target'
                        $file = ''
                        $fragment = $link
                        Break
                    }
                    {$_ -ge 0} {
                        $file = $link.Substring(0,$hash)
                        $fragment = $link.Substring($hash)
                        Break
                    }
                    default {
                        $file = $link
                        $fragment = ''
                    }
                }

                # rewrite the link so that it works from the current location
                $file = if ($file.EndsWith('.md') -or $file.EndsWith('.markdown')) {
	                        $up + [System.IO.Path]::ChangeExtension($file,'html')
                        } elseif (![string]::IsNullOrWhiteSpace($file)) {
                            $up + $file
                        }

                # re-assemble the updated link
                $link = $file + $fragment
		    }
		    Write-Output "<button class='navitem'><a href=`"$link`">$name</a></button><br/>"
	    }
    }
}

# find headings on in an HTML fragment.
$SCRIPT:hRE = New-Object regex '<h(\d)[^<>]* id="([^"])+"[^<]*>(.+?)\s*(?=</h\d.*|$)'
# Match a hyperlink
$aRE = New-Object regex '</{0,1} *a[^>]*>'

<#
.SYNOPSIS
Generate navigation specifications for all headings found in an HTML fragment.

.DESCRIPTION
Retrieves all headings (`h1`.. `h6`) from a HTML fragment and generates a link
specification for each heading that has an `id` attribute.

The link specifications have a format suitable for conversion to HTML
navigation code by `ConvertTo-NavigationItem`

.PARAMETER HTMLfragment
HTML text to be scanned for headings.

.INPUTS
None. This function does not read from a pipe.

.OUTPUTS
HTML elements representing navigation links to headings on the input HTML
fragment for use in a vertical navigation bar.

.EXAMPLE
ConvertTo-PageHeadingNavigation '<h1 id="bob">Hello World</h1>' | ConvertTo-NavigationItem

Create an HTML element for navigation for a heading. Output:

~~~ HTML
<button class='navitem'>
   <a href="#bob"><span class="navitem1">Hello World</span></a>
</button><br/>
~~~

.NOTES
This function is typically used in the build script `Build.ps1` to define
the contents of the navigation bar (placeholder `{{nav}}`).
#>
function ConvertTo-PageHeadingNavigation {
    [OutputType([hashtable])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [ValidateNotNull()]
        [string]$HTMLfragment
    )
    $HTMLfragment -split "`n" | ForEach-Object {
        $m = $hRE.Match($_)
        if ($m.Success -and $m.Groups.Count -eq 4) {
            # found a heading with an id attribute
            $level = $m.Groups[1].Captures.Value
            $id = $m.Groups[2].Captures -join ''
            $txt = $m.Groups[3].Captures -join ''
            # strip hyperlinks in heading text
            $txt = $aRE.Replace($txt,'')
            @{"<span class=`"navitem$level`">$txt</span>" = "#$id"}
        }
    } | ConvertTo-NavigationItem
}
# SIG # Begin signature block
# MIIFYAYJKoZIhvcNAQcCoIIFUTCCBU0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUdZh0kcaDgMG6vptcMObtsUDg
# 9vCgggMAMIIC/DCCAeSgAwIBAgIQaejvMGXYIKhALoN4OCBcKjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRLOcGeHtSkcLjoYGLjf204x/gC
# rDANBgkqhkiG9w0BAQEFAASCAQApLQZdNCap+iAY/roZaeKn1rRnubAL5L1xGKIf
# 72VJY89Z++0axBbbeWiQbIDr7TcSpy+pssOdD+VVRX6Yt4yUSTo6NrRvorLkwr71
# 5o1kES5O3nUhSid3HQjOTGN1t2N3PIXzzygObxG/66LLxzSghFfFDQ8ciiEqAgTx
# 7UOxvHFFPYiuTcW1lt3uEugb8/6lTJvzRHf5rcGlFpYEQFwobTc1oVP5Qb1wQ22A
# TPPGg2FMBl/IpA1An1M1m9HFkLOqfdqXRNvk07MSYT64WB+8aWfyYCuO54rcLyBK
# P68sv4MPS2O4g+zQ1aDmxH3tYUoGbKdbKv0Sorp7k34MHsHv
# SIG # End signature block

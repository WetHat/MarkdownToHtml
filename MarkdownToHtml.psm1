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

        [parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [ValidateNotNull()]
        [string]$SiteDirectory
    )
    
    BEGIN {
        # Load the template
        [string[]]$htmlTemplate = Get-Content -LiteralPath (Join-Path $Template 'md-template.html')`
                                              -Encoding    UTF8

        ## Create the site directory, if neccessary
        $siteDir = Get-Item -LiteralPath $SiteDirectory -ErrorAction:SilentlyContinue
        if (!$siteDir) {
            $siteDir = New-Item -Path $SiteDirectory -ItemType Directory -ErrorAction:SilentlyContinue
        }

        if (!$siteDir) {
            throw("Unable to create site directory: $SiteDirectory")
        }
        Write-Verbose "Publishing to '$siteDir' using HTML template '$Template'."

        ## Copy the template resources to the site directory
        Copy-Item -Path "$Template/*" -Recurse -Exclude 'md-template.html' -Destination $siteDir -Force
    }

    PROCESS {
        [System.IO.FileInfo]$htmlFile = Join-Path $siteDir.FullName ([System.IO.Path]::ChangeExtension($InputObject.RelativePath,'html'))
        $htmlfile.Directory.Create() # make sure we have all directories
        $relativeResourcePath = '' # relative path to resources at the root of the output directory
        foreach ($dir in (Split-Path $InputObject.RelativePath -Parent) -split '\\+') {
            if (![string]::IsNullOrWhiteSpace($dir)) {
                $relativeResourcePath += '../'
            }
        }

        $htmlTemplate | ForEach-Object {
            if ($InputObject.Title -and $_ -match '^\s*<title>\[title\]</title>\s*$') {
                Write-Output "<title>$($InputObject.Title)</title>"
            } elseif ($_ -match '^\s*\[content\]\s*$') {
                Write-Output $InputObject.HtmlFragment
            } else {
                ## fixup resource pathes in the template header
                Write-Output ($_ -replace '(?<=(href|src)=")(?=[^/][^:"]+")',$relativeResourcePath)
            }
        } `
        | Out-File -LiteralPath $htmlFile -Encoding    utf8
        $htmlFile
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

.INPUTS
None

.OUTPUTS
A `[System.IO.FileInfo]` object for each Markdown file found below the given directory. The
`[System.IO.FileInfo]` objects are annotated with a note property `RelativePath` which is a string
specifying the relative path of the markdown file below the given directory.

.EXAMPLE
Find-MarkdownFiles -Path 'E:\Lab\WindowsPowerShell\Modules\MarkdownToHtml' | Select-Object -Property Mode,LastWriteTime,Length,Name,RelativePath | Format-Table

Returns following annotated Markdown file objects of type `[System.IO.FileInfo]` for this PowerShell module:

    LastWriteTime        Length Name                       RelativePath
    -------------        ------ ----                       ------------
    13.09.2019 13:56:21  10751  Convert-MarkdownToHTML.md  Documentation\Convert-MarkdownToHTML.md
    13.09.2019 13:56:20   3348  MarkdownToHTML.md          Documentation\MarkdownToHTML.md
    13.09.2019 13:56:21   7193  New-HTMLTemplate.md        Documentation\New-HTMLTemplate.md
    11.09.2019 17:01:13   4455  README.md                  ReferenceData\katex\README.md
    ...                   ...   ...                        ...
#>
function Find-MarkdownFiles {
    [OutputType([System.IO.FileInfo])]
    [CmdletBinding()]
    param (
        [SupportsWildcards()]
        [parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [ValidateNotNullorEmpty()]
        [string]$Path
    )
    Get-Item -Path $Path `
    | ForEach-Object {
        [string]$basePath = $_.FullName.TrimEnd('/\')
        # Compute and attach the relative path
        if ($_ -is [System.IO.DirectoryInfo]) {
            Write-Verbose "Scanning $($basePath)"
            Get-ChildItem -Path $basePath -Recurse -File -Include '*.md','*.Markdown' `
            | ForEach-Object {
                # capture the relative path of the Markdown file
                [string]$relativePath = $_.FullName.Substring($basePath.Length).Trim('/\')
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

.PARAMETER Markdown
A Markdown string of a Markdown file [System.IO.FileInfo]

.PARAMETER IncludeExtension
Comma separated list of Markdown parsing extensions to use.

.PARAMETER ExcludeExtension
Comma separated list of Markdown parsing extensions to exclude.
Mostly used when the the 'advanced' parsing option is included and
certain individual options need to be removed.

.INPUTS
Markdown text [string] or Markdown file [System.IO.FileInfo].

.OUTPUTS
HTML fragment object with following properties:
* `RelativePath`: A string representing the relative path to the Markdown file with respect to
  a base directory. This property is mandatory when using the PowerShell function [`Publish-StaticHtmlSite`](Publish-StaticHtmlSite.md)
  to generate a static HTML site from Markdown files.
  This propery is automatically set when
  * using the PowerShell function [`Find-MarkdownFiles`](Find-MarkdownFiles.md)
  * the `-Markdown` parameter is of type `[System.IO.FileInfo]`.
* `Title`: The first heading in the Markdown content. This property may be absent if no heading was found
* `HtmlFragment`: The HTML fragment string generated from the Markdown text.

.NOTES

The conversion to HTML framgments also implies:
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

Returns the html fragment object:

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
#>
function Convert-MarkdownToHTMLFragment
{
    [OutputType([hashtable])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateScript({$_ -is [string] -or $_ -is [System.IO.FileInfo]})]
        $Markdown,

        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [string[]]$IncludeExtension = @('advanced'),

        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [string[]]$ExcludeExtension = @()
    )
    BEGIN {
        ## Determine which parser extensions to use
        if ($IncludeExtension -eq $null -or $IncludeExtension.Count -eq 0) {
            $extensions = @('common') # use _common_ extensions by default
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
        [string]$md = if ($Markdown -is [System.IO.FileInfo]) {
                          Get-Content -LiteralPath $Markdown.FullName -Encoding UTF8 | Out-String
                      } else {
                          $Markdown
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
        $htmlDescriptor = @{'HtmlFragment' = $fragment}
        # guess a title
        $match = [regex]::Match($md,'^[#\s]*([^\r\n]+)\s*\{*')
        if ($match.Success) {
            $htmlDescriptor.Title = $match.Groups[1].Value
        } elseif ($Markdown.BaseName) {
            $htmlDescriptor.Title = $Markdown.BaseName
        }

        if ($Markdown.RelativePath) {
            $htmlDescriptor.RelativePath = $Markdown.RelativePath
        } elseif ($Markdown.Name) {
            $htmlDescriptor.RelativePath = $Markdown.Name
        }

        $htmlDescriptor # return the annotated HTML fragmemt
    }
}

<#
.SYNOPSIS
Convert Markdown files into HTML files.

.DESCRIPTION
This function reads all Markdown files from a source folder and converts each of them to
standalone html documents using configured parser extensions and an HTML template.

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

**Note** Some parser options require additional template configuration. See [New-HTMLTemplate](New-HTMLTemplate.md) for details.

Custom templates can be easily generated by [New-HTMLTemplate](New-HTMLTemplate.md).

.PARAMETER Path
Path to Markdown files or directories containing Markdown files.

.PARAMETER Template
Optional directory containing the html template file `md-template.html` and its resources.
If no template directory is specified, a default factory-installed template is used.
For infomations about creating custom templates see [New-HTMLTemplate](New-HTMLTemplate.md).

.PARAMETER IncludeExtension
Comma separated list of Markdown parsing extensions to use.

.PARAMETER ExcludeExtension
Comma separated list of Markdown parsing extensions to exclude.
Mostly used when the the 'advanced' parsing option is included and
certain individual options need to be removed,

.PARAMETER Destination
Directory for the generated HTML files.

.INPUTS
This function does not read from the pipe

.OUTPUTS
HTML files generated `[System.IO.FileInfo]`

.EXAMPLE
Convert-MarkdownToHTML -Markdown 'E:\MyMarkdownFiles' -Destination 'E:\MyHTMLFiles'

Convert all Markdown files in `E:\MyMarkdownFiles` and save the generated HTML files
in `E:\MyHTMLFiles`

.EXAMPLE
Convert-MarkdownToHTML -Markdown 'E:\MyMarkdownFiles' -Template 'E:\MyTemplate' -Destination 'E:\MyHTMLFiles'

Convert all Markdown files in `E:\MyMarkdownFiles` using
* the 'common' parsing configuration
* the custom template in `E:\MyTemplate`

The generated HTML files are saved to `E:\MyHTMLFiles`.

.EXAMPLE
Convert-MarkdownToHTML -Markdown 'E:\MyMarkdownFiles' -Destination 'E:\MyHTMLFiles' -IncludeExtension 'advanced','diagrams'

Convert all Markdown files in `E:\MyMarkdownFiles` using
* the 'advanced' and 'diagrams' parsing extension.
* the default template

The generated HTML files are saved to `E:\MyHTMLFiles`.

.NOTES
Markdown conversion uses the [Markdig](https://github.com/lunet-io/markdig)
library. Markdig is a fast, powerful, [CommonMark](http://commonmark.org/) compliant,
extensible Markdown processor for .NET.

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
New-HTMLTemplate
#>
function Convert-MarkdownToHTML {
    [OutputType([System.IO.FileInfo])]
    [CmdletBinding()]
    param(
            [SupportsWildcards()]
            [parameter(Mandatory=$true,ValueFromPipeline=$false)]
            [ValidateNotNullorEmpty()]
            [string]$Path,

            [parameter(Mandatory=$false,ValueFromPipeline=$false)]
            [string]$Template =  (Join-Path $SCRIPT:moduleDir.FullName 'Template'),

            [parameter(Mandatory=$false,ValueFromPipeline=$false)]
            [string[]]$IncludeExtension = @('common'),

            [parameter(Mandatory=$false,ValueFromPipeline=$false)]
            [string[]]$ExcludeExtension = @(),

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
    | Publish-StaticHtmlSite -SiteDirectory $SiteDirectory `
                             -Template $Template `
                             -Verbose:$Verbose
}

<#
.SYNOPSIS
Create a new customizable template directory for Markdown to HTML conversion.

.DESCRIPTION
The factory-default conversion template is copied to the destination directory to
seed the customization process.

The custom template directory has following structure:

    <Template Root>
      +--- js           <-- Javascript libraries
      |
      +--- katex        <-- LaTex Math typesetting library
      |    +--- contrib
      |    '--- fonts
      '--- styles       <-- CSS style libraries.

## Default configuration
The factory-default template is configured in the following way
* Code syntax highlighting is enabled for following languages:
  * Bash
  * C#
  * C++
  * CSS
  * Diff
  * HTML/XML
  * HTTP
  * Java
  * JavaScript
  * Makefile
  * Markdown
  * SQL
  * Maxima
  * PowerShell
* Diagramming (`mermaid` extension) is pre-installed but deactivated.
* Math Typesetting (`mathematics` extension) is pre-installed but deactivated.

## The HTML template `md-template.html`

The HTML template file is used to turn the HTML fragments generated for each
Markdown file into standalone HTML documents which can be viewed in a web browser.

## Customizing `md-template.html`
The HTML template contains two placeholders which get replaced with
HTML content:
* `[title]` - Page title generated from the Markdown filename. **Note**: The title **cannot**
  be customized.
* `[content]` - HTML content. **Note**: It is possible to add additional html content to the
  `<body>` of the template, as long as this placeholder remains on its own line.

To customize styling the stylesheet `styles\md-styles.css` in the template derectory can be
modified or a new stylesheet can be added to the `styles` directory and included in
`md-template.html`.

## Configuring Factory Installed Extensions in `md-template.html`

* **Code syntax highlighting** uses the [highlight.js](https://highlightjs.org/)
  JavaScript library which supports 185 languages and 89 styles as well as
  automatic language detection. Code syntax highlighting by default is activated and
  configured for following languages:
  * Bash
  * C#
  * C++
  * Clojure
  * CMake
  * CSS
  * Diff
  * DOS .bat
  * F#
  * Groovy
  * HTML/XML
  * HTTP
  * Java
  * JavaScript
  * JSON
  * Lisp
  * Makefile
  * Markdown
  * Maxima
  * Python
  * PowerShell
  * SQL

  To obtain syntax highlighting for other/additional languages, please visit
  the [Getting highlight.js](https://highlightjs.org/download/) page and
  download a customized version of `highlight.js` configured for the languages
  you need.

  Code syntax highlighting is configured in the `<head>` section
  of `md-template.html` as shown below. By default the syntax highlighting style `vs.css`
  is used. Alternative styles can be enabled. Only one highlighting style should be enabled
  at a time. Additional styles can be downloaded from the
  [highlight.js styles](https://github.com/highlightjs/highlight.js/tree/master/src/styles)
  directory.
  Use the [demo](https://highlightjs.org/static/demo/) page to identify the styles
  you like best.

<blockquote>

~~~ html
<!-- Code syntax highlighting configuration -->
<!-- Comment this to deactivate syntax highlighting. -->
<link rel="stylesheet" type="text/css" href="styles/vs.css" />
<link rel="stylesheet" type="text/css" href="styles/vs.css" />
<!-- Alternative highlighting styles -->
<!-- <link rel="stylesheet" type="text/css" href="styles/agate.css" /> -->
<!-- <link rel="stylesheet" type="text/css" href="styles/far.css" /> -->
<!-- <link rel="stylesheet" type="text/css" href="styles/tomorrow-night-blue.css" /> -->
<script src="js/highlight.pack.js"></script>
<script>
    hljs.configure({ languages: [] });
    hljs.initHighlightingOnLoad();
</script>
<!-- -->
~~~

</blockquote>

* **Diagramming** uses the [mermaid](https://mermaidjs.github.io/) diagram
  and flowchart generator. Is activated by default and is configured in the
  `<head>` section of `md-template.html` like so:

<blockquote>

~~~ html
<!-- mermaid diagram generator configuration -->
<!-- Comment this to deactivate the diagramming extension ('diagrams'). -->
<script src="js/mermaid.min.js"></script>
<script>mermaid.initialize({startOnLoad:true});</script>
<!-- -->
~~~

</blockquote>

* **LaTeX Math Typesetting** is provided by the [KaTeX](https://katex.org/) LaTeX Math
  typesetting library. Is activated by default and is configured in the
  `<head>` section of `md-template.html` like so:

<blockquote>

~~~ html
<!-- KaTex LaTex Math typesetting configuration -->
<!-- Comment this to deactivate the LaTey math extension ('mathematics'). -->
<link rel="stylesheet" type="text/css" href="katex/katex.min.css" />
<script defer src="katex/katex.min.js"></script>
<script>
  window.onload = function() {
      var tex = document.getElementsByClassName("math");
      Array.prototype.forEach.call(tex, function(el) {
          katex.render(el.textContent, el);
      });
  };
</script>
<!-- -->
~~~

</blockquote>

## Configuring Other parsing extensions
Unless pre-installed in the default factory template, some parsing extensions may require
additional local resources and configuration.

Configuration is typically achieved by adding style sheets and javascript code to the `<head>` or `<body>`
section of the HTML template. Local Resources can be added anywhere to the template directory, but usually
javascript libraries are added to the the `js` directory of the template
and stylesheets are added to the `styles` directory. To obtain resources and installation instructions
for individual parsing extensions, visit the documentation of the extensions.
See [Convert-MarkdownToHTMLDocument](Convert-MarkdownToHTMLDocument.md) for links.

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
Convert-MarkdownToHTML
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
    ## Copy the template to the output directory

    $outdir = Get-Item -LiteralPath $Destination -ErrorAction:SilentlyContinue

    if ($outdir -eq $null) {
        $outdir = New-Item -Path $Destination -ItemType Directory -ErrorAction:SilentlyContinue
    }

    if ($outdir -eq $null -or $outdir -isnot [System.IO.DirectoryInfo]) {
        throw("Unable to create directory $Destination")
    }
    Copy-Item -Path "${template}/*" -Recurse -Destination $outDir
    $outDir
}
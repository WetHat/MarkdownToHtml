[System.IO.DirectoryInfo]$SCRIPT:moduleDir = Split-Path -Parent $MyInvocation.MyCommand.Path

[string[]]$SCRIPT:defaultMarkdownExtensions = @(
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

filter Expand-HtmlTemplate (
	                         [parameter(Mandatory=$false,ValueFromPipeline=$true)]
							 [string]$Template = "",
	                         [parameter(Mandatory=$true,ValueFromPipeline=$false)]
	                         [string]$Title,
	                         [parameter(Mandatory=$true,ValueFromPipeline=$false)]
	                         [ValidateNotNullOrEmpty()]
	                         [string]$Content,
	                         [parameter(Mandatory=$false,ValueFromPipeline=$false)]
	                         [string]$RelativePath = ''
                            )
{
   if ($Template -match '^\s*<title>\[title\]</title>\s*$') {
		Write-Output "<title>$Title</title>"
	} elseif ($Template -match '^\s*\[content\]\s*$') {
		([Regex]::Split($Content,'(<code[^>]*>|</code>)') `
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
							[Regex]::Split($_,'(?<=<a [^>]*)(href="[^"]*")') `
							| ForEach-Object {
								if ($_ -match '^href=".*"' -and $_ -notmatch '^href="https?://') {
								    $_ -replace '(.md|.markdown)(?=["#])','.html'
							    } else {
									$_
								}
						      }
						}
				     })  -Join '' # join to make HTML look nice
	} elseif (![string]::IsNullOrWhiteSpace($RelativePath)) {
		## fixup relative pathes in the template
		$Template -replace '(?<=(href|src)=")(?=[^/][^:"]+")',$RelativePath
	} else {
		$Template
	}
}

function Convert-MarkdownToHTMLDocument (
										  [parameter(Mandatory=$true,ValueFromPipeline=$true)]
										  [ValidateNotNull()]
										  [System.IO.FileInfo]$Markdown,
										  [parameter(Mandatory=$true,ValueFromPipeline=$false)]
										  [ValidateNotNull()]
										  [System.IO.FileInfo]$Template,
	                                      [parameter(Mandatory=$false,ValueFromPipeline=$false)]
										  [string[]]$IncludeExtension = @('advanced'),
										  [parameter(Mandatory=$false,ValueFromPipeline=$false)]
										  [string[]]$ExcludeExtension = @(),
	                                      [parameter(Mandatory=$true,ValueFromPipeline=$false)]
										  [ValidateNotNull()]
										  [System.IO.DirectoryInfo]$Destination
									   )
{
  Begin {
    ## Determine which parser extensions to use
	if ($IncludeExtension -eq $null -or $IncludeExtension.Count -eq 0) {
		$extensions = @('common') # use _common_ extensions by default
	} elseif ('advanced' -in $IncludeExtension) {
		if ($ExcludeExtension.Count -gt 0) {
		   $IncludeExtension = $IncludeExtension | Where-Object { $_ -ne 'advanced'}
		   ## add the extensions explicitely so that we can remove individual ones
		   $IncludeExtension += $SCRIPT:defaultMarkdownExtensions
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

	$IncludeExtension = $IncludeExtension | Where-Object { $_ -notin $ExcludeExtension}

	## configure the converter pipeline
	[Markdig.MarkdownPipelineBuilder]$pipelineBuilder = (New-Object Markdig.MarkdownPipelineBuilder)
	Write-Verbose "Using parser extensions $IncludeExtension"
	$pipelineBuilder = [Markdig.MarkDownExtensions]::Configure($pipelineBuilder,[string]::Join('+',$IncludeExtension))

    $pipeline = $pipelineBuilder.Build()

	## Load the template.
	[string[]]$htmlTemplate = @(get-content -LiteralPath $Template.FullName -Encoding UTF8)
  }
  Process {
	## slurp the markdown
	[string]$md = Get-Content -LiteralPath $Markdown.FullName -Encoding UTF8 | Out-String
	[string]$fragment = [Markdig.Markdown]::ToHtml($md, $pipeline)
	[string]$title = $Markdown.BaseName # for now, title is just the filename.
	[System.IO.FileInfo]$html = Join-Path $Destination.FullName "$($Markdown.RelativePath)/$($Markdown.BaseName).html"

	$relativePath = ''
	foreach ($segment in $Markdown.RelativePath -split '[\/]+') {
		if (![string]::IsNullOrWhiteSpace($segment)) {
			$relativePath += '../'
		}
	}

	$htmlTemplate | Expand-HtmlTemplate -Title        $title `
	                                    -Content      $fragment `
	                                    -RelativePath $relativePath `
	              | Out-File -LiteralPath $html.FullName -Encoding utf8
	$html
  }
}

<#
.SYNOPSIS
Convert Markdown files into HTML files.

.DESCRIPTION
This function reads all markdown files from a source folder and converts each of them to
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
Path to markdown files or directories containing markdown files.

.PARAMETER Template
Optional directory containing the html template file `md-template.html` and its resources.
If no template directory is specified, a default factory-installed template is used.
For infomations about creating custom templates see [New-HTMLTemplate](New-HTMLTemplate.md).

.PARAMETER IncludeExtension
Comma separated list of markdown parsing extensions to use.

.PARAMETER ExcludeExtension
Comma separated list of markdown parsing extensions to exclude.
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

Convert all markdown files in `E:\MyMarkdownFiles` and save the generated HTML files
in `E:\MyHTMLFiles`

.EXAMPLE
Convert-MarkdownToHTML -Markdown 'E:\MyMarkdownFiles' -Template 'E:\MyTemplate' -Destination 'E:\MyHTMLFiles'

Convert all markdown files in `E:\MyMarkdownFiles` using
* the 'common' parsing configuration
* the custom template in `E:\MyTemplate`

The generated HTML files are saved to `E:\MyHTMLFiles`.

.EXAMPLE
Convert-MarkdownToHTML -Markdown 'E:\MyMarkdownFiles' -Destination 'E:\MyHTMLFiles' -IncludeExtension 'advanced','diagrams'

Convert all markdown files in `E:\MyMarkdownFiles` using
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
            [string]$Template,
	        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
            [string[]]$IncludeExtension = @('common'),
	        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
            [string[]]$ExcludeExtension = @(),
	        [parameter(Mandatory=$true,ValueFromPipeline=$false)]
            [ValidateNotNullorEmpty()]
	        [string]$Destination
        )
	# Determine which template to use
	if (![string]::IsNullOrWhiteSpace($Template) -and (Test-Path $Template -PathType Container)) {
		Write-Verbose "Using HTML template '$Template'."
	} else {
		Write-Verbose 'Using default HTML template.'
		$Template = Join-Path $SCRIPT:moduleDir.FullName 'Template'
	}
	[string]$htmlTemplate = Join-Path $Template 'md-template.html'

	## Create the output directory
	$outdir = Get-Item -LiteralPath $Destination -ErrorAction:SilentlyContinue

	if ($outdir -eq $null) {
		$outdir = New-Item -Path $Destination -ItemType Directory -ErrorAction:SilentlyContinue
	}

	if ($outdir -eq $null -or $outdir -isnot [System.IO.DirectoryInfo]) {
		throw("Unable to create directory $Destination")
    }

	## Copy the template file to the output directory
	Copy-Item -Path "$Template/*" -Recurse -Exclude 'md-template.html' -Destination $Destination -Force

	## Generate the html files in the destination by expanding the templates
	Get-Item -Path $Path `
	| ForEach-Object {
		if ($_ -is [System.IO.DirectoryInfo]) {
			$baseDir = $_
			[string]$basePath = $baseDir.FullName.TrimEnd('/\')
            ## Copy markdown resources to the output directory
	        Copy-Item -Path "${basePath}/*" -Recurse -Exclude '*.md','*.markdown' -Destination $Destination -Force

			Write-Verbose "Processing $($baseDir.Name)"
			Get-ChildItem -Path $basePath -Recurse -File -Include '*.md','*.markdown' `
			| ForEach-Object {
		        ## capture the relative path of the markdown file
				[string]$relativePath = $_.DirectoryName.Substring($basePath.Length).Trim('/\')
		        Add-Member -InputObject $_ -MemberType NoteProperty -Name 'RelativePath' -Value $relativePath
		        $_
	          }
		} elseif ($_.Extension -in '.md','.markdown') {
			$_ # single file
		}
	  } `
	| Convert-MarkdownToHTMLDocument -Template (get-Item -LiteralPath $htmlTemplate) `
	                                 -IncludeExtension $IncludeExtension `
	                                 -ExcludeExtension $ExcludeExtension `
	                                 -Destination $outdir
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
markdown file into standalone HTML documents which can be viewed in a web browser.

## Customizing `md-template.html`
The HTML template contains two placeholders which get replaced with
HTML content:
* `[title]` - Page title generated from the markdown filename. **Note**: The title **cannot**
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
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
	                         [parameter(Mandatory=$true,ValueFromPipeline=$true)]
							 [string]$Template,
	                         [parameter(Mandatory=$true,ValueFromPipeline=$false)]
	                         [string]$Title,
	                         [ValidateNotNullOrEmpty()]
	                         [string]$Content
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
							[System.Web.HttpUtility]::HtmlEncode([System.Web.HttpUtility]::HtmlDecode($_))
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
	} else {
		Write-Output $Template
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
		$extensions = @('common')
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
	Write-Host -ForegroundColor Yellow "Using parser extensions $IncludeExtension"
	$pipelineBuilder = [Markdig.MarkDownExtensions]::Configure($pipelineBuilder,[string]::Join('+',$IncludeExtension))

    $pipeline = $pipelineBuilder.Build()

	## Load the template Location
	[string[]]$htmlTemplate = @(get-content -LiteralPath $Template.FullName -Encoding UTF8)
  }
  Process {
	## slurp the template
	[string]$md = Get-Content -LiteralPath $Markdown.FullName -Encoding UTF8 | Out-String
	[string]$fragment = [Markdig.Markdown]::ToHtml($md, $pipeline)
	[string]$title = $Markdown.BaseName
	[System.IO.FileInfo]$html = Join-Path $Destination.FullName "$($Markdown.RelativePath)/$($Markdown.BaseName).html"
	$htmlTemplate | Expand-HtmlTemplate -Title $title -Content $fragment `
	              | Out-File -LiteralPath $html.FullName -Encoding utf8
	$html
  }
}

<#
.SYNOPSIS
Convert Markdown files into HTML files.

.DESCRIPTION
This function reads all markdown files from a source folder and converts them to
standalone html documents using customizeable parser configurations and templates.

A template is a directory containing:

* a html template file named `md-template.html`
* resources used in the html template files such as:
  * images
  * stylesheets (css)
  * JavaScripts

Custom templates can be easily generated by [New-HTMLTemplate](New-HTMLTemplate.md).

A parser configuration is a comma separated list of configuration option strings. Currently
avaliable options are:

* "abbreviations": [Abbreviations ](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/AbbreviationSpecs.md)
* "advanced": advanced parser configuration. A pre-build collection of parsing option strings
* "attributes": [Special attributes](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/GenericAttributesSpecs.md) or attached HTML attributes.
* "autoidentifiers": [Auto-identifiers](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/AutoIdentifierSpecs.md) for headings
* "autolinks": [Auto-links](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/AutoLinks.md) generates links if a text starts with `http://` or `https://` or `ftp://` or `mailto:` or `www.xxx.yyy`
* "bootstrap": [Bootstrap](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/BootstrapSpecs.md) class (to output bootstrap class)
* "citations": [Citation text](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FigureFooterAndCiteSpecs.md) by enclosing `""...""`
* "common": CommonMark parsing; no parser extensions (default)
* "customcontainers": [Custom containers](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/CustomContainerSpecs.md) similar to fenced code block `:::` for generating a proper `<div>...</div>`  instead
* "definitionlists": [Definition lists](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/DefinitionListSpecs.md)
* "diagrams": [Diagrams](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/DiagramsSpecs.md)  extension whenever a fenced code block contains a special keyword, it will be converted to a div block with the content as-is (currently, supports `mermaid` and `nomnoml` diagrams)
* "emojis": [Emoji](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/EmojiSpecs.md) support
* "emphasisextras": [Extra emphasis](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/EmphasisExtraSpecs.md)
* "figures": [Figures ](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FigureFooterAndCiteSpecs.md)
* "footers": [Footers](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FigureFooterAndCiteSpecs.md)
* "footnotes": [Footnotes](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FootnotesSpecs.md)
* "gridtables": [Grid tables](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/GridTableSpecs.md)
* "hardlinebreak": [Soft lines](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/HardlineBreakSpecs.md) as hard lines
* "listextras": [Extra bullet lists](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/ListExtraSpecs.md), supporting alpha bullet a. b. and roman bullet (i, ii...etc.)
* "mathematics": [Mathematics](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/MathSpecs.md)/Latex extension by enclosing `$$` for block and `$` for inline math
* "medialinks": [Media support](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/MediaSpecs.md) for media url (youtube, vimeo, mp4...etc.)
* "nofollowlinks":
* "nohtml":
* "nonascii-noescape":
* "pipetables": [Pipe tables](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/PipeTableSpecs.md)
* "smartypants": [SmartyPants](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/SmartyPantsSpecs.md)
* "tasklists": [Task Lists](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/TaskListSpecs.md)
* "yaml": [YAML frontmatter](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/YamlSpecs.md) to parse without evaluating the frontmatter and to discard it from the HTML output (typically used for previewing without the frontmatter in MarkdownEditor)

.PARAMETER Path
Path to markdown files or directories containing markdown files.

.PARAMETER Template
Optional directory containing the html template file `md-template.html` and its resources.
If no template directory is specified, a default template is used.

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
Convert-MarkdownToHTML -Markdown 'E:\MyMarkdownFiles' -Destination 'E:\MyHTMLFiles' -IncludeExtension 'advanced'

Convert all markdown files in `E:\MyMarkdownFiles` using
* the 'advanced' parsing configuration
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
New-HTMLTemplate
#>
function Convert-MarkdownToHTML (
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
{
	if (![string]::IsNullOrWhiteSpace($Template) -and (Test-Path $Template -PathType Container)) {
		Write-Host -ForegroundColor Yellow "Using HTML template '$Template'."
	} else {
		Write-Host -ForegroundColor Yellow 'Using default HTML template.'
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
            ## Copy markdown resources to the output directory
	        Copy-Item -Path "$($baseDir.FullName)/*" -Recurse -Exclude '*.md','*.markdown' -Destination $Destination -Force

			Write-Host -ForegroundColor Yellow "Processing $($baseDir.Name)"
			Get-ChildItem -Path "$($baseDir.FullName)/*" -Recurse -File -Include '*.md','*.markdown' `
			| ForEach-Object {
		        ## capture the relative path of the markdown file
		        Add-Member -InputObject $_ -MemberType NoteProperty -Name 'RelativePath' -Value $_.DirectoryName.Substring($baseDir.FullName.TrimEnd("/\").Length)
		        $_
	          }
		} elseif ($_.Extension -in '.md','.markdown') {
			$_
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
The default conversion template is copied to the destination directory to
seed the creation of a custom template.

Typically following files are customized:

* `styles\md-styles.css`: html styling
* `md-template.html`: Html template file. Used for creating standalone HTML files
  from HTML fragments. A html template typically has a structure like shown in the example below.
  There are two placeholders which get replaced by help content:
  * [title] - Page title generated from the markdown filename.
  * [content] - Help content. **Note**: This placeholder must be the only text on the line.

<blockquote>

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>[title]</title>
    <link rel="stylesheet" type="text/css" href="styles/md-styles.css" />
    <link rel="stylesheet" type="text/css" href="styles/vs.css" />
    <script src="js/highlight.pack.js"></script>
    <script>
        hljs.configure({ languages: [] });
        hljs.initHighlightingOnLoad();
    </script>
</head>
<body>
    [content]
</body>
</html>
```
</blockquote>

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
function New-HTMLTemplate (
	                        [parameter(Mandatory=$true,ValueFromPipeline=$false)]
                            [ValidateNotNullorEmpty()]
	                        [string]$Destination
                          )
{
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
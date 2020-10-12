# Convert-MarkdownToHTML

Convert Markdown files into HTML files.

# Syntax
```PowerShell
 Convert-MarkdownToHTML [-Path] <String> [-Template] <String> [-IncludeExtension] <String[]> [-ExcludeExtension] <String[]> [-MediaDirectory] <String> [-SiteDirectory] <String>  [<CommonParameters>] 
```


# Description


This function reads all Markdown files from a source folder and converts each
of them to standalone html documents using configurable Markdown extensions and
a customizable HTML template. See [`about_MarkdownToHTML`](about_MarkdownToHTML.md) for a list of
supported extensions and customization options.





# Parameters

<blockquote>



## -Path \<String\>

<blockquote>

Path to Markdown files or directories containing Markdown files.

Parameter Property         | Value
--------------------------:|:----------
Required?                  | true
Position?                  | 1
Default value              | ``
Accept pipeline input?     | false
Accept wildcard characters?| true

</blockquote>
 

## -Template \<String\>

<blockquote>

Optional directory containing the html template file `md-template.html` and its resources.
If no template directory is specified, a default factory-installed template is used.
For infomations about creating custom templates see [`New-HTMLTemplate`](New-HTMLTemplate.md).

Parameter Property         | Value
--------------------------:|:----------
Required?                  | false
Position?                  | 2
Default value              | `(Join-Path $SCRIPT:moduleDir.FullName 'Template')`
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>
 

## -IncludeExtension \<String[]\>

<blockquote>

Comma separated list of Markdown parsing extensions to use (see notes for available extensions).

Parameter Property         | Value
--------------------------:|:----------
Required?                  | false
Position?                  | 3
Default value              | `@('common')`
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>
 

## -ExcludeExtension \<String[]\>

<blockquote>

Comma separated list of Markdown parsing extensions to exclude.
Mostly used when the the 'advanced' parsing option is included and
certain individual options need to be removed,

Parameter Property         | Value
--------------------------:|:----------
Required?                  | false
Position?                  | 4
Default value              | `@()`
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>
 

## -MediaDirectory \<String\>

<blockquote>

An optional directory containing additional media for the Html site
such as images, videos etc. Defaults to the directory given in `-Path`

Parameter Property         | Value
--------------------------:|:----------
Required?                  | false
Position?                  | 5
Default value              | `$Path`
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>
 

## -SiteDirectory \<String\>

<blockquote>

Directory for the generated HTML files. The Html files will be placed
in the same relative location below this directory as related Markdown document
has below the Markdown source directory.

Parameter Property         | Value
--------------------------:|:----------
Required?                  | true
Position?                  | 6
Default value              | ``
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>


</blockquote>


# Inputs
This function does not read from the pipe.


# Outputs
File objects `[System.IO.FileInfo]` of the generated HTML files.

# Notes

<blockquote>

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

</blockquote>

# Examples

<blockquote>


## EXAMPLE 1

```PowerShell
Convert-MarkdownToHTML -Path 'E:\MyMarkdownFiles' -SiteDirectory 'E:\MyHTMLFiles'
```


Convert all Markdown files in `E:\MyMarkdownFiles` and save the generated HTML files
in `E:\MyHTMLFiles`











 
## EXAMPLE 2

```PowerShell
Convert-MarkdownToHTML -Path 'E:\MyMarkdownFiles' -Template 'E:\MyTemplate' -SiteDirectory 'E:\MyHTMLFiles'
```


Convert all Markdown files in `E:\MyMarkdownFiles` using
* the 'common' parsing configuration
* the custom template in `E:\MyTemplate`

The generated HTML files are saved to `E:\MyHTMLFiles`.











 
## EXAMPLE 3

```PowerShell
Convert-MarkdownToHTML -Path 'E:\MyMarkdownFiles' -SiteDirectory 'E:\MyHTMLFiles' -IncludeExtension 'advanced','diagrams'
```


Convert all Markdown files in `E:\MyMarkdownFiles` using
* the 'advanced' and 'diagrams' parsing extension.
* the default template

The generated HTML files are saved to `E:\MyHTMLFiles`.











 
## EXAMPLE 4

```PowerShell
Convert-MarkdownToHTML -Path 'E:\MyMarkdownFiles' -MediaDirectory 'e:\Media' -SiteDirectory 'E:\MyHTMLFiles' -IncludeExtension 'advanced','diagrams'
```


Convert all Markdown files in `E:\MyMarkdownFiles` using
* the 'advanced' and 'diagrams' parsing extension.
* the default template
* Media files (images, Videos, etc.) from the directory `e:\Media`

The generated HTML files are saved to `E:\MyHTMLFiles`.













</blockquote>

# Related Links

* [https://github.com/WetHat/MarkdownToHtml/blob/master/Documentation/Convert-MarkdownToHTML.md](https://github.com/WetHat/MarkdownToHtml/blob/master/Documentation/Convert-MarkdownToHTML.md) 
* [https://github.com/lunet-io/markdig](https://github.com/lunet-io/markdig) 
* [http://commonmark.org/](http://commonmark.org/) 
* [https://highlightjs.org/](https://highlightjs.org/) 
* [https://mermaidjs.github.io/](https://mermaidjs.github.io/) 
* [https://katex.org/](https://katex.org/) 
* [`Find-MarkdownFiles`](Find-MarkdownFiles.md) 
* [`Convert-MarkdownToHtmlFragment`](Convert-MarkdownToHtmlFragment.md) 
* [`Publish-StaticHtmlSite`](Publish-StaticHtmlSite.md) 
* [`New-HTMLTemplate`](New-HTMLTemplate.md)

---

<cite>Module: MarkdownToHtml; Version: 2.2.2; (c) 2018-2020 WetHat Lab. All rights reserved.</cite>

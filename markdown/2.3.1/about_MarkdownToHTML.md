# Topic
about_MarkdownToHTML

# Short Description
Highly configurable Markdown to HTML conversion using customizable templates.

* Open Source and fully _hackable_.
* Out-of-the box support for diagrams, math typesetting and code syntax
  highlighting.
* Based on [Markdig](https://github.com/lunet-io/markdig),
  a fast, powerful, [CommonMark](http://commonmark.org/) compliant Markdown
  processor for .NET with more than 20 configurable extensions.
* High quality Open Source web components:
  - **Code Highlighting**: [highlight.js](https://highlightjs.org/); supports
    189 languages and 91 styles.
  - **Math typesetting**: [KaTeX](https://katex.org/); The fastest math
    typesetting library for the web.
  - **Diagramming**: [Mermaid](http://mermaid-js.github.io/mermaid/); Generation
    of diagrams and flowcharts from text in a similar manner as Markdown.
* Highly configurable static website projects with configuration file and build
  script. See [`New-StaticHTMLSiteProject`](New-StaticHTMLSiteProject.md).
* Sites can be used offline (without connection to the internet). All site
  assets are local.

## Prerequisites

> To successfully create web sites from Markdown you should:
> * know Markdown. A good starting point would be
>   [GitHub Flavored Markdown](https://github.github.com/gfm/)
> * have some knowledge about HTML and CSS (Cascading Stylesheets)
> * be familiar with [JSON](https://www.tutorialspoint.com/json/json_overview.htm)
>   configuration files.
> * have some [_PowerShell_](https://www.tutorialspoint.com/powershell/index.htm)
>  knowledge in case you want to customize the build script `Build.ps1`.

# Typical Use Cases
This module supports a range of workflows involving conversion of Markdown
text to HTML. The most common uses cases are outlined below.

## Converting Markdown files to HTML files

> The conversion setup in the context of this use case is typically based
> on [`Convert-MarkdownToHtml`](Convert-MarkdownToHtml.md). This function picks up Markdown files
> and their resources (e.g images) from a source directory and outputs
> HTML files to a destination directory as shown below:
>
> ~~~ PowerShell
> PS> Convert-MarkdownToHTML -Path '<directory with markdown files>' -SiteDirectory '<html site directory>' -IncludeExtension 'advanced'
> ~~~
>
> Local Links in the Markdown files are rewired to point to the corresponding
> HTML files.

## Static HTML Site Authoring Projects

> Static HTML site projects can be easily bootstrapped with the
> [`New-StaticHTMLSiteProject`](New-StaticHTMLSiteProject.md) function.
>
> ~~~ PowerShell
> PS> New-StaticHTMLSiteProject -ProjectDirectory 'MyProject'
> PS> cd 'MyProject'
> PS> ./Build.ps1
> ~~~
> The code snippet above generates a fully functional static HTML site
> with a README.html file showcasing some features and further tips
> on authoring the static site,.
>
> Static site authoring projects have a project configuration
> file `Build.json`, a customizable template, and a
> customizable converter pipeline located in the build script `Build.ps1`.
>
> ~~~
>                  Directory
>                     |
>                     v
>         .-----------'------------.
> 1       |  Markdown File Scanner |
>         '-----------.------------'
>                     |
>                Markdown files
>                     |
>        .------------'-------------.
> 2      | HTML Fragment Conversion |
>        '------------.-------------'
>                     |
>        .------------'-------------.    .- Template
> 3      | HTML Document Assembler  | <--+
>        '------------.-------------'    '- Content Map
>                     |
>                     v
>           standalone HTML Documents
> ~~~
>
> The PowerShell functions associated with the pipeline stages are:
>
> 1. [`Find-MarkdownFiles`](Find-MarkdownFiles.md)
> 2. [`Convert-MarkdownToHTMLFragment`](Convert-MarkdownToHTMLFragment.md)
> 3. [`Publish-StaticHtmlSite`](Publish-StaticHtmlSite.md)
>
> See the [customization](#customization) section for more details.

# Markdown Extensions
The [Markdig](https://github.com/lunet-io/markdig) Markdown converter can be
configured to parse extended Markdown syntax. Below is a list of
supported extensions which can be used in [`Convert-MarkdownToHTML`](Convert-MarkdownToHTML.md) or
[`Convert-MarkdownToHTMLFragment`](Convert-MarkdownToHTMLFragment.md).

**Note**: The 'mathematics' and 'diagramming' extensions require additional
configuration in the HTML template (`md-template.html`).
Refer to the [`New-HTMLTemplate`](New-HTMLTemplate.md) for customization details.

`abbreviations`
:   [Abbreviations](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/AbbreviationSpecs.md)

`advanced`
:   advanced parser configuration. A pre-build collection of extensions including:
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

`attributes`
:   [Special attributes](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/GenericAttributesSpecs.md).
    Set HTML attributes (e.g `id` or class`).

`autoidentifiers`
:    [Auto-identifiers](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/AutoIdentifierSpecs.md).
     Automatically creates an identifiers attributes (id) for headings.

`autolinks`
:   [Auto-links](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/AutoLinks.md)
    generates links if a text starts with `http://` or `https://` or `ftp://` or `mailto:` or `www.xxx.yyy`.

`bootstrap`
:   [Bootstrap](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/BootstrapSpecs.md)
    to output bootstrap classes.

`citations`
:   [Citation text](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FigureFooterAndCiteSpecs.md)
    by enclosing text with `''...''`

`common`
:   CommonMark parsing; no parser extensions (default)

`customcontainers`
:   [Custom containers](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/CustomContainerSpecs.md)
    similar to fenced code block `:::` for generating a proper `<div>...</div>` instead.

`definitionlists`
:   [Definition lists](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/DefinitionListSpecs.md)

`diagrams`
:   [Diagrams](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/DiagramsSpecs.md)
    whenever a fenced code block uses the 'mermaid' keyword, it will be converted to a div block with the content as-is
    (currently, supports `mermaid` and `nomnoml` diagrams). Resources for the `mermaid` diagram generator are pre-installed and configured.
    See [New-HTMLTemplate](New-HTMLTemplate.md) for customization details.

`emojis`
:   [Emoji](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/EmojiSpecs.md) support.

`emphasisextras`
:   [Extra emphasis](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/EmphasisExtraSpecs.md)
    markup.

    * strike through `~~`
    * Subscript `~`
    * Superscript `^`
    * Inserted `++`
    * Marked `==`

`figures`
:   [Figures](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FigureFooterAndCiteSpecs.md).
    A figure can be defined by using a pattern equivalent to a fenced code block but with the character `^`.

`footers`
:   [Footers](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FigureFooterAndCiteSpecs.md).

`footnotes`
:   [Footnotes](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FootnotesSpecs.md)

[`gfm-pipetables`](gfm-pipetables.md)
:   [Pipe tables](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/PipeTableSpecs.md)
    to generate tables from markup. Gfm pipe tables using header for column count

`globalization`
:   [Globalization](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/GlobalizationSpecs.md).
    Adds support for RTL (Right To Left) content by adding `dir="rtl"` and `align="right"` attributes to
    the appropriate html elements. Left to right text is not affected by this extension.

`gridtables`
:   [Grid tables](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/GridTableSpecs.md)
    allow to have multiple lines per cells and allows to span cells over multiple columns.

`hardlinebreak`
:   [Hard Linebreak](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/HardlineBreakSpecs.md)
    a new line in a paragraph block will result in a hardline break `<br/>`:

`listextras`
:   Extra bullet lists](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/ListExtraSpecs.md),
    supporting alpha bullet a. b. and roman bullet (i, ii...etc.)

`mathematics`
:   [Mathematics](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/MathSpecs.md)
    LaTeX extension by enclosing `$$` for block and `$` for inline math. Resources for this extension are pre-installed and configured.
    See [`New-HTMLTemplate`](New-HTMLTemplate.md) for customization details.

`medialinks`
:   [Media support](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/MediaSpecs.md)
    for media urls (youtube, vimeo, mp4...etc.).

`nofollowlinks`
:   Add `rel=nofollow` to all links rendered to HTML.

`nohtml`
:   [NoHTML](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/NoHtmlSpecs.md)
    allows to disable the parsing of HTML.

[`nonascii-noescape`](nonascii-noescape.md)
:   Use this extension to disable URI escape with % characters for non-US-ASCII characters in order to
    workaround a bug under IE/Edge with local file links containing non US-ASCII chars. DO NOT USE OTHERWISE.

`noopenerlinks`
:   Add `rel=noopener` to all links rendered to HTML effectively telling
    the browser to open a link in a new tab without providing the context access to the webpage that
    opened the link.

`noreferrerlinks`
:   Add `rel=noreferrer` to all links rendered to HTML preventing the browser, when you navigate to
    another page, to send the referring webpage�s address.

`pipetables`
:   [Pipe tables](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/PipeTableSpecs.md)
    to generate tables from markup.

`smartypants`
:   [SmartyPants](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/SmartyPantsSpecs.md)
    quotes.

`tasklists`
:   [Task Lists](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/TaskListSpecs.md).
  A task list item consist of `[ ]` or `[x]` or `[X]` inside a list item (ordered or unordered)

`yaml`
:   [YAML frontmatter](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/YamlSpecs.md)
    parsing.

# Default Conversion Templates

The module provides templates for custom conversion projects based on the
[`Convert-MarkdownToHTML`](Convert-MarkdownToHTML.md) and for static site authoring projects generated by
[`New-StaticHTMLSiteProject`](New-StaticHTMLSiteProject.md).

The template directory structure is the same in both cases
and the factory configuration is almost identical.

The common factory-default configuration of a new template is as follows.

Syntax Highlighting
:   Pre-installed and configured languages:
    - Bash
    - C#
    - C++
    - Clojure
    - CMake
    - CSS
    - Diff
    - DOS .bat
    - F#
    - Groovy
    - HTML/XML
    - HTTP
    - Java
    - JavaScript
    - JSON
    - Lisp
    - Makefile
    - Markdown
    - Maxima
    - Perl
    - Python
    - PowerShell
    - SQL
    - YAML

    To obtain syntax highlighting for other/additional languages, please visit
    the [Getting highlight.js](https://highlightjs.org/download/) page and
    get a customized version of `highlight.js` configured for the languages
    you need.

Diagramming
:   The 'mermaid' extension is activated and its resources are pre-installed.

Math Typesetting
:   The 'mathematics' extension is activated and its resources are pre-installed.

# Conversion Template Customization
For many cases the module provides reasonable default templates so that
first results can be achieved quickly and easily. However, if the
conversion process is to be embedded in a larger process or workflow,
structure and appearance of the generated HTML files need to be adjusted.

Simple Markdown to HTML conversions and static site projects are based
on very similar conversion templates. These templates
reside in a directories with the following structure:

~~~
<root>                 <- template root directory
   |- js               <- javascripts (*.js)
   |- katex            <- LateX math renderer
   |- styles           <- stylesheets (*.css)
   '- md-template.html <- Html page template
~~~

`md-template.html`
:   The HTML template file
    * defines the overall layout of the generated HTML files
    * has placeholders for content injection.
    * loads all JavaScript and stylesheet resources
      to render the final HTML page in the desired way.

    The placeholders on the page are enclosed in double
    curly brackets, e.g. `{{foo}}`. The command [`Publish-StaticHtmlSite`](Publish-StaticHtmlSite.md)
    located these placeholders on the template page and replaces them
    with page content. This replacement step takes place for simple
    conversion projects based on the [`Convert-MarkdownToHTML`](Convert-MarkdownToHTML.md) command
    and also with static site projects.
    By default following placeholders are defined:

    `{{title}}`
    :   Placeholder for a page title generated from the Markdown content
        or filename.

    `{{content}}`
    :   Placeholder for the HTML content fragment generated from Markdown
        content.

    For static HTML site projects following additional placeholders are
    defined on `md-template.html` :

    `{{nav}}`
    :   Placehoder which is replaced by a HTML content fragment
        defining a navigatation sidebar on each page.

    `{{footer}}`
    :   Placeholder which is replaced by a HTML content fragment
        defining the page footer.

    For static HTML site projects additional
    [custom placeholders](#content-map-Customization) can be added.

The `js` directory
:   Initially contains JavaScript resources to support
    extensions such as code syntax highlighting or diagramming.
    JavaScript files can be added or removed as needed.

The `katex` directory
:   Contains the support files for LaTeX math rendering. It
    can be removed if this functionality is not needed.

The `styles` directory
:   Contains style sheets. The file `md-styles.css` contains the default
    styles. The other style sheets support other feature such as
    code systax highlighting.

    Usually style customization of the HTML pages is achieved by editing
    `md-styles.css`. However, other `*.css` files can be added as needed.

# Customizing Static Html Site Projects

## Content Map Customization

> When a custom placeholders was added to `md-template.html` it needs to
> be replaced by a HTML fragment in the project's build process.
> This can be done by adding an entry to the content map defined
> in `Build.ps1`. For example:
>
> ~~~ Powershell
> SCRIPT:contentMap = @{
>
> '{{my_placeholder}}' = '<b>Hello</b>'
> '{{footer}}' =  $config.Footer # Footer text from configuration
>
> ...
> }
> ~~~
>
> The code in the example above will replace all occurenced of
> `{{my_placeholder}}` in `md-template.html` with the HTML fragment
> `<b>Hello</b>`.
>
> The replacement value for a placeholders can be dynamically computed. To
> do this a script block can be assigned.
>
> The script block must take **one** parameter to which an object is bound
> which has these properties:
>
> | Property       | Description                                                     |
> | :------------: | :-------------------------------------------------------------- |
> | `Title`        | Optional page title. The first heading in the Markdown content. |
> | `HtmlFragment` | The HTML fragment string generated from the Markdown text.      |
> | `RelativePath` | Passed through form the input object, provided it exists.       |
>
> It is called once for each HTML fragment and should return one or more
> strings which define the substitution value for each page.
>
> Script Block example:
>
> ~~~ PowerShell
> {
>   param($Input)
>   "Source = $($Input.RelativePath)"
> }
> ~~~
>
> This script block would subsitute the path of the HTML document relative
> to the site root for every occurence of '{{my_placeholder}}'.

# Keywords
Markdown HTML static sites Conversion

# Other Markdown Site Generators
* [MkDocs](https://www.mkdocs.org/) - A fast and simple static site generator
  that is geared towards building project documentation.
  Documentation source files are written in Markdown, and configured with a
  single YAML configuration file.


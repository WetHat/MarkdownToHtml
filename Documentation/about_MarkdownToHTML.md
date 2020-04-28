# Topic
about_MarkdownToHTML | Resolve-Links)

# Short_Description
Highly configurable markdown to HTML conversion using customizable templates. | Resolve-Links)

Based on [Markdig](https://github.com/lunet-io/markdig), a fast, powerful, | Resolve-Links)
[CommonMark](http://commonmark.org/) compliant, extensible Markdown | Resolve-Links)
processor for .NET. | Resolve-Links)

This version is incompatible with existing conversion projects | Resolve-Links)
which use the 'mathematics' extensions and were created with versions of | Resolve-Links)
this module older than 2.0.0 (i.e. 1.* or 0.*). | Resolve-Links)

Make sure to read the INCOMPATIBILITIES section below about options for | Resolve-Links)
upgrading existing conversion projects. | Resolve-Links)

# Long Description
A typical use case is to ad-hoc convert a bunch of Markdown files in a | Resolve-Links)
directory to a static Html site using `Convert-MarkdownToHtml`. This uses | Resolve-Links)
a simple, built-in HTML conversion template. | Resolve-Links)

If the simple conversion template is not sufficient, a custom template | Resolve-Links)
can be generated with `New-HtmlTemplate`. | Resolve-Links)

For advanced use, HTML site authoring projects can be generated with | Resolve-Links)
`New-StaticHTMLSiteProject`. These projects have a project configuration | Resolve-Links)
file, a build script, a sophisticated customizable template, and a | Resolve-Links)
customizable converter pipeline. | Resolve-Links)

The Markdown to HTML conversion is achieved by running Markdown content | Resolve-Links)
through a multi-stage conversion pipeline. | Resolve-Links)

~~~
                 Directory
                    |
                    v
        .-----------'------------.
1       |  Markdown File Scanner |
        '-----------.------------'
                    |
               Markdown files
                    |
       .------------'-------------.
2      | HTML Fragment Conversion |
       '------------.-------------'
                    |
  .-----------------'------------------.
3 | Content Substitution Map Generator |
  '-----------------.------------------'
                    |
       .------------'-------------.
4      | HTML Document Assembler  | <--- Template
       '------------.-------------'
                    |
                    v
          standalone HTML Documents
~~~ | Resolve-Links)

The PowerShell functions associated with the pipeline stages are: | Resolve-Links)

1. `Find-MarkdownFiles` | Resolve-Links)
2. `Convert-MarkdownToHTMLFragment` | Resolve-Links)
3. `Add-ContentSubstitutionMap` | Resolve-Links)
4. `Publish-StaticHtmlSite` | Resolve-Links)

# Known Incompatibilities
The updated version of Markdig included in this release introduces an | Resolve-Links)
incompatiblity in the _mathematics_ extension which breaks _KaTeX_ math | Resolve-Links)
rendering. To address this incompaibility the KaTex configuration in | Resolve-Links)
ALL deployed html templates (`md_template.html`) need to be updated like so: | Resolve-Links)

~~~ html
<script>
  // <![CDATA[
  window.onload = function() {
      var tex = document.getElementsByClassName("math");
      Array.prototype.forEach.call(tex, function(el) {
          katex.render(el.textContent, el, {
                                                displayMode: (el.nodeName == "DIV"),
                                                macros: {
                                                           "\\(": "",
                                                           "\\)": "",
                                                           "\\[": "",
                                                           "\\]": ""
                                                        }
                                           })
      });
  };
  // ]]>
</script>
~~~ | Resolve-Links)

# Supported Markdown Extensions
The [Markdig](https://github.com/lunet-io/markdig) Markdown converter can be | Resolve-Links)
configured to understand extended Markdown syntax. Below is a list of | Resolve-Links)
supported extensions which can be used in `Convert-MarkdownToHTML` or | Resolve-Links)
`Convert-MarkdownToHTMLFragment`. | Resolve-Links)

Note that the 'mathematics' and 'diagramming' extensions require additional | Resolve-Links)
configuration in the HTML template (`md-template.html`). Refer to the | Resolve-Links)
`New-HTMLTemplate` for customizatin details. | Resolve-Links)

'abbreviations' | Resolve-Links)
:   [Abbreviations](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/AbbreviationSpecs.md) | Resolve-Links)

'advanced': advanced parser configuration. A pre-build collection of | Resolve-Links)
:   extensions as listed below: | Resolve-Links)
    - 'abbreviations' | Resolve-Links)
    - 'autoidentifiers' | Resolve-Links)
    - 'citations' | Resolve-Links)
    - 'customcontainers' | Resolve-Links)
    - 'definitionlists' | Resolve-Links)
    - 'emphasisextras' | Resolve-Links)
    - 'figures' | Resolve-Links)
    - 'footers' | Resolve-Links)
    - 'footnotes' | Resolve-Links)
    - 'gridtables' | Resolve-Links)
    - 'mathematics' | Resolve-Links)
    - 'medialinks' | Resolve-Links)
    - 'pipetables' | Resolve-Links)
    - 'listextras' | Resolve-Links)
    - 'tasklists' | Resolve-Links)
    - 'diagrams' | Resolve-Links)
    - 'autolinks' | Resolve-Links)
    - 'attributes' | Resolve-Links)

'attributes' | Resolve-Links)
:   [Special attributes](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/GenericAttributesSpecs.md). | Resolve-Links)
    Set HTML attributes (e.g `id` or class`). | Resolve-Links)

'autoidentifiers' | Resolve-Links)
:   [Auto-identifiers](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/AutoIdentifierSpecs.md). | Resolve-Links)
    Allows to automatically create identifiers for headings. | Resolve-Links)

'autolinks' | Resolve-Links)
:   [Auto-links](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/AutoLinks.md) | Resolve-Links)
    generates links if a text starts with `http://` or `https://` or `ftp://` or `mailto:` or `www.xxx.yyy`. | Resolve-Links)

'bootstrap' | Resolve-Links)
:   [Bootstrap](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/BootstrapSpecs.md) | Resolve-Links)
    to output bootstrap classes. | Resolve-Links)

'citations' | Resolve-Links)
:   [Citation text](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FigureFooterAndCiteSpecs.md) | Resolve-Links)
     by enclosing text with `''...''` | Resolve-Links)

'common' | Resolve-Links)
:   CommonMark parsing; no parser extensions (default) | Resolve-Links)

'customcontainers' | Resolve-Links)
:   [Custom containers](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/CustomContainerSpecs.md) | Resolve-Links)
    similar to fenced code block `:::` for generating a proper | Resolve-Links)
    `<div>...</div>` instead. | Resolve-Links)

'definitionlists' | Resolve-Links)
:   [Definition lists](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/DefinitionListSpecs.md) | Resolve-Links)

'diagrams' | Resolve-Links)
:   [Diagrams](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/DiagramsSpecs.md) | Resolve-Links)
    whenever a fenced code block uses the 'mermaid' keyword, it will be | Resolve-Links)
    converted to a div block with the content as-is (currently, supports | Resolve-Links)
    `mermaid` and `nomnoml` diagrams). Resources for the `mermaid` diagram | Resolve-Links)
    generator are pre-installed and configured. | Resolve-Links)
    See `New-HTMLTemplate` for customization details for this feature. | Resolve-Links)

'emojis' | Resolve-Links)
:   [Emoji](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/EmojiSpecs.md) | Resolve-Links)
    support. | Resolve-Links)

'emphasisextras' | Resolve-Links)
:    [Extra emphasis](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/EmphasisExtraSpecs.md) | Resolve-Links)
     - strike through `~~`, | Resolve-Links)
     - Subscript `~` | Resolve-Links)
     - Superscript `^` | Resolve-Links)
     - Inserted `++` | Resolve-Links)
     - Marked `==` | Resolve-Links)

'figures' | Resolve-Links)
:   [Figures](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FigureFooterAndCiteSpecs.md). | Resolve-Links)
    A figure can be defined by using a pattern equivalent to a fenced code | Resolve-Links)
    block but with the character `^`. | Resolve-Links)

'footers' | Resolve-Links)
:   [Footers](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FigureFooterAndCiteSpecs.md) | Resolve-Links)

'footnotes' | Resolve-Links)
:   [Footnotes](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FootnotesSpecs.md) | Resolve-Links)

'globalization' | Resolve-Links)
:   [https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/GlobalizationSpecs.md] | Resolve-Links)
    Adds support for RTL (Right To Left) content by adding `dir="rtl"` and | Resolve-Links)
    `align="right"` attributes to the appropriate html elements. Left to | Resolve-Links)
    right text is not affected by this extension. | Resolve-Links)

'gridtables' | Resolve-Links)
:   [Grid tables](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/GridTableSpecs.md) | Resolve-Links)
    allow to have multiple lines per cells and allows to span cells over | Resolve-Links)
    multiple columns. | Resolve-Links)

'hardlinebreak' | Resolve-Links)
:   [Soft lines](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/HardlineBreakSpecs.md) | Resolve-Links)
    as hard lines | Resolve-Links)

'listextras' | Resolve-Links)
:   [Extra bullet lists](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/ListExtraSpecs.md), | Resolve-Links)
    supporting alpha bullet a. b. and roman bullet (i, ii...etc.) | Resolve-Links)

'mathematics' | Resolve-Links)
:   [Mathematics](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/MathSpecs.md) | Resolve-Links)
    LaTeX extension by enclosing `$$` for block and `$` for inline math. | Resolve-Links)
    Resources for this extension are pre-installed and configured. | Resolve-Links)
    See `New-HTMLTemplate` for customization details. | Resolve-Links)

'medialinks' | Resolve-Links)
:   [Media support](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/MediaSpecs.md) | Resolve-Links)
    for media urls (youtube, vimeo, mp4...etc.) | Resolve-Links)

'nofollowlinks' | Resolve-Links)
:   Add `rel=nofollow` to all links rendered to HTML. | Resolve-Links)

'nohtml' | Resolve-Links)
:   [NoHTML](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/NoHtmlSpecs.md) | Resolve-Links)
     allows to disable the parsing of HTML. | Resolve-Links)

'nonascii-noescape' | Resolve-Links)
:   Use this extension to disable URI escape with % characters for | Resolve-Links)
    non-US-ASCII characters in order to workaround a bug under IE/Edge with | Resolve-Links)
    local file links containing non US-ASCII chars. DO NOT USE OTHERWISE. | Resolve-Links)

'pipetables' | Resolve-Links)
:   [Pipe tables](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/PipeTableSpecs.md) | Resolve-Links)
    to generate tables from markup. | Resolve-Links)

'smartypants' | Resolve-Links)
:   [SmartyPants](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/SmartyPantsSpecs.md) | Resolve-Links)
    quotes. | Resolve-Links)

'tasklists' | Resolve-Links)
:   [Task Lists](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/TaskListSpecs.md). | Resolve-Links)
    A task list item consist of `[ ]` or `[x]` or `[X]` inside a list item | Resolve-Links)
    (ordered or unordered). | Resolve-Links)

'yaml' | Resolve-Links)
:   [YAML frontmatter](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/YamlSpecs.md) | Resolve-Links)
    parsing. | Resolve-Links)

# Template Customization
The pre-installed templates are meant as a starting point for customaization. | Resolve-Links)

This is typically done by cloning new templates by either | Resolve-Links)
`New-HTML-Template` or creating a HTML site project by | Resolve-Links)
`New-StaticHTMLSiteProject`. | Resolve-Links)

Use `New-HTML-Template` if only simple customization involving style sheet | Resolve-Links)
changes or extension configuration (eg. disabling pre activated extension) | Resolve-Links)
is needed. | Resolve-Links)

Use `New-StaticHTMLSiteProject` for advanced customization options involving | Resolve-Links)
changes to the HTML page structure, or project build scripts. | Resolve-Links)

All factory-default templates are pre-configured in the following way: | Resolve-Links)

* Code syntax highlighting is pre-installed for following languages: | Resolve-Links)
  - Bash | Resolve-Links)
  - C# | Resolve-Links)
  - C++ | Resolve-Links)
  - Clojure | Resolve-Links)
  - CMake | Resolve-Links)
  - CSS | Resolve-Links)
  - Diff | Resolve-Links)
  - DOS .bat | Resolve-Links)
  - F# | Resolve-Links)
  - Groovy | Resolve-Links)
  - HTML/XML | Resolve-Links)
  - HTTP | Resolve-Links)
  - Java | Resolve-Links)
  - JavaScript | Resolve-Links)
  - JSON | Resolve-Links)
  - Lisp | Resolve-Links)
  - Makefile | Resolve-Links)
  - Markdown | Resolve-Links)
  - Maxima | Resolve-Links)
  - Perl | Resolve-Links)
  - Python | Resolve-Links)
  - PowerShell | Resolve-Links)
  - SQL | Resolve-Links)
  - YAML | Resolve-Links)

  To obtain syntax highlighting for other/additional languages, please visit | Resolve-Links)
  the [Getting highlight.js](https://highlightjs.org/download/) page and | Resolve-Links)
  get a customized version of highlight.js configured for the languages | Resolve-Links)
  you need. | Resolve-Links)
* Diagramming ('mermaid' extension) is activated and its resources are | Resolve-Links)
  pre-installed. | Resolve-Links)
* Math Typesetting ('mathematics' extension) is activated and its resources | Resolve-Links)
  are pre-installed. | Resolve-Links)

Template directories generated by either `New-HTML-Template` or | Resolve-Links)
`New-StaticHTMLSiteProject` have following default structure: | Resolve-Links)

~~~
<root>                 <- template root directory
   |- js               <- javascripts (*.js)
   |- katex            <- LateX math renderer
   |- styles           <- stylesheets (*.css)
   '- md-template.html <- Html page template
~~~ | Resolve-Links)

`js` | Resolve-Links)
:    This subdirectory initially contains JavaScript resources to support | Resolve-Links)
     extensions such as code syntax highlighting or diagramming. | Resolve-Links)
     JavaScript files can be added or removed as needed. | Resolve-Links)

`katex` | Resolve-Links)
:   This directory contains the support files for LaTeX math rendering. It | Resolve-Links)
    can be removed if this functionality is not needed. | Resolve-Links)

`styles` | Resolve-Links)
:   Contains style sheets. The file `md-styles.css` contains the default | Resolve-Links)
    styles. The other style sheets support code systax highlighting themes. | Resolve-Links)
    Usually style customization of the HTML pages is achieved by editing | Resolve-Links)
    `md-styles.css`. However, other `*.css` files can be added as needed. | Resolve-Links)

`md-template.html` | Resolve-Links)
:   The HTML template file. This file defines the basic structure of the | Resolve-Links)
    final HTML page. Standalone HTML documents are created from this | Resolve-Links)
    template by substituting placeholders with HTML fragments. Placeholders | Resolve-Links)
    are tokens delimited by `{{` and `}}`. At least the two following | Resolve-Links)
    placeholders should be present in a template: | Resolve-Links)

    `{{title}}` | Resolve-Links)
    :   Placeholder for a page title generated from the Markdown content or | Resolve-Links)
        filename. | Resolve-Links)

    `{{content}}` | Resolve-Links)
    :   Placeholder for the HTML content fragment generated from Markdown | Resolve-Links)
        content. | Resolve-Links)

    Also this file needs to load all JavaScript and stylesheet resources | Resolve-Links)
    to render the final HTML page in the desired way. | Resolve-Links)

# Keywords
Markdown HTML static sites Conversion | Resolve-Links)

# Other Markdown Site Generators
* [MkDocs](https://www.mkdocs.org/) - A fast and simple static site generator | Resolve-Links)
  that is geared towards building project documentation. | Resolve-Links)
  Documentation source files are written in Markdown, and configured with a | Resolve-Links)
  single YAML configuration file. | Resolve-Links)


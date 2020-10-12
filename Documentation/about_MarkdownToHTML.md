# Topic
about_MarkdownToHTML

# Short_Description
Highly configurable markdown to HTML conversion using customizable templates.

Based on [Markdig](https://github.com/lunet-io/markdig), a fast, powerful,
[CommonMark](http://commonmark.org/) compliant, extensible Markdown
processor for .NET.

This version is incompatible with existing conversion projects
which use the 'mathematics' extensions and were created with versions of
this module older than 2.0.0 (i.e. 1.* or 0.*).

Make sure to read the 'KNOWN INCOMPATIBILITIES' section below about options
for upgrading existing conversion projects.

# Long Description
A typical use case is to ad-hoc convert a bunch of Markdown files in a
directory to a static Html site using [`Convert-MarkdownToHtml`](Convert-MarkdownToHtml.md). This uses
a simple, built-in HTML conversion template.

If the simple conversion template is not sufficient, a custom template
can be generated with [`New-HtmlTemplate`](New-HtmlTemplate.md).

For advanced use, HTML site authoring projects can be generated with
[`New-StaticHTMLSiteProject`](New-StaticHTMLSiteProject.md). These projects have a project configuration
file, a build script, a sophisticated customizable template, and a
customizable converter pipeline.

The Markdown to HTML conversion is achieved by running Markdown content
through a multi-stage conversion pipeline.

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
       .------------'-------------.    .- Template
3      | HTML Document Assembler  | <--+
       '------------.-------------'    '- Content Map
                    |
                    v
          standalone HTML Documents
~~~

The PowerShell functions associated with the pipeline stages are:

1. [`Find-MarkdownFiles`](Find-MarkdownFiles.md)
2. [`Convert-MarkdownToHTMLFragment`](Convert-MarkdownToHTMLFragment.md)
3. [`Publish-StaticHtmlSite`](Publish-StaticHtmlSite.md)

# Known Incompatibilities
The updated version of Markdig included in this release introduces an
incompatiblity in the _mathematics_ extension which breaks _KaTeX_ math
rendering. To address this incompaibility the KaTex configuration in
ALL deployed html templates (`md_template.html`) need to be updated like so:

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
~~~

# Supported Markdown Extensions
The [Markdig](https://github.com/lunet-io/markdig) Markdown converter can be
configured to understand extended Markdown syntax. Below is a list of
supported extensions which can be used in [`Convert-MarkdownToHTML`](Convert-MarkdownToHTML.md) or
[`Convert-MarkdownToHTMLFragment`](Convert-MarkdownToHTMLFragment.md).

Note that the 'mathematics' and 'diagramming' extensions require additional
configuration in the HTML template (`md-template.html`). Refer to the
[`New-HTMLTemplate`](New-HTMLTemplate.md) for customizatin details.

'abbreviations'
:   [Abbreviations](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/AbbreviationSpecs.md)

'advanced': advanced parser configuration. A pre-build collection of
:   extensions as listed below:
    - 'abbreviations'
    - 'autoidentifiers'
    - 'citations'
    - 'customcontainers'
    - 'definitionlists'
    - 'emphasisextras'
    - 'figures'
    - 'footers'
    - 'footnotes'
    - 'gridtables'
    - 'mathematics'
    - 'medialinks'
    - 'pipetables'
    - 'listextras'
    - 'tasklists'
    - 'diagrams'
    - 'autolinks'
    - 'attributes'

'attributes'
:   [Special attributes](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/GenericAttributesSpecs.md).
    Set HTML attributes (e.g `id` or class`).

'autoidentifiers'
:   [Auto-identifiers](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/AutoIdentifierSpecs.md).
    Allows to automatically create identifiers for headings.

'autolinks'
:   [Auto-links](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/AutoLinks.md)
    generates links if a text starts with `http://` or `https://` or `ftp://` or `mailto:` or `www.xxx.yyy`.

'bootstrap'
:   [Bootstrap](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/BootstrapSpecs.md)
    to output bootstrap classes.

'citations'
:   [Citation text](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FigureFooterAndCiteSpecs.md)
     by enclosing text with `''...''`

'common'
:   CommonMark parsing; no parser extensions (default)

'customcontainers'
:   [Custom containers](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/CustomContainerSpecs.md)
    similar to fenced code block `:::` for generating a proper
    `<div>...</div>` instead.

'definitionlists'
:   [Definition lists](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/DefinitionListSpecs.md)

'diagrams'
:   [Diagrams](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/DiagramsSpecs.md)
    whenever a fenced code block uses the 'mermaid' keyword, it will be
    converted to a div block with the content as-is (currently, supports
    `mermaid` and `nomnoml` diagrams). Resources for the `mermaid` diagram
    generator are pre-installed and configured.
    See [`New-HTMLTemplate`](New-HTMLTemplate.md) for customization details for this feature.

'emojis'
:   [Emoji](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/EmojiSpecs.md)
    support.

'emphasisextras'
:    [Extra emphasis](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/EmphasisExtraSpecs.md)
     - strike through `~~`,
     - Subscript `~`
     - Superscript `^`
     - Inserted `++`
     - Marked `==`

'figures'
:   [Figures](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FigureFooterAndCiteSpecs.md).
    A figure can be defined by using a pattern equivalent to a fenced code
    block but with the character `^`.

'footers'
:   [Footers](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FigureFooterAndCiteSpecs.md)

'footnotes'
:   [Footnotes](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FootnotesSpecs.md)

'globalization'
:   [https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/GlobalizationSpecs.md]
    Adds support for RTL (Right To Left) content by adding `dir="rtl"` and
    `align="right"` attributes to the appropriate html elements. Left to
    right text is not affected by this extension.

'gridtables'
:   [Grid tables](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/GridTableSpecs.md)
    allow to have multiple lines per cells and allows to span cells over
    multiple columns.

'hardlinebreak'
:   [Soft lines](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/HardlineBreakSpecs.md)
    as hard lines

'listextras'
:   [Extra bullet lists](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/ListExtraSpecs.md),
    supporting alpha bullet a. b. and roman bullet (i, ii...etc.)

'mathematics'
:   [Mathematics](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/MathSpecs.md)
    LaTeX extension by enclosing `$$` for block and `$` for inline math.
    Resources for this extension are pre-installed and configured.
    See [`New-HTMLTemplate`](New-HTMLTemplate.md) for customization details.

'medialinks'
:   [Media support](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/MediaSpecs.md)
    for media urls (youtube, vimeo, mp4...etc.)

'nofollowlinks'
:   Add `rel=nofollow` to all links rendered to HTML.

'nohtml'
:   [NoHTML](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/NoHtmlSpecs.md)
     allows to disable the parsing of HTML.

'nonascii-noescape'
:   Use this extension to disable URI escape with % characters for
    non-US-ASCII characters in order to workaround a bug under IE/Edge with
    local file links containing non US-ASCII chars. DO NOT USE OTHERWISE.

'pipetables'
:   [Pipe tables](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/PipeTableSpecs.md)
    to generate tables from markup.

'smartypants'
:   [SmartyPants](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/SmartyPantsSpecs.md)
    quotes.

'tasklists'
:   [Task Lists](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/TaskListSpecs.md).
    A task list item consist of `[ ]` or `[x]` or `[X]` inside a list item
    (ordered or unordered).

'yaml'
:   [YAML frontmatter](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/YamlSpecs.md)
    parsing.

# Project Default Configuration
The factory-default project is pre-configured in the following way:

### Code Syntax Highlighting
Pre-installed for following languages:
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
get a customized version of highlight.js configured for the languages
you need.

### Diagramming
The 'mermaid' extension is activated and its resources are pre-installed.

### Math Typesetting
The 'mathematics' extension is activated and its resources are pre-installed.

# Template Customization
The pre-installed templates are meant as a starting point for customaization.

This is typically done by cloning new templates by either
[`New-HTMLTemplate`](New-HTMLTemplate.md) or creating a HTML site project by
[`New-StaticHTMLSiteProject`](New-StaticHTMLSiteProject.md).

Use [`New-HTMLTemplate`](New-HTMLTemplate.md) if only simple customization involving style sheet
changes or extension configuration (eg. disabling pre activated extension)
is needed.

Use [`New-StaticHTMLSiteProject`](New-StaticHTMLSiteProject.md) for advanced customization options involving
changes to the HTML page structure, or project build scripts.

Template directories generated by either [`New-HTMLTemplate`](New-HTMLTemplate.md) or
[`New-StaticHTMLSiteProject`](New-StaticHTMLSiteProject.md) have following default structure:

~~~
<root>                 <- template root directory
   |- js               <- javascripts (*.js)
   |- katex            <- LateX math renderer
   |- styles           <- stylesheets (*.css)
   '- md-template.html <- Html page template
~~~

### The `js` directory
Initially contains JavaScript resources to support
extensions such as code syntax highlighting or diagramming.
JavaScript files can be added or removed as needed.

### The `katex` directory
Contains the support files for LaTeX math rendering. It
can be removed if this functionality is not needed.

### The `styles` directory
Contains style sheets. The file `md-styles.css` contains the default
styles. The other style sheets support other feature such as
code systax highlighting.

Usually style customization of the HTML pages is achieved by editing
`md-styles.css`. However, other `*.css` files can be added as needed.

### The `md-template.html` template
This HTML template file defines the basic structure of the
final HTML pages. Standalone HTML documents are created from this
template by substituting placeholders with HTML fragments. Placeholders
are tokens delimited by `{{` and `}}`. At least the two following
placeholders should be present in a template:

`{{title}}`
:   Placeholder for a page title generated from the Markdown content or
    filename.

`{{content}}`
:   Placeholder for the HTML content fragment generated from Markdown
    content.

When additional placeholders are added they need to be defined in the
content map in `Build.ps1`. See the next section for details.

The `md-template.html` needs to load all JavaScript and stylesheet resources
to render the final HTML page in the desired way.

# Content Map Customization
When a custom placeholders was added to `md-template.html` it needs to
be replaced by a HTML fragment during the build process. This can be done
by adding an entry to the content map defined in `Build.ps1`. For example:

~~~ Powershell
SCRIPT:contentMap = @{

'{{my_placeholder}}' = '<b>Hello</b>'
footer}}' =  $config.Footer # Footer text from configuration

...
}
~~~

This will replace all occurenced of `{{my_placeholder}}` in
`md-template.html` with the HTML fragment `<b>Hello</b>`.

The replacement value for a placeholders can be dynamically computed. To
do this a script block can be assigned to the placeholder.

The script block takes **one** parameter to which an object is bound
which has these properties:

| Property       | Description                                                     |
| :------------: | :-------------------------------------------------------------- |
| `Title`        | Optional page title. The first heading in the Markdown content. |
| `HtmlFragment` | The HTML fragment string generated from the Markdown text.      |
| `RelativePath` | Passed through form the input object, provided it exists.       |

It is called once for each HTML fragment and should return one or more
strings which define the substitution value for each page.

Script Block example:

~~~ PowerShell
{
  param($Input)
  "Source = $($Input.RelativePath)"
}
~~~

This script block would subsitute the path of the HTML document relative
to the site root for every occurence of '{{my_placeholder}}'.
# Keywords
Markdown HTML static sites Conversion

# Other Markdown Site Generators
* [MkDocs](https://www.mkdocs.org/) - A fast and simple static site generator
  that is geared towards building project documentation.
  Documentation source files are written in Markdown, and configured with a
  single YAML configuration file.


# New-HTMLTemplate

Create a new customizable template directory for Markdown to HTML conversion.

# Syntax

<blockquote>

```PowerShell
 New-HTMLTemplate [-Destination] <String>  [<CommonParameters>] 
```


</blockquote>

# Description

<blockquote>

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
See [Convert-MarkdownToHTML](Convert-MarkdownToHTML.md) for links.

</blockquote>

# Parameters

<blockquote>



## -Destination \<String\>

<blockquote>

Location of the new conversion template directory. The template directory
should be empty or non-existent.

Parameter Property         | Value
--------------------------:|:----------
Required?                  | true
Position?                  | 1
Default value              | ``
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>


</blockquote>


# Inputs

<blockquote>

This function does not read from the pipe

</blockquote>

# Outputs

<blockquote>

The new conversion template directory `[System.IO.DirectoryInfo]`

</blockquote>

# Examples

<blockquote>


## EXAMPLE 1

```PowerShell
New-HTMLTemplate -Destination 'E:\MyTemplate'
```

Create a copy of the default template in `E:\MyTemplate` for customization.

</blockquote>

# Related Links

<blockquote>


* [Convert-MarkdownToHtml](Convert-MarkdownToHtml.md) 
* [Find-MarkdownFiles](Find-MarkdownFiles.md) 
* [Convert-MarkdownToHtmlFragment](Convert-MarkdownToHtmlFragment.md) 
* [Publish-StaticHtmlSite](Publish-StaticHtmlSite.md)

</blockquote>

---

<cite>Module: MarkdownToHtml; Version: 2.0.0; (c) 2018-2020 WetHat Lab. All rights reserved.</cite>

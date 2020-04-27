# New-StaticHTMLSiteProject

Create a customizable Markdown to HTML site conversion project.

# Syntax
```PowerShell
 New-StaticHTMLSiteProject [-ProjectDirectory] <String>  [<CommonParameters>] 
```


# Description


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

`html`
:   The build output direcoty containing the static HTML site. This directory
    is overwritten by every build.

`markdown`
:   Directory containing the authored Markdown content for this project.
    Initially this contains the project's `README.md` file.

`Template`
:   The directory containing the HTML template and resources for the project.
    See [`about_MarkdownToHTML`](about_MarkdownToHTML.md) section 'TEMPLATE CUSTOMIZATION' for more
    information. The HTML template ([`md-template-html`](md-template-html.md)) containe in this
    directory contains besides the two standard placeholders `{{title}}` and
    `{{content}}` following additional placeholders:

    `{{nav}}`
    :   Placehoder which is replaced by a HTML content fragment
        providing a navigatation section on each page.

    `{{footer}}`
    :   Placeholder which is replaced by a HTML content fragment
        representing the page footer.

`Build.json`
:   The project configuration file in [JavaScript Object Notation](https://en.wikipedia.org/wiki/JSON)
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
        possible extension, refer to the documentation of the function
       [`Convert-MarkdownToHTML`](Convert-MarkdownToHTML.md).

    `footer`
    :   Page footer text which gets substituted for the placeholder `{{footer}}` in
        the HTML template `md-template.html`.

    `site_navigation`
    :   A list of links to be shown in each page's `<nav>` section.
        The list will be substitutes for the placeholder `{{nav}}` in
        the HTML template `md-template.html`.

`Build.ps1`
:   The project build script.

``





# Parameters

<blockquote>



## -ProjectDirectory \<String\>

<blockquote>

The location of the new Markdown to HTML site conversion project.

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
None


# Outputs
The new project directory object `[System.IO.DirectoryInfo]`

# Examples

<blockquote>


## EXAMPLE 1

```PowerShell
New-StaticHTMLSiteProject -ProjectDirectory MyProject
```


Create a new conversion project names 'MyProject' in the current directory. The
project is ready for build.













</blockquote>

# Related Links

* [https://github.com/WetHat/MarkdownToHtml/blob/master/Documentation/New-StaticHTMLSiteProject.md](https://github.com/WetHat/MarkdownToHtml/blob/master/Documentation/New-StaticHTMLSiteProject.md) 
* [`New-HTMLTemplate`](New-HTMLTemplate.md)

---

<cite>Module: MarkdownToHtml; Version: 2.1.0; (c) 2018-2020 WetHat Lab. All rights reserved.</cite>

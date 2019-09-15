﻿# Publish-StaticHtmlSite

Create a static HTML site from HTML fragment objects.

# Syntax

<blockquote>

```PowerShell
 Publish-StaticHtmlSite [-InputObject] <Object> [-Template] <String> [-SiteDirectory] <String>  [<CommonParameters>] 
```


</blockquote>

# Description

<blockquote>

Html fragment objects piped into this function (or passed via the `InputObject` parameter) are converted
into HTML documents and saved to a static Html site directory.

The Markdown to Html document conversion uses a default or custom template with
stylesheets and JavaScript resources to render Markdown extensions for LaTeX math, code syntax
highlighting and diagrams (see [`New-HtmlTemplate`](New-HtmlTemplate.md) for details).

</blockquote>

# Parameters

<blockquote>



## -InputObject \<Object\>

<blockquote>

An object representing an Html fragment. Ideally this is an output object of
['Convert-MarkdownToHtmlFragment'](Convert-MarkdownToHtmlFragment.md), but any object will
work provided following properties are present:
* `RelativePath`: A string representing the relative path to the Markdown file with respect to
  a base (static site) directory.
  This property is provided by:
  * using the PowerShell function [`Find-MarkdownFiles`](Find-MarkdownFiles.md)
  * piping a file object `[System.IO.FileInfo]` into
    ['Convert-MarkdownToHtmlFragment'](Convert-MarkdownToHtmlFragment.md)
    (or passing it as a parameter).
* `Title`: Optional page title. This property is generated by
   ['Convert-MarkdownToHtmlFragment'](Convert-MarkdownToHtmlFragment.md) from
   the first heading in a Markdown document.
* `HtmlFragment`: The HTML fragment string generated from the Markdown text.

Parameter Property         | Value
--------------------------:|:----------
Required?                  | true
Position?                  | 1
Default value              | ``
Accept pipeline input?     | true (ByValue)
Accept wildcard characters?| false

</blockquote>
 

## -Template \<String\>

<blockquote>

Optional directory containing the html template file `md-template.html` and its resources
which will be used to convert the Html fragments into standalone Html documents.
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
 

## -SiteDirectory \<String\>

<blockquote>

Directory for the generated HTML files. The Html files will be placed
in the same relative location below this directory as related Markdown document
has below the input directory. If the site directory does not exist it will be created.
If the site directory already exists its files will be retained, but possibly overwitten
by generated HTML files.

Parameter Property         | Value
--------------------------:|:----------
Required?                  | true
Position?                  | 3
Default value              | ``
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>


</blockquote>


# Inputs

<blockquote>

Html Fragment objects having the properties `RelativePath`,`Title`, and `HtmlFragment`.
See the description of the `InputObject` parameter for details

</blockquote>

# Outputs

<blockquote>

File objects [System.IO.FileInfo] of the generated HTML documents.

</blockquote>

# Examples

<blockquote>


## EXAMPLE 1

```PowerShell
Find-MarkdownFiles '...\Modules\MarkdownToHtml' | Convert-MarkdownToHtmlFragment | Publish-StaticHtmlSite -SiteDirectory 'e:\temp\site'
```

Generates a static HTML site from the Markdown files in '...\Modules\MarkdownToHtml'. This is
a simpler version of the functionality provided by the function [`Convert-MarkdownToHtml`](Convert-MarkdownToHtml).

The generated Html file objects are returned like so:

    Mode                LastWriteTime         Length Name
    ----                -------------         ------ ----
    -a----       15.09.2019     10:03          16395 Convert-MarkdownToHTML.html
    -a----       15.09.2019     10:03          14714 Convert-MarkdownToHTMLFragment.html
    -a----       15.09.2019     10:03           4612 Find-MarkdownFiles.html
    -a----       15.09.2019     10:03           6068 MarkdownToHTML.html
    ...          ...            ...            ...

</blockquote>

# Related Links

<blockquote>


* [Convert-MarkdownToHtml](Convert-MarkdownToHtml.md) 
* [Find-MarkdownFiles](Find-MarkdownFiles.md) 
* [Convert-MarkdownToHtmlFragment](Convert-MarkdownToHtmlFragment.md) 
* [New-HTMLTemplate](New-HTMLTemplate.md)

</blockquote>

---

<cite>Module: MarkdownToHTML; Version: 1.3.0; (c) 2018-2019 WetHat Lab. All rights reserved.</cite>
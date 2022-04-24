# Convert-MarkdownToHTML

Convert Markdown files to static HTML files.

# Syntax
```PowerShell
 Convert-MarkdownToHTML [-Path] <String> [-Template] <String> [-IncludeExtension] <String[]> [-ExcludeExtension] <String[]> [-MediaDirectory] <String> [-SiteDirectory] <String>  [<CommonParameters>] 
```


# Description


This function reads all Markdown files from a source folder and converts each
of them to a standalone html document using:

* configurable [Markdown extensions](about_MarkdownToHTML.md#supported-markdown-extensions)
* a customizable or default HTML template. See [`New-HTMLTemplate`](New-HTMLTemplate.md) about
  the creation of custom templates.





# Parameters

<blockquote>



## -Path \<String\>

<blockquote>

Path to Markdown files or directories containing Markdown files.

---

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
If no template directory is specified, the factory-installed default template is used.
For information about creating custom templates see [`New-HTMLTemplate`](New-HTMLTemplate.md).

---

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

Comma separated list of Markdown parsing extensions to use.
See [about_MarkdownToHTML](MarkdownToHTML.md#markdown-extensions) for an
annotated list of supported extensions.

---

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

---

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

---

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

---

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

# Examples


## EXAMPLE 1

> ~~~ PowerShell
> Convert-MarkdownToHTML -Path 'E:\MyMarkdownFiles' -SiteDirectory 'E:\MyHTMLFiles'
> ~~~
>
> 
> Convert all Markdown files in `E:\MyMarkdownFiles` and save the generated HTML
> files to `E:\MyHTMLFiles`.
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
 
## EXAMPLE 2

> ~~~ PowerShell
> Convert-MarkdownToHTML -Path 'E:\MyMarkdownFiles' -Template 'E:\MyTemplate' -SiteDirectory 'E:\MyHTMLFiles'
> ~~~
>
> 
> Convert all Markdown files in `E:\MyMarkdownFiles` using the 'common' parsing
> configuration and the custom template in `E:\MyTemplate`.
> 
> The generated HTML files are saved to `E:\MyHTMLFiles`.
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
 
## EXAMPLE 3

> ~~~ PowerShell
> Convert-MarkdownToHTML -Path 'E:\MyMarkdownFiles' -SiteDirectory 'E:\MyHTMLFiles' -IncludeExtension 'advanced','diagrams'
> ~~~
>
> 
> Convert all Markdown files in `E:\MyMarkdownFiles` using the 'advanced' and
> 'diagrams' parsing extension and the default template.
> 
> The generated HTML files are saved to `E:\MyHTMLFiles`.
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
 
## EXAMPLE 4

> ~~~ PowerShell
> Convert-MarkdownToHTML -Path 'E:\MyMarkdownFiles' -MediaDirectory 'e:\Media' -SiteDirectory 'E:\MyHTMLFiles' -IncludeExtension 'advanced','diagrams'
> ~~~
>
> 
> Convert all Markdown files in `E:\MyMarkdownFiles` using
> * the 'advanced' and 'diagrams' parsing extension.
> * the default template
> * Media files (images, Videos, etc.) from the directory `e:\Media`
> 
> The generated HTML files are saved to the directory `E:\MyHTMLFiles`.
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 


# Related Links

* [https://wethat.github.io/MarkdownToHtml/2.7/Convert-MarkdownToHTML.html](https://wethat.github.io/MarkdownToHtml/2.7/Convert-MarkdownToHTML.html) 
* [`New-HTMLTemplate`](New-HTMLTemplate.md) 
* [Markdown extensions](about_MarkdownToHTML.md#supported-markdown-extensions)

---

<cite>Module: MarkDownToHTML; Version: 2.7.1; (c) 2018-2022 WetHat Lab. All rights reserved.</cite>

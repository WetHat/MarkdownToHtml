# Publish-StaticHtmlSite

Create a static HTML site from HTML fragment objects.

# Syntax
```PowerShell
 Publish-StaticHtmlSite [-InputObject] <Object> [-Template] <String> [-ContentMap] <Hashtable> [-MediaDirectory] <String> [-SiteDirectory] <String>  [<CommonParameters>] 
```


# Description


Html fragment objects piped into this function (or passed via the `InputObject`
parameter) are converted into standalone HTML documents and saved to a Html site
directory.

The Markdown to HTML document conversion uses default or custom templates with
stylesheets and JavaScript resources to render Markdown extensions for:
* LaTeX math
* code syntax highlighting
* diagrams

See [`New-HtmlTemplate`](New-HtmlTemplate.md) for details.





# Parameters

<blockquote>



## -InputObject \<Object\>

<blockquote>

An object representing an Html fragment. Ideally this is an output object
returned by [`Convert-MarkdownToHTMLFragment`](Convert-MarkdownToHTMLFragment.md), but any object will
work provided following properties are present:

`RelativePath`
:   A string representing the relative path to the Markdown file with respect to
    a base (static site) directory.
    This property is automatically provided by:
    * using the PowerShell function [`Find-MarkdownFiles`](Find-MarkdownFiles.md)
    * piping a file object `[System.IO.FileInfo]` into
      [`Convert-MarkdownToHTMLFragment`](Convert-MarkdownToHTMLFragment.md) (or passing it as a parameter).

`Title`
:   The page title.

`HtmlFragment`
:   A html fragment, as string or array of strings to be used as main content of
    the HTML document.

---

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

Optional directory containing the html template file `md-template.html` and its
resources which will be used to convert the Html fragments into standalone Html
documents. If no template directory is specified, a default factory-installed
template is used. For infomations about creating custom templates see
[`New-HTMLTemplate`](New-HTMLTemplate.md). See
[Template Customization](about_MarkdownToHTML.md#conversion-template-customization)
for customization options.

---

Parameter Property         | Value
--------------------------:|:----------
Required?                  | false
Position?                  | 2
Default value              | `(Join-Path $SCRIPT:moduleDir.FullName 'Template')`
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>
 

## -ContentMap \<Hashtable\>

<blockquote>

Placeholder substitution mapping as described in
[Template Customization](about_MarkdownToHTML.md#conversion-template-customization).

Following substitution mappings are used by default unless explicitely defined.

| Placeholder   | Description                  | Origin                      |
|:------------- | :--------------------------- | :-------------------------- |
| `{{title}}`   | Auto generated page title    | `$inputObject.Title`        |
| `[title]`     | For backwards compatibility. | `$inputObject.Title`        |
| `{{content}}` | HTML content                 | `$inputObject.HtmlFragment` |
| `[content]`   | For backwards compatibility. | `$inputObject.HtmlFragment` |

For static HTML site projects additional mappings are defined:

| Placeholder   | Description                  | Origin       |
|:------------- | :--------------------------- | :----------- |
| `{{nav}}`     | Navigation bar content       | `Build.json` |
| `{{footer}}`  | Page footer content          | `Build.json` |

For static HTML site projects additional placeholders can be added to the map.
See
[Defining Content Mapping Rules](about_MarkdownToHTML.md#defining-content-mapping-rules)

---

Parameter Property         | Value
--------------------------:|:----------
Required?                  | false
Position?                  | 3
Default value              | ``
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>
 

## -MediaDirectory \<String\>

<blockquote>

An optional directory containing additional media for the HTML site
such as images, videos etc.

---

Parameter Property         | Value
--------------------------:|:----------
Required?                  | false
Position?                  | 4
Default value              | ``
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

---

Parameter Property         | Value
--------------------------:|:----------
Required?                  | true
Position?                  | 5
Default value              | ``
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>


</blockquote>


# Inputs
An Html Fragment objects having the properties `RelativePath`,`Title`, `HtmlFragment` , and
optionally `ContentMap`. See the description of the `InputObject` parameter for details


# Outputs
File objects [System.IO.FileInfo] of the generated HTML documents.

# Examples


## EXAMPLE 1

> ~~~ PowerShell
> Find-MarkdownFiles '...\Modules\MarkdownToHtml' | Convert-MarkdownToHTMLFragment | Publish-StaticHtmlSite -SiteDirectory 'e:\temp\site'
> ~~~
>
> 
> Generates a static HTML site from the Markdown files in '...\Modules\MarkdownToHtml'. This is
> a simpler version of the functionality provided by the function [`Convert-MarkdownToHTML`](Convert-MarkdownToHTML.md).
> 
> The generated Html file objects are returned like so:
> 
>     Mode                LastWriteTime         Length Name
>     ----                -------------         ------ ----
>     -a----       15.09.2019     10:03          16395 Convert-MarkdownToHTML.html
>     -a----       15.09.2019     10:03          14714 Convert-MarkdownToHTMLFragment.html
>     -a----       15.09.2019     10:03           4612 Find-MarkdownFiles.html
>     -a----       15.09.2019     10:03           6068 MarkdownToHTML.html
>     ...          ...            ...            ...
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

* [https://wethat.github.io/MarkdownToHtml/2.5.0/Publish-StaticHtmlSite.html](https://wethat.github.io/MarkdownToHtml/2.5.0/Publish-StaticHtmlSite.html) 
* [`Convert-MarkdownToHTML`](Convert-MarkdownToHTML.md) 
* [`Find-MarkdownFiles`](Find-MarkdownFiles.md) 
* [`Convert-MarkdownToHTMLFragment`](Convert-MarkdownToHTMLFragment.md) 
* [`New-HTMLTemplate`](New-HTMLTemplate.md) 
* [Defining Content Mapping Rules](about_MarkdownToHTML.md#defining-content-mapping-rules)

---

<cite>Module: MarkDownToHTML; Version: 2.6.0; (c) 2018-2022 WetHat Lab. All rights reserved.</cite>

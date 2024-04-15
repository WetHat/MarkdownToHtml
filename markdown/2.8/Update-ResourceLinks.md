#  Update-ResourceLinks

> ## :bookmark: Synopsis
> Rewrite resource links which are relative to the projects root to make them
> valid for other site locations.

# Syntax
```PowerShell
 Update-ResourceLinks -InputObject <String> [-RelativePath <String>]  [<CommonParameters>] 
```


# Description

HTML templates use links which are relative to the HTML site root directory
to link to resources such as JavaScript, css, or image files. When a HTML
file is assembled (e.g with `[`Publish-StaticHtmlSite`](Publish-StaticHtmlSite.md)`) using such a template,
the resource links in the template may not be valid for the location of that
HTML file. This command uses the relative position of the new HTML file in the
site to compute valid resource links and update the template.





# Parameters
 ## -InputObject `<String>`
  >An html fragment containing root-relative resource links.
>
> Parameter Property         | Value
> --------------------------:|:----------
> Required?                  | true
> Position?                  | 1
> Default value              | ``
> Accept pipeline input?     | true (ByValue)
> Accept wildcard characters?| false
 - - -
 ## -RelativePath `<String>`
  >The path to a Markdown (`*.md`) or HTML (`*.html`) file relative to its root
 >directory. That file's relative path
 >is used to adjust the links of in the given navigation bar item,
 >so that it can be reached from the location of the HTML page currently being
 >assembled.
 >
 >The given path should use forward slash '/' path separators.
>
> Parameter Property         | Value
> --------------------------:|:----------
> Required?                  | false
> Position?                  | 2
> Default value              | ``
> Accept pipeline input?     | false
> Accept wildcard characters?| false



# Inputs
HTML fragments containing resource links relative to the HTML site root.


# Outputs
HTML fragment with updated resource links.

# Examples

## EXAMPLE 1

~~~ PowerShell
Update-ResourceLinks -HtmlFragment $fragment -RelativePath 'a/b/v/test.html'
~~~


Adjust link to a resource at `images/logo.png` so that it is valid for a
file located at `a/b/v/test.html`. The input `$fragment` is defined as:

~~~ PowerShell
$fragment = '<img width="90%" src="images/logo.png"/>'
~~~

Outut:

~~~ html
<img width="90%" src="../../../images/logo.png"/>
~~~














# Related Links

* [https://wethat.github.io/MarkdownToHtml/2.8/Update-ResourceLinks.html](https://wethat.github.io/MarkdownToHtml/2.8/Update-ResourceLinks.html) 
* [`Publish-StaticHtmlSite`](Publish-StaticHtmlSite.md)

- - -

_Module: [MarkDownToHTML](MarkDownToHTML.md); Version: 2.8.0; (c) 2018-2022 WetHat Lab. All rights reserved._

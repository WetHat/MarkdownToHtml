# ConvertTo-PageHeadingNavigation

Generate navigation specifications for specified headings found in an HTML
fragment.

# Syntax
```PowerShell
 ConvertTo-PageHeadingNavigation [-HTMLfragment] <String> [-NavTemplate] <Object> [-HeadingLevels] <String>  [<CommonParameters>] 
```


# Description


Generates a link specification for each heading in an HTML fragment which
* has an `id` attribute
* matches heading level constraint

The link specifications have the format required by [`ConvertTo-NavigationItem`](ConvertTo-NavigationItem.md)
to generate navigation bar items.





# Parameters

<blockquote>



## -HTMLfragment \<String\>

<blockquote>

HTML fragment to scan for headings.

---

Parameter Property         | Value
--------------------------:|:----------
Required?                  | true
Position?                  | 1
Default value              | ``
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>
 

## -NavTemplate \<Object\>

<blockquote>

An optional dictionary of the named HTML template needed to add a heading
link to the navigation bar.

+ :--------: + :----------: + ----------------------------------------
| Type       | Key          | HTML Template
+ ========== + ============ + ========================================
| Heading    | "navheading" | ~~~ html
| link       |              |<span class='navitem{{level}}'>{{navtext}}</span>"
| template   |              | ~~~
+ ---------- + ------------ + ----------------------------------------

The HTML template above is the value defined in
`Build.json`. That value is used if the given dictionary does not define the
"navheading" mapping or if no dictionary is given at all. Additional mappings
contained in the dictionary are ignored.

For more customization options see
[Static Site Project Customization](about_MarkdownToHTML.md#static-site-project-customization).

The css styles used in the template is defined in `md-styles.css`.

Following placeholders in the HTML template are recognized.

| Placeholder   | Description
| :-----------: | -----------
| `{{level}}`   | heading level.
| `{{navtext}}` | heading text

During the build process the placeholders are replaced with content taken from
the `NavSpec` parameter.

---

Parameter Property         | Value
--------------------------:|:----------
Required?                  | false
Position?                  | 2
Default value              | `$SCRIPT:defaultNavTemplate`
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>
 

## -HeadingLevels \<String\>

<blockquote>

A string of numbers denoting the levels of the headings to add to the navigation
bar. By default the headings at level 1,2 and 3 are added to the Navigation bar.
If headings should not be automatically added to the navigation bar, use the
empty string `''` for this parameter. If omitted, the default configuration
defined by option "capture_page_headings" in `Build.json` is used.

---

Parameter Property         | Value
--------------------------:|:----------
Required?                  | false
Position?                  | 3
Default value              | `123`
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>


</blockquote>


# Inputs
None. This function does not read from a pipe.


# Outputs
HTML elements representing navigation links to headings on the input HTML
fragment for use in a vertical navigation bar.

# Notes

<blockquote>

This function is typically used in the build script `Build.ps1` to define
the contents of the navigation bar (placeholder `{{nav}}`).

</blockquote>


# Examples


## EXAMPLE 1

> ~~~ PowerShell
> Hello World</h2>' -HeadingLevels '234'| ConvertTo-NavigationItem
> ~~~
>
> 
> Create an HTML element for navigation to page headings `<h2>`, `<h3>`, `<h4>`.
> All other headings are ignored.
> 
> Output:
> 
> ~~~ HTML
> <button class="navitem">
>    <a href="#bob"><span class="navitem2">Hello World</span></a>
> </button>
> ~~~
> 
> Note that the heading level has been added to the css class.
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
> Hello World</h2>' -NavTemplate $custom | ConvertTo-NavigationItem
> ~~~
>
> 
> Create an HTML element for navigation to an heading using the custom template `$custom`.
> 
> ~~~ PowerShell
>     $custom = @{ navheading = '<span class="li-item{{level}}">{{navtext}}</span>'}
> ~~~
> 
> Output:
> 
> ~~~ HTML
> <button class="navitem">
>     <a href="#bob"><span class="li-item2">Hello World</span></a>
> </button>
> ~~~
> 
> Note that the heading level is used as a postfix for the css class.
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

* [https://wethat.github.io/MarkdownToHtml/2.3.1/ConvertTo-PageHeadingNavigation.html](https://wethat.github.io/MarkdownToHtml/2.3.1/ConvertTo-PageHeadingNavigation.html) 
* [`New-StaticHTMLSiteProject`](New-StaticHTMLSiteProject.md) 
* [`ConvertTo-NavigationItem`](ConvertTo-NavigationItem.md)

---

<cite>Module: MarkDownToHTML; Version: 2.3.1; (c) 2018-2021 WetHat Lab. All rights reserved.</cite>

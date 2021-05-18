# ConvertTo-PageHeadingNavigation

Generate navigation specifications for all headings found in an HTML fragment.

# Syntax

<blockquote>

```PowerShell
 ConvertTo-PageHeadingNavigation [-HTMLfragment] <String> [-NavTemplate] <Object> [-HeadingLevels] <String>  [<CommonParameters>] 
```


</blockquote>

# Description

<blockquote>

Retrieves all headings (`h1`.. `h6`) from a HTML fragment and generates a link
specification for each heading that has an `id` attribute.

The link specifications have a format suitable for conversion to HTML
navigation code by `ConvertTo-NavigationItem`

</blockquote>

# Parameters

<blockquote>



## -HTMLfragment \<String\>

<blockquote>

HTML text to be scanned for headings.

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

A table of template html fragments with placeholders for:
* the heading text: placeholder `{{navtext}}`
* the heading level: placeholder `{{level}}`

The default template for page headings is:

~~~ html
<!-- navheading - auto-generated links to page headings -->
<span class="navitem{{level}}">{{navtext}}</span>
~~~

This template can also be configured in `Build.json`. See `New-StaticHTMLSiteProject` for more
details.

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
empty string `''` for this parameter.

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

<blockquote>

None. This function does not read from a pipe.

</blockquote>

# Outputs

<blockquote>

HTML elements representing navigation links to headings on the input HTML
fragment for use in a vertical navigation bar.

</blockquote>

# Notes

<blockquote>

This function is typically used in the build script `Build.ps1` to define
the contents of the navigation bar (placeholder `{{nav}}`).

</blockquote>

# Examples

<blockquote>


## EXAMPLE 1

```PowerShell
Hello World</h2>' -HeadingLevels '123'| ConvertTo-NavigationItem
```

Create an HTML element for navigation to page headings `<h1>`, `<h2>`, '<h3>'.
All other headings are ignored.

Output:

~~~ HTML
<button class="navitem">
   <a href="#bob"><span class="navitem2">Hello World</span></a>
</button>
~~~

Note that the heading level has been added to the css class. 
## EXAMPLE 2

```PowerShell
Hello World</h2>' -NavTemplate $custom | ConvertTo-NavigationItem
```

Create an HTML element for navigation to an heading using the custom template `$custom`.

~~~ PowerShell
    $custom = @{ navheading = '<span class="li-item{{level}}">{{navtext}}</span>'}
~~~

Output:

~~~ HTML
<button class="navitem">
    <a href="#bob"><span class="li-item2">Hello World</span></a>
</button>
~~~

Note that the heading level is used as a postfix for the css class.

</blockquote>

# Related Links

<blockquote>


* `New-StaticHTMLSiteProject` 
* `ConvertTo-NavigationItem`

</blockquote>

---

<cite>Module: MarkdownToHtml; Version: 2.3.0; (c) 2018-2021 WetHat Lab. All rights reserved.</cite>

# ConvertTo-PageHeadingNavigation

Generate navigation specifications for all headings found in an HTML fragment.

# Syntax
```PowerShell
 ConvertTo-PageHeadingNavigation [-HTMLfragment] <String>  [<CommonParameters>] 
```


# Description


Retrieves all headings (`h1`.. `h6`) from a HTML fragment and generates a link
specification for each heading that has an `id` attribute.

The link specifications have a format suitable for conversion to HTML
navigation code by [`ConvertTo-NavigationItem`](ConvertTo-NavigationItem.md)





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

<blockquote>


## EXAMPLE 1

```PowerShell
Hello World</h1>' | ConvertTo-NavigationItem
```


Create an HTML element for navigation for a heading. Output:

~~~ HTML
<button class='navitem'>
   <a href="#bob"><span class="navitem1">Hello World</span></a>
</button><br/>
~~~













</blockquote>

---

<cite>Module: MarkdownToHtml; Version: 2.2.2; (c) 2018-2020 WetHat Lab. All rights reserved.</cite>

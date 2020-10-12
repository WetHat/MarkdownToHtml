# ConvertTo-NavigationItem

Convert a navigation specification to a HTML element representing a navigation
link..

# Syntax
```PowerShell
 ConvertTo-NavigationItem [-NavSpec] <Object> [-RelativePath] <String>  [<CommonParameters>] 
```


# Description


Converts a navigation specification to an HTML an element representing a single
navigation line in a simple vertical navigation bar.

Following kinds of navigation links are supported:
* navigatable links
* separator lines
* labels (without link)

The generated HTML element is assigned to the class `navitem` to enable
styling in `md-styles.css`.





# Parameters

<blockquote>



## -NavSpec \<Object\>

<blockquote>

An object or hashtables with one NoteProperty or key. The property or key name
defines the link label, the associated value defines the link target location.

If the link target location of a specification item is the **empty string**, the
item has special meaning. If the name is the '---', a horizontal separator line
is generated. If it is just plain text (or a HTML fragment), a label without
clickable link is generated.

Parameter Property         | Value
--------------------------:|:----------
Required?                  | true
Position?                  | 1
Default value              | ``
Accept pipeline input?     | true (ByValue)
Accept wildcard characters?| false

</blockquote>
 

## -RelativePath \<String\>

<blockquote>

A path relative to the site root for the HTML document the navigation is to used
for. This relative path is used to adjust the relative links which may be
present in the link specification so that they work from the location of the
HTML page the navifation is build for. The given path should be in HTML notation
and is expected to use forward slash '/' path separators.

Parameter Property         | Value
--------------------------:|:----------
Required?                  | false
Position?                  | 2
Default value              | ``
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>


</blockquote>


# Inputs
Objects or hashtables with one NoteProperty or key.


# Outputs
HTML element representing one navigation item for use in a vertical navigation
bar.

# Notes

<blockquote>

This function is typically used in the build script `Build.ps1` to define
the contents of the navigation bar (placeholder `{{nav}}`).

</blockquote>

# Examples

<blockquote>


## EXAMPLE 1

```PowerShell
ConvertTo-NavigationItem @{'Project HOME'='https://github.com/WetHat/MarkdownToHtml'} -RelativePath 'into/about.md'
```


Generates a web navigation link to be put on the page `intro/about.md`. Note
the `RelativePath` is not needed for that link. OUtput:

~~~ html
<button class='navitem'>
    <a href="https://github.com/WetHat/MarkdownToHtml">Project HOME</a>
</button><br/>
~~~











 
## EXAMPLE 2

```PowerShell
ConvertTo-NavigationItem @{'Index'='index.md'} -RelativePath 'intro/about.md'
```


Generates a relative navigation link to be put on the page `into/about.md`. The
link target is another page `index.md` on the same site, hence the link is
adjusted accordingly.

Output:

~~~ html
<button class='navitem'>
    <a href="../index.html">Index</a>
</button><br/>
~~~











 
## EXAMPLE 3

```PowerShell
ConvertTo-NavigationItem @{'---'=''} -RelativePath 'intro/about.md'
```


Generates a separator line. Note that the `RelativePath` is not used.

Output:

~~~ html
<hr class="navitem" />
~~~











 
## EXAMPLE 4

```PowerShell
ConvertTo-NavigationItem @{'Introduction'=''} -RelativePath 'intro/about.md'
```


Generates a label. Note that the `RelativePath` is not used.

Output:

~~~ html
<div class='navitem'>Introduction</div>
~~~













</blockquote>

---

<cite>Module: MarkdownToHtml; Version: 2.2.2; (c) 2018-2020 WetHat Lab. All rights reserved.</cite>

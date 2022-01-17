# ConvertTo-NavigationItem

Convert a navigation specification to a single item in a navigation bar of pages
in a static HTML site project created by `New-StaticHTMLSiteProject`.

# Syntax
```PowerShell
 ConvertTo-NavigationItem [-NavSpec] <Object> [-RelativePath] <String> [-NavTemplate] <Object>  [<CommonParameters>] 
```


# Description


Converts the specification for a single item in the navigation bar by
* finding an HTML template to represent the item in the navigation bar.
* replacing placeholders in the template by data taken from the
  specification.
* adjusting the navigation link based on the location in the directory tree.





# Parameters

<blockquote>



## -NavSpec \<Object\>

<blockquote>

An object or dictionary with exactly one `NoteProperty` or key representing
a single key-value pair. This parameter provides the data for one item in
the navigation bar.

Following key-value pairs are recognized:

+ :----: + :---: + :--------: + ---------------------------------------------- +
| Key    | Value | Template   | Description
|        |       | Name       |
+ ====== + ===== + ========== + ============================================== +
|"_text_"|"_url_"| navitem    | A clickable hyperlink where _text_ is the link
|        |       |            | text and _url_ a link to a web page or a local
|        |       |            | Markdown file. Local file links must be
|        |       |            | relative to the project root.
+ ------ + ----- + ---------- + ---------------------------------------------- +
|"_text_"| ""    | navlabel   | A label without hyperlink.
+ ------ + ----- + ---------- + ---------------------------------------------- +
| "---"  | ""    |navseparator| A speparator line.
+ ------ + ----- + ---------- + ---------------------------------------------- +

The structure of the data determines the type of navigation bar item to build.
The table above maps supported key-value combinations to the associated named
HTML templates.

---

Parameter Property         | Value
--------------------------:|:----------
Required?                  | false
Position?                  | 1
Default value              | ``
Accept pipeline input?     | true (ByValue)
Accept wildcard characters?| false

</blockquote>
 

## -RelativePath \<String\>

<blockquote>

The path to a Markdown (`*.md`) or HTML (`*.html`) file relative to its
corresponding root configured in `Build.json`. For Markdown files the
root is configured by parameter `"markdown_dir"` for html files it is
`"site_dir"`. This parameter will be used to compute relative resource
and navigation bar links for the HTML page currently
being assembled.

The given path should use forward slash '/' path separators.

---

Parameter Property         | Value
--------------------------:|:----------
Required?                  | false
Position?                  | 2
Default value              | ``
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>
 

## -NavTemplate \<Object\>

<blockquote>

An optional dictionary of named HTML templates.

+ :--------: + :----------: + ----------------------------------------
| Type       | Key          | HTML Template
+ ========== + ============ + ========================================
| clickable  | "navitem"    | ~~~ html
| link       |              | <button class='navitem'>
|            |              |     <a href='{{navurl}}'>{{navtext}}</a>
|            |              | </button>
|            |              | ~~~
+ ---------- + ------------ + ----------------------------------------
| label (no  | "navlabel"   | ~~~ html
| link)      |              | <div class='navlabel'>{{navtext}}</div>
|            |              | ~~~
+ ---------- + ------------ + ----------------------------------------
| separator  |"navseparator"| ~~~ html
|            |              | <hr/>
|            |              | ~~~
+ ---------- + ------------ + ----------------------------------------

The HTML templates listed represent are the values configured in `Build.json`.
These values are used for keys not provided in the given dictionary or if no
dictionary is given at all.  Additional mappings contained in dictionary are
ignored.

For more customization options see
[Static Site Project Customization](about_MarkdownToHTML.md#static-site-project-customization).

The css styles used in the templates are defined in `md-styles.css`.

During the build process the placeholders contained in the HTML template
are replaced with content extracted from the `NavSpec` parameter .

| Placeholder   | Description
| :-----------: | -----------
| `{{navurl}}`  | hyperlink to web-page or local file.
| `{{navtext}}` | link or label text

---

Parameter Property         | Value
--------------------------:|:----------
Required?                  | false
Position?                  | 3
Default value              | `$defaultNavTemplate`
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


## EXAMPLE 1

> ~~~ PowerShell
> ConvertTo-NavigationItem @{'Project HOME'='https://github.com/WetHat/MarkdownToHtml'} -RelativePath 'intro/about.md'
> ~~~
>
> 
> Generates a web navigation link to be put on the page `intro/about.md`.
> Note:
> the parameter `RelativePath` is specified but not used because the link is
> non-local.
> 
> Output:
> 
> ~~~ html
> <button class='navitem'>
>     <a href="https://github.com/WetHat/MarkdownToHtml">Project HOME</a>
> </button><br/>
> ~~~
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
> ConvertTo-NavigationItem @{'Index'='index.md'} -RelativePath 'intro/about.md'
> ~~~
>
> 
> Generates a navigation link relative to `intro/about.md`. The
> link target `index.md` is a page at the root of the same site, hence the link is
> adjusted accordingly.
> 
> Output:
> 
> ~~~ html
> <button class="navitem">
>     <a href="../index.html">Index</a>
> </button>
> ~~~
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
> ConvertTo-NavigationItem @{'Index'='index.md'} -RelativePath 'intro/about.md' -NavTemplate $custom
> ~~~
>
> 
> Generates a navigation link relative to `intro/about.md`.
> A custom template definition `$custom` is used:
> 
> ~~~ PowerShell
>     $custom = @{ navitem = '<li class="li-item"><a href="{{navurl}}">{{navtext}}</a></li>'}
> ~~~
> 
> The link target `index.md` is a page at the root of the same site, hence the link is
> adjusted accordingly.
> 
> Output:
> 
> ~~~ html
> <li class="li-item">
>     <a href="../index.html">Index</a>
> </li>
> ~~~
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
> ConvertTo-NavigationItem @{'---'=''} -RelativePath 'intro/about.md'
> ~~~
>
> 
> Generates a separator line in the navigation bar. The _RelativePath_ parameter
> is not used (the specification does not contain a link).
> 
> Output:
> 
> ~~~ html
> <hr class="navitem" />
> ~~~
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
 
## EXAMPLE 5

> ~~~ PowerShell
> ConvertTo-NavigationItem @{'---'=''} -NavTemplate $custom
> ~~~
>
> 
> Generates a separator line in the navigation bar using a custom template `$custom`:
> 
> ~~~ PowerShell
>     $custom = @{ navseparator = '<hr class="li-item" />'}
> ~~~
> 
> Output:
> 
> ~~~ html
> <hr class="li-item" />
> ~~~
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
 
## EXAMPLE 6

> ~~~ PowerShell
> ConvertTo-NavigationItem @{'Introduction'=''}
> ~~~
>
> 
> Generates a label in the navigation bar.
> 
> Output:
> 
> ~~~ html
> <div class='navitem'>Introduction</div>
> ~~~
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
 
## EXAMPLE 7

> ~~~ PowerShell
> ConvertTo-NavigationItem @{'Introduction'=''} -NavTemplate $custom
> ~~~
>
> 
> Generates a label in the navigation bar using the custom template `$custom`:
> 
> ~~~ PowerShell
>     $custom = @{ navlabel = '<div class='li-item'>Introduction</div>'}
> ~~~
> 
> Output:
> 
> ~~~ html
> <div class='li-item'>Introduction</div>
> ~~~
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

* [https://wethat.github.io/MarkdownToHtml/2.6/ConvertTo-NavigationItem.html](https://wethat.github.io/MarkdownToHtml/2.6/ConvertTo-NavigationItem.html) 
* [`New-StaticHTMLSiteProject`](New-StaticHTMLSiteProject.md) 
* [`New-PageHeadingNavigation`](New-PageHeadingNavigation.md)

---

<cite>Module: MarkDownToHTML; Version: 2.6.0; (c) 2018-2022 WetHat Lab. All rights reserved.</cite>

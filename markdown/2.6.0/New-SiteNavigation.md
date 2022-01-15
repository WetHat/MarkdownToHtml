# New-SiteNavigation

Build navigation bar content for a HTML page from a specification and
redering templates

# Syntax
```PowerShell
 New-SiteNavigation [-NavitemSpecs] <Object[]> [-RelativePath] <String> [-NavTemplate] <Object>  [<CommonParameters>] 
```


# Description


A navigation bar section for a HTML page is built by:
* processing a list of item specification which define the navigation bar
  content
* picking the appropriate HTML template for each navigation bar item
  and expanding the template using data from the item specification





# Parameters

<blockquote>



## -NavitemSpecs \<Object[]\>

<blockquote>

An array where each item án object or dictionary with exactly one `NoteProperty`
or key representing a single key-value pair. This parameter provides the data
for one item in the navigation bar.

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
Required?                  | true
Position?                  | 1
Default value              | ``
Accept pipeline input?     | false
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
None


# Outputs
HTML fragment for a navigation bar.

# Examples


## EXAMPLE 1

> ~~~ PowerShell
> New-SiteNavigation -NavitemSpecs $specs -RelativePath 'a/b/c/bob.md'
> ~~~
>
> 
> Create navigation content for a file with relative path `a/b/c/bob.md` and
> the specification `$specs` and default templates:
> 
> `$specs` is defined like so:
> 
> ~~~PowerShell
> $specs = @(
>     @{ "<img width='90%' src='logo.png' />" = "README.md" },
>     @{ "README" = "" },
>     @{ "Home" = "README.md" },
>     @{ "---" = "" }
> )
> ~~~
> 
> Output:
> 
> ~~~ html
> <button class="navitem">
>    <a href="../../../README.html">
>       <img width='90%' src='../../../logo.png' />
>    </a>
> </button>
> <div class="navlabel">README</div>
> <button class="navitem">
>    <a href="../../../README.html">Home</a>
> </button>
> <hr/>
> ~~~
> 
> Note how the relative path parameter was used to update the links.
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

* [https://wethat.github.io/MarkdownToHtml/2.5.0/New-SiteNavigation.html](https://wethat.github.io/MarkdownToHtml/2.5.0/New-SiteNavigation.html)

---

<cite>Module: MarkDownToHTML; Version: 2.6.0; (c) 2018-2022 WetHat Lab. All rights reserved.</cite>

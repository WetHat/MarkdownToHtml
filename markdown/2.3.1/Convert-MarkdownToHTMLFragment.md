# Convert-MarkdownToHTMLFragment

Convert Markdown text to html fragments.

# Syntax
```PowerShell
 Convert-MarkdownToHTMLFragment [-InputObject] <Object> [-IncludeExtension] <String[]> [-ExcludeExtension] <String[]>  [<CommonParameters>] 
```


# Description


Converts Markdown text to HTML fragments using configured Markdown parser extensions.





# Parameters

<blockquote>



## -InputObject \<Object\>

<blockquote>

The input object can have one of the following of types:
* An annotated `[System.IO.FileInfo]` object as emitted by [[`Find-MarkdownFiles`](Find-MarkdownFiles.md)](Find-MarkdownFiles.md).
* A plain markdown string [`string`].
* A markdown descriptor object which is basically a [`hashtable`] whith following contents:

  | Key            | Value Type | Description                                              |
  | :------------- | :--------- | :------------------------------------------------------- |
  | `Markdown`     | [`string`] | The markdown text.                                       |
  | `RelativePath` | [`string`] | Relative path of the html file below the site directory. |

Parameter Property         | Value
--------------------------:|:----------
Required?                  | true
Position?                  | 1
Default value              | ``
Accept pipeline input?     | true (ByValue)
Accept wildcard characters?| false

</blockquote>
 

## -IncludeExtension \<String[]\>

<blockquote>

Comma separated list of Markdown parsing extension names.
See [about_MarkdownToHTML](about_MarkdownToHTML.md#markdown-extensions) for an
annotated list of supported extensions.

Parameter Property         | Value
--------------------------:|:----------
Required?                  | false
Position?                  | 2
Default value              | `@('advanced')`
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>
 

## -ExcludeExtension \<String[]\>

<blockquote>

Comma separated list of Markdown parsing extensions to exclude.
Mostly used when the the 'advanced' parsing option is included and
certain individual options need to be removed.

Parameter Property         | Value
--------------------------:|:----------
Required?                  | false
Position?                  | 3
Default value              | `@()`
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>


</blockquote>


# Inputs
Markdown text `[string]`, Markdown file `[System.IO.FileInfo]`, or a markdown descriptor `[hashtable]`.


# Outputs
HTML fragment object with following properties:

| Property       | Description                                                     |
| :------------: | :-------------------------------------------------------------- |
| `Title`        | Optional page title. The first heading in the Markdown content. |
| `HtmlFragment` | The HTML fragment string generated from the Markdown text.      |
| `RelativePath` | Passed through form the input object, provided it exists.       |

# Notes

<blockquote>

The conversion to HTML fragments also includes:

* Changing links to Markdown files to the corresponding Html files.

  ~~~ Markdown
  [Hello World](Hello.md)
  ~~~

  becomes:

  ~~~ html
  <a href="Hello.html">
  ~~~

* HTML encoding code blocks:

  ~~~ Markdown

  ```xml
  <root>
      <thing/>
  </root>

  ```
  ~~~

  becomes

  ~~~ HTML
  <pre><code class="language-xml">&lt;root&gt;
      &lt;thing/&gt;
  &lt;/root&gt;

  </code></pre>
  ~~~

  which renders as

  ```xml
  <root>
      <thing/>
  </root>

  ```

</blockquote>

# Examples

## EXAMPLE 1

<blockquote>

```PowerShell
Convert-MarkdownToHTMLFragment -Markdown '# Hello World'
```


Returns the HTML fragment object:

    Name               Value
    ----               -----
    HtmlFragment       <h1 id="hello-world">Hello World</h1>...
    Title              Hello World













</blockquote>
 ## EXAMPLE 2

<blockquote>

```PowerShell
Get-Item -LiteralPath "Convert-MarkdownToHTML.md" | Convert-MarkdownToHTMLFragment
```


Reads the content of Markdown file `Example.md` and returns a Html fragment object.

    Name               Value
    ----               -----
    Title              Convert-MarkdownToHTML
    HtmlFragment       <h1 id="convert-Markdowntohtml">Convert-MarkdownToHTML</h1>...
    RelativePath       Convert-MarkdownToHTML.md













</blockquote>


# Related Links

* [https://wethat.github.io/MarkdownToHtml/2.3.1/Convert-MarkdownToHTMLFragment.html](https://wethat.github.io/MarkdownToHtml/2.3.1/Convert-MarkdownToHTMLFragment.html) 
* [`Convert-MarkdownToHTML`](Convert-MarkdownToHTML.md) 
* [`Find-MarkdownFiles`](Find-MarkdownFiles.md) 
* [`Publish-StaticHtmlSite`](Publish-StaticHtmlSite.md) 
* [`New-HTMLTemplate`](New-HTMLTemplate.md)

---

<cite>Module: MarkDownToHTML; Version: 2.3.1; (c) 2018-2021 WetHat Lab. All rights reserved.</cite>

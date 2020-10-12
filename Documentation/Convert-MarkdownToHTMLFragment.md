# Convert-MarkdownToHTMLFragment

Convert Markdown text to html fragments.

# Syntax
```PowerShell
 Convert-MarkdownToHTMLFragment [-InputObject] <Object> [-IncludeExtension] <String[]> [-ExcludeExtension] <String[]>  [<CommonParameters>] 
```


# Description


Converts Markdown text to HTML fragments using configured Markdown parser extensions.

A parser configuration is a comma separated list of configuration option strings. Currently
avaliable extensions are:

* 'abbreviations': [Abbreviations ](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/AbbreviationSpecs.md)
* 'advanced': advanced parser configuration. A pre-build collection of extensions including:
  * 'abbreviations'
  * 'autoidentifiers'
  * 'citations'
  * 'customcontainers'
  * 'definitionlists'
  * 'emphasisextras'
  * 'figures'
  * 'footers'
  * 'footnotes'
  * 'gridtables'
  * 'mathematics'
  * 'medialinks'
  * 'pipetables'
  * 'listextras'
  * 'tasklists'
  * 'diagrams'
  * 'autolinks'
  * 'attributes'
* 'attributes': [Special attributes](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/GenericAttributesSpecs.md).
   Set HTML attributes (e.g `id` or class`).
* 'autoidentifiers': [Auto-identifiers](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/AutoIdentifierSpecs.md).
`  Allows to automatically creates an identifier for a heading.
* 'autolinks': [Auto-links](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/AutoLinks.md)
   generates links if a text starts with `http://` or `https://` or `ftp://` or `mailto:` or `www.xxx.yyy`.
* 'bootstrap': [Bootstrap](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/BootstrapSpecs.md)
   to output bootstrap classes.
* 'citations': [Citation text](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FigureFooterAndCiteSpecs.md)
   by enclosing text with `''...''`
* 'common': CommonMark parsing; no parser extensions (default)
* 'customcontainers': [Custom containers](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/CustomContainerSpecs.md)
  similar to fenced code block `:::` for generating a proper `<div>...</div>` instead.
* 'definitionlists': [Definition lists](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/DefinitionListSpecs.md)
* 'diagrams': [Diagrams](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/DiagramsSpecs.md)
  whenever a fenced code block uses the 'mermaid' keyword, it will be converted to a div block with the content as-is
  (currently, supports `mermaid` and `nomnoml` diagrams). Resources for the `mermaid` diagram generator are pre-installed and configured.
  See [New-HTMLTemplate](New-HTMLTemplate.md) for customization details.
* 'emojis': [Emoji](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/EmojiSpecs.md) support
* 'emphasisextras': [Extra emphasis](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/EmphasisExtraSpecs.md)
   * strike through `~~`,
   * Subscript `~`
   * Superscript `^`
   * Inserted `++`
   * Marked `==`
* 'figures': [Figures](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FigureFooterAndCiteSpecs.md).
  A figure can be defined by using a pattern equivalent to a fenced code block but with the character `^`.
* 'footers': [Footers](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FigureFooterAndCiteSpecs.md)
* 'footnotes': [Footnotes](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/FootnotesSpecs.md)
* 'globalization': [https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/GlobalizationSpecs.md]
  Adds support for RTL (Right To Left) content by adding `dir="rtl"` and `align="right"` attributes to
  the appropriate html elements. Left to right text is not affected by this extension.
* 'gridtables': [Grid tables](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/GridTableSpecs.md)
  allow to have multiple lines per cells and allows to span cells over multiple columns.
* 'hardlinebreak': [Soft lines](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/HardlineBreakSpecs.md)
   as hard lines
* 'listextras': [Extra bullet lists](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/ListExtraSpecs.md),
   supporting alpha bullet a. b. and roman bullet (i, ii...etc.)
* 'mathematics': [Mathematics](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/MathSpecs.md)
  LaTeX extension by enclosing `$$` for block and `$` for inline math. Resources for this extension are pre-installed and configured.
  See [New-HTMLTemplate](New-HTMLTemplate.md) for customization details.
* 'medialinks': [Media support](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/MediaSpecs.md)
  for media urls (youtube, vimeo, mp4...etc.)
* 'nofollowlinks': Add `rel=nofollow` to all links rendered to HTML.
* 'nohtml': [NoHTML](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/NoHtmlSpecs.md)
   allows to disable the parsing of HTML.
* 'nonascii-noescape': Use this extension to disable URI escape with % characters for non-US-ASCII characters in order to
   workaround a bug under IE/Edge with local file links containing non US-ASCII chars. DO NOT USE OTHERWISE.
* 'pipetables': [Pipe tables](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/PipeTableSpecs.md)
  to generate tables from markup.
* 'smartypants': [SmartyPants](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/SmartyPantsSpecs.md)
  quotes.
* 'tasklists': [Task Lists](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/TaskListSpecs.md).
  A task list item consist of `[ ]` or `[x]` or `[X]` inside a list item (ordered or unordered)
* 'yaml': [YAML frontmatter](https://github.com/lunet-io/markdig/blob/master/src/Markdig.Tests/Specs/YamlSpecs.md)
  parsing.





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

Comma separated list of Markdown parsing extensions to use.

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

<blockquote>

~~~ Markdown
[Hello World](Hello.md)
~~~

becomes:

~~~ html
<a href="Hello.html">
~~~

</blockquote>

* HTML encoding code blocks:

<blockquote>

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

</blockquote>

which renders as

```xml
<root>
    <thing/>
</root>

```

</blockquote>

# Examples

<blockquote>


## EXAMPLE 1

```PowerShell
Convert-MarkdownToHTMLFragment -Markdown '# Hello World'
```


Returns the HTML fragment object:

    Name               Value
    ----               -----
    HtmlFragment       <h1 id="hello-world">Hello World</h1>...
    Title              Hello World











 
## EXAMPLE 2

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

* [https://github.com/WetHat/MarkdownToHtml/blob/master/Documentation/Convert-MarkdownToHTMLFragment.md](https://github.com/WetHat/MarkdownToHtml/blob/master/Documentation/Convert-MarkdownToHTMLFragment.md) 
* [`Convert-MarkdownToHtml`](Convert-MarkdownToHtml.md) 
* [`Find-MarkdownFiles`](Find-MarkdownFiles.md) 
* [`Publish-StaticHtmlSite`](Publish-StaticHtmlSite.md) 
* [`New-HTMLTemplate`](New-HTMLTemplate.md)

---

<cite>Module: MarkdownToHtml; Version: 2.2.2; (c) 2018-2020 WetHat Lab. All rights reserved.</cite>

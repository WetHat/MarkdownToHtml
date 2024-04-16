#  Convert-MarkdownToHTMLFragment

> ## :bookmark: Synopsis
> Convert Markdown text to HTML fragments.

# Syntax
```PowerShell
 Convert-MarkdownToHTMLFragment -InputObject <Object> [-IncludeExtension <String[]>] [-ExcludeExtension <String[]>] [-Split <object>]  [<CommonParameters>] 
```


# Description

Converts Markdown text to HTML fragments using configured
[Markdown extensions](about_MarkdownToHTML.md#supported-markdown-extensions).





# Parameters
 ## -InputObject `<Object>`
  >The input object can have one of the following types:
 >* An annotated `[System.IO.FileInfo]` object as emitted by [`Find-MarkdownFiles`](Find-MarkdownFiles.md).
 >* A plain markdown string [`string`].
 >* A markdown descriptor object which is a [`hashtable`] with following contents:
 >
 >  | Key                      | Value Type         | Description                                                   |
 >  | :----------------------- | :----------------- | :------------------------------------------------------------ |
 >  | `Markdown`               | [`string`]         | The markdown text.                                            |
 >  | `RelativePath`           | [`string`]         | Relative path of the Markdown file below the input directory. |
 >  | `EffectiveConfiguration` | [`PSCustomObject`] | Optional: Build configuration in effect for this fragment     |
>
> Parameter Property         | Value
> --------------------------:|:----------
> Required?                  | true
> Position?                  | 1
> Default value              | ``
> Accept pipeline input?     | true (ByValue)
> Accept wildcard characters?| false
 - - -
 ## -IncludeExtension `<String[]>`
  >Comma separated list of Markdown parsing extension names.
 >See [Markdown extensions](about_MarkdownToHTML.md#supported-markdown-extensions)
 >for an annotated list of supported extensions.
>
> Parameter Property         | Value
> --------------------------:|:----------
> Required?                  | false
> Position?                  | 2
> Default value              | `@('advanced')`
> Accept pipeline input?     | false
> Accept wildcard characters?| false
 - - -
 ## -ExcludeExtension `<String[]>`
  >Comma separated list of Markdown parsing extensions to exclude.
 >Mostly used when the the 'advanced' parsing option is included and
 >certain individual options need to be removed.
>
> Parameter Property         | Value
> --------------------------:|:----------
> Required?                  | false
> Position?                  | 3
> Default value              | `@()`
> Accept pipeline input?     | false
> Accept wildcard characters?| false
 - - -
 ## -Split `<SwitchParameter>`
  >Split the Html fragment into an Array where each tag is in a separate slot.
 >This somewhat simplifies Html fragment post-processing.
 >
 >For example the fragment
 >
 >~~~ html
 ><pre><code class="language-PowerShell">PS&gt; Install-Module -Name MarkdownToHTML</pre></code>
 >~~~
 >
 >is split up into the array
 >
 >| Index | Value                                        |
 >| :---: | :------------------------------------------- |
 >| 0     | `<pre>`                                      |
 >| 1     | `<code class="language-PowerShell">`         |
 >| 2     | `PS&gt; Install-Module -Name MarkdownToHTML` |
 >| 3     | `</pre>`                                     |
 >| 4     | `</code>`                                    |
>
> Parameter Property         | Value
> --------------------------:|:----------
> Required?                  | false
> Position?                  | named
> Default value              | `False`
> Accept pipeline input?     | false
> Accept wildcard characters?| false



# Inputs
Markdown text `[string]`, Markdown file `[System.IO.FileInfo]`,
or a markdown descriptor `[hashtable]`.


# Outputs
HTML fragment object with following properties:

| Property                 | Description                                                         |
| :----------------------: | :------------------------------------------------------------------ |
| `Title`                  | Optional page title. The first heading in the Markdown content.     |
| `HtmlFragment`           | The HTML fragment string or array generated from the Markdown text. |
| `RelativePath`           | Passed through from the input object, provided it exists.           |
| `EffectiveConfiguration` | Passed through from the input object, provided it exists.           |

# Notes

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


# Examples

## EXAMPLE 1

~~~ PowerShell
Convert-MarkdownToHTMLFragment -Markdown '# Hello World'
~~~


Returns the HTML fragment object:

    Name               Value
    ----               -----
    HtmlFragment       <h1 id="hello-world">Hello World</h1>...
    Title              Hello World












 ## EXAMPLE 2

~~~ PowerShell
Convert-MarkdownToHTMLFragment -Markdown '# Hello World' -Split
~~~


Returns the HTML fragment object:

    Name               Value
    ----               -----
    HtmlFragment       {<h1 id="hello-world">,Hello World,</h1>,...}
    Title              Hello World












 ## EXAMPLE 3

~~~ PowerShell
Get-Item -LiteralPath "Convert-MarkdownToHTML.md" | Convert-MarkdownToHTMLFragment
~~~


Reads the content of Markdown file `Example.md` and returns a Html fragment object.

    Name               Value
    ----               -----
    Title              Convert-MarkdownToHTML
    HtmlFragment       <h1 id="convert-Markdowntohtml">Convert-MarkdownToHTML</h1>...
    RelativePath       Convert-MarkdownToHTML.md














# Related Links

* [https://wethat.github.io/MarkdownToHtml/2.8/Convert-MarkdownToHTMLFragment.html](https://wethat.github.io/MarkdownToHtml/2.8/Convert-MarkdownToHTMLFragment.html) 
* [`Convert-MarkdownToHTML`](Convert-MarkdownToHTML.md) 
* [`Convert-SvgbobToSvg`](Convert-SvgbobToSvg.md) 
* [`Find-MarkdownFiles`](Find-MarkdownFiles.md) 
* [`Publish-StaticHtmlSite`](Publish-StaticHtmlSite.md) 
* [`New-HTMLTemplate`](New-HTMLTemplate.md) 
* [Markdown extensions](about_MarkdownToHTML.md#supported-markdown-extensions)

- - -

_Module: [MarkDownToHTML](MarkDownToHTML.md); Version: 2.8.0; (c) 2018-2024 WetHat Lab. All rights reserved._

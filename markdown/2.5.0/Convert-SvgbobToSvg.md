# Convert-SvgbobToSvg

Convert fenced svgbob code blocks to svg images.

# Syntax
```PowerShell
 Convert-SvgbobToSvg [-MarkdownLine] <String> [-SiteDirectory] <String> [-RelativePath] <String> [-Options] <Object>  [<CommonParameters>] 
```


# Description


Scans the input data (lines of Markdown text) for svgbob fenced code blocks
and converts them to a Markdown style image link to a svg file containing
the rendered diagram.

Svgbob code blocks define human readable diagrams and are labeled as `bob`.
For example:

~~~ Markdown
˜˜˜ bob
      +------+   .-.   +---+
 o----| elem |--( ; )--| n |----o
      +------+   '-'   +---+
˜˜˜
~~~

The generated svg file is put right next to the HTML file
currently being assembled and named after that HTML file with an unique
index appended.





# Parameters

<blockquote>



## -MarkdownLine \<String\>

<blockquote>



---

Parameter Property         | Value
--------------------------:|:----------
Required?                  | true
Position?                  | 1
Default value              | ``
Accept pipeline input?     | true (ByValue)
Accept wildcard characters?| false

</blockquote>
 

## -SiteDirectory \<String\>

<blockquote>

Location of the static HTML site. The Svg file will be generated relative to this
path.

---

Parameter Property         | Value
--------------------------:|:----------
Required?                  | true
Position?                  | 2
Default value              | ``
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>
 

## -RelativePath \<String\>

<blockquote>

Svg file path relative to `SiteDirectory`.

---

Parameter Property         | Value
--------------------------:|:----------
Required?                  | true
Position?                  | 3
Default value              | ``
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>
 

## -Options \<Object\>

<blockquote>

Svg conversion options. An object or hashtable with follwing properties or keys:

| Property       | Description                                  |
| :------------: | :------------------------------------------- |
| `background`   | Diagram background color (default: white)    |
| `fill_color`   | Fill color for solid shapes (default: black) |
| `font_family`  | Text font (default: monospace)               |
| `font_size`    | Text font size (default 14)                  |
| `scale`        | Diagram scale (default: 1)                   |
| `stroke_width` | Stroke width for all lines (default: 2)      |

When using conversion projects instantiated by [`New-StaticHTMLSiteProject`](New-StaticHTMLSiteProject.md) these
parameters are configured in `Build.json` parameter section `svgbob`.

---

Parameter Property         | Value
--------------------------:|:----------
Required?                  | false
Position?                  | 4
Default value              | ``
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>


</blockquote>


# Inputs
Lines of Markdown text.


# Outputs
Lines of Markdown text where all fenced code blocks labelled `bob` are
replaced by Markdown style image links to svg files.

# Notes

<blockquote>

The svg conversion is performed by the external utility
`svgbob.exe` which is packaged with this module.

</blockquote>


# Examples


## EXAMPLE 1

> ~~~ PowerShell
> Get-Content $md -Encoding UTF8 | Convert-SvgbobToSvg -SiteDirectory $site -RelativePath $relativePath
> ~~~
>
> 
> Read Markdown content from the file `$md` and replace all fenced code blocks
> marled as `bob` with Markdown style image links to the svg version of the
> diagram. The conversion is performed using default svg rendering options.
> 
> Where
> 
> `$site`
> :   Is the **absolute path** to the HTML site's root directory
> 
> `$relativePath`
> :   is the **relative path** of the HTML file currently being assembled below
>     `$site`.
> 
> `$md`
> :   represents a file named `test.md` which contains a fenced svgbob diagram.
>     ~~~ Markdown
>     Some text ...
> 
>     ˜˜˜ bob
>           +------+   .-.   +---+
>      o----| elem |--( ; )--| n |----o
>           +------+   '-'   +---+
>     ˜˜˜
> 
>     Some more text ...
>     ~~~
> 
> this is converted to:
> 
> ~~~ Markdown
> Some text ...
> 
> ![Diagram 1.](test1.svg)
> 
> Some more text ...
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

* [https://wethat.github.io/MarkdownToHtml/2.5.0/Convert-SvgbobToSvg.html](https://wethat.github.io/MarkdownToHtml/2.5.0/Convert-SvgbobToSvg.html) 
* [Svgbob](https://ivanceras.github.io/svgbob-editor/)

---

<cite>Module: MarkDownToHTML; Version: 2.5.0; (c) 2018-2021 WetHat Lab. All rights reserved.</cite>

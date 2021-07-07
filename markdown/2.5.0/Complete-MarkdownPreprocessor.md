# Complete-MarkdownPreprocessor

Wrap up markdown preprocessing.

# Syntax
```PowerShell
 Complete-MarkdownPreprocessor [-MarkdownLine] <String> [-RelativePath] <String>  [<CommonParameters>] 
```


# Description


Consolidates the preprocessed Markdown data for the downstream conversion
pipeline.





# Parameters

<blockquote>



## -MarkdownLine \<String\>

<blockquote>

One line of Markdown text.

---

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
Required?                  | true
Position?                  | 2
Default value              | ``
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>


</blockquote>


# Inputs
Lines of Markdown text.


# Outputs
A Markdown descriptor object `[hashtable]` with these properties:

| Key            | Value Type | Description                                 |
| :------------- | :--------- | :------------------------------------------ |
| `Markdown`     | [`string`] | The markdown text.                          |
| `RelativePath` | [`string`] | Relative path of the Markdown or html file. |

# Examples


## EXAMPLE 1

> ~~~ PowerShell
> Get-Content $md -Encoding UTF8 | Convert-X ... | Complete-MarkdownPreprocessor -RelativePath $md.RelativePath
> ~~~
>
> 
> Preprocess Markdown data from a file `$md` using a custom preprocessing function
> [`Convert-X`](Convert-X.md). The preprocessed Markdown data is finally re-packaged to further
> pipeline processing by [`Complete-MarkdownPreprocessor`](Complete-MarkdownPreprocessor.md). `$md` is an _annotated_
> `[System.IO.FileInfo]` object whch is either output by [`Find-MarkdownFiles`](Find-MarkdownFiles.md)
> or assembled by custom code.
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

* [https://wethat.github.io/MarkdownToHtml/2.5.0/Complete-MarkdownPreprocessor.html](https://wethat.github.io/MarkdownToHtml/2.5.0/Complete-MarkdownPreprocessor.html) 
* [`Convert-SvgbobToSvg`](Convert-SvgbobToSvg.md) 
* [`Find-MarkdownFiles`](Find-MarkdownFiles.md)

---

<cite>Module: MarkDownToHTML; Version: 2.5.0; (c) 2018-2021 WetHat Lab. All rights reserved.</cite>

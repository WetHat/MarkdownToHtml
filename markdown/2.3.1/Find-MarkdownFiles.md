# Find-MarkdownFiles

Find all Markdown file below a given directory.

# Syntax
```PowerShell
 Find-MarkdownFiles [-Path] <String> [-Exclude] <String[]>  [<CommonParameters>] 
```


# Description


Recursively scans a directory and generates annotated `[System.IO.FileInfo]`
objects for each Markdown file.

The annotation is a `NoteProperty` named `RelativePath`. It contains the
relative path of the Markdown file below the given directory.





# Parameters

<blockquote>



## -Path \<String\>

<blockquote>

Path to a directory containing Markdown files.

---

Parameter Property         | Value
--------------------------:|:----------
Required?                  | true
Position?                  | 1
Default value              | ``
Accept pipeline input?     | false
Accept wildcard characters?| true

</blockquote>
 

## -Exclude \<String[]\>

<blockquote>

Omit the specified files. Enter comma separated list of path elements or
patterns, such as "D*.md". Wildcards are permitted.

---

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
None


# Outputs
An `[System.IO.FileInfo]` object for each Markdown file found below
the given directory. The emitted
`[System.IO.FileInfo]` objects are annotated with a `NoteProperty` named
`RelativePath` which specifies the relative path of the Markdown file below the
given directory. The `RelativePath` property is
**mandatory** if `Publish-StaticHtmlSite` is used in the downstream conversion
pipeline.

# Examples


## EXAMPLE 1

> ~~~ PowerShell
> Find-MarkdownFiles -Path '...\Modules\MarkdownToHtml' | Select-Object -Property Mode,LastWriteTime,Length,Name,RelativePath | Format-Table
> ~~~
>
> 
> Returns following annotated Markdown file objects of type `[System.IO.FileInfo]` for this PowerShell module:
> 
>     LastWriteTime        Length Name                       RelativePath
>     -------------        ------ ----                       ------------
>     13.09.2019 13:56:21  10751  Convert-MarkdownToHTML.md  Documentation\Convert-MarkdownToHTML.md
>     13.09.2019 13:56:20   3348  MarkdownToHTML.md          Documentation\MarkdownToHTML.md
>     13.09.2019 13:56:21   7193  New-HTMLTemplate.md        Documentation\New-HTMLTemplate.md
>     11.09.2019 17:01:13   4455  README.md                  ReferenceData\katex\README.md
>     ...                   ...   ...                        ...
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

* [https://wethat.github.io/MarkdownToHtml/2.3.1/Find-MarkdownFiles.html](https://wethat.github.io/MarkdownToHtml/2.3.1/Find-MarkdownFiles.html) 
* [`Convert-MarkdownToHTML`](Convert-MarkdownToHTML.md) 
* [`Convert-MarkdownToHTMLFragment`](Convert-MarkdownToHTMLFragment.md) 
* [`Publish-StaticHtmlSite`](Publish-StaticHtmlSite.md) 
* [`New-HTMLTemplate`](New-HTMLTemplate.md)

---

<cite>Module: MarkDownToHTML; Version: 2.3.1; (c) 2018-2021 WetHat Lab. All rights reserved.</cite>

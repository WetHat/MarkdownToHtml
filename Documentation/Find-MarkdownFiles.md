# Find-MarkdownFiles

Find all Markdown file below a given directory.

# Syntax

<blockquote>

```PowerShell
 Find-MarkdownFiles [-Path] <String>  [<CommonParameters>] 
```


</blockquote>

# Description

<blockquote>

Recursively scans a directory and generates annotated `[System.IO.FileInfo]` objects
for each Markdown file.

</blockquote>

# Parameters

<blockquote>



## -Path \<String\>

<blockquote>

Path to a directory containing markdown files.

Parameter Property         | Value
--------------------------:|:----------
Required?                  | true
Position?                  | 1
Default value              | ``
Accept pipeline input?     | false
Accept wildcard characters?| true

</blockquote>


</blockquote>


# Inputs

<blockquote>

None

</blockquote>

# Outputs

<blockquote>

A `[System.IO.FileInfo]` object for each Markdown file found below the given directory. The
`[System.IO.FileInfo]` objects are annotated with a note property `RelativePath` which is a string
specifying the relative path of the markdown file below the given directory.

</blockquote>

# Examples

<blockquote>


## EXAMPLE 1

```PowerShell
Find-MarkdownFiles -Path '...\Modules\MarkdownToHtml' | Select-Object -Property Mode,LastWriteTime,Length,Name,RelativePath | Format-Table
```

Returns following annotated Markdown file objects of type `[System.IO.FileInfo]` for this PowerShell module:

    LastWriteTime        Length Name                       RelativePath
    -------------        ------ ----                       ------------
    13.09.2019 13:56:21  10751  Convert-MarkdownToHTML.md  Documentation\Convert-MarkdownToHTML.md
    13.09.2019 13:56:20   3348  MarkdownToHTML.md          Documentation\MarkdownToHTML.md
    13.09.2019 13:56:21   7193  New-HTMLTemplate.md        Documentation\New-HTMLTemplate.md
    11.09.2019 17:01:13   4455  README.md                  ReferenceData\katex\README.md
    ...                   ...   ...                        ...

</blockquote>

# Related Links

<blockquote>


* [Convert-MarkdownToHtml](Convert-MarkdownToHtml.md) 
* [Convert-MarkdownToHtmlFragment](Convert-MarkdownToHtmlFragment.md) 
* [Publish-StaticHtmlSite](Publish-StaticHtmlSite.md) 
* [New-HTMLTemplate](New-HTMLTemplate.md)

</blockquote>

---

<cite>Module: MarkdownToHtml; Version: 2.0.0; (c) 2018-2020 WetHat Lab. All rights reserved.</cite>

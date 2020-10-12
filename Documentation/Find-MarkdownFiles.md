# Find-MarkdownFiles

Find all Markdown file below a given directory.

# Syntax
```PowerShell
 Find-MarkdownFiles [-Path] <String> [-Exclude] <String[]>  [<CommonParameters>] 
```


# Description


Recursively scans a directory and generates annotated `[System.IO.FileInfo]` objects
for each Markdown file.





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
 

## -Exclude \<String[]\>

<blockquote>

Omits the specified markdown files. The value of this parameter qualifies the Path parameter. Enter a path element or
pattern, such as "D*.md". Wildcards are permitted.

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
A `[System.IO.FileInfo]` object for each Markdown file found below the given directory. The emitted
`[System.IO.FileInfo]` objects are annotated with a note property `RelativePath` which is a string
specifying the relative path of the markdown file below the given directory. The `RelativePath` property is
**mandatory** if `Publish-StaticHtmlSite` is used in the downstream conversion
pipeline.

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

* [https://github.com/WetHat/MarkdownToHtml/blob/master/Documentation/Find-MarkdownFiles.md](https://github.com/WetHat/MarkdownToHtml/blob/master/Documentation/Find-MarkdownFiles.md) 
* [`Convert-MarkdownToHtml`](Convert-MarkdownToHtml.md) 
* [`Convert-MarkdownToHtmlFragment`](Convert-MarkdownToHtmlFragment.md) 
* [`Publish-StaticHtmlSite`](Publish-StaticHtmlSite.md) 
* [`New-HTMLTemplate`](New-HTMLTemplate.md)

---

<cite>Module: MarkdownToHtml; Version: 2.2.2; (c) 2018-2020 WetHat Lab. All rights reserved.</cite>

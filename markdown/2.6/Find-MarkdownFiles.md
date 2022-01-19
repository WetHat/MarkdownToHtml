# Find-MarkdownFiles

Find all Markdown file below a given directory.

# Syntax
```PowerShell
 Find-MarkdownFiles [-Path] <String> [-Exclude] <String[]> [-BuildConfiguration] <PSObject>  [<CommonParameters>] 
```


# Description


Recursively scans a directory and generates annotated `[System.IO.FileInfo]`
objects for each Markdown file.

The annotations are of type `NoteProperty`. They are used in the downstream
conversion process to determine the relative path of a markdown file (property
`RelativePath`) and the build configuration in effect for the Markdown file
(property `EffectiveConfiguration`).





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

Omit the specified files. A comma separated list of path elements or
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
 

## -BuildConfiguration \<PSObject\>

<blockquote>

Build configuration object. Usually obtained by reading a `Build.json` configuration
file. See the [Static Site](about_MarkdownToHTML.md#static-site-project-customization)
for details about configuration options and structure. This configuration is
cascaded with configurations from `Build.json` files found at or above the
location of the Markdown file.

---

Parameter Property         | Value
--------------------------:|:----------
Required?                  | false
Position?                  | 3
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
`[System.IO.FileInfo]` objects are annotated with properties of type `NoteProperty`:

`RelativePath`
:   Specifies the relative path of the Markdown file below the
    directory specified in the `Path` parameter. The `RelativePath` property is
    **mandatory** if `Publish-StaticHtmlSite` is used in the downstream conversion
    pipeline to generate HTML files in the correct locations.

`EffectiveConfiguration`
:   An object similar to the one specified in parameter `-BuildConfiguration`.
    Describes the build configuration in effect at the location of the Markdown
    file. The effective configuration is determined by cascading all `Build.json`
    files in at and above the location of the Markdown file.

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

* [https://wethat.github.io/MarkdownToHtml/2.6/Find-MarkdownFiles.html](https://wethat.github.io/MarkdownToHtml/2.6/Find-MarkdownFiles.html) 
* [`Convert-MarkdownToHTML`](Convert-MarkdownToHTML.md) 
* [`Convert-MarkdownToHTMLFragment`](Convert-MarkdownToHTMLFragment.md) 
* [`Publish-StaticHtmlSite`](Publish-StaticHtmlSite.md) 
* [`New-HTMLTemplate`](New-HTMLTemplate.md)

---

<cite>Module: MarkDownToHTML; Version: 2.6.1; (c) 2018-2022 WetHat Lab. All rights reserved.</cite>

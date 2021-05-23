# New-HTMLTemplate

Create a customizable template directory for Markdown to HTML conversion.

# Syntax
```PowerShell
 New-HTMLTemplate [-Destination] <String>  [<CommonParameters>] 
```


# Description


The factory-default conversion template is copied to the destination directory
to seed the customization process. The new template directory contains the
resources necesssary to generate fully functional, standalone HTML files.

Information about the template
[factory default configuration](about_MarkdownToHtml.md#default-conversion-templates)
and [template customization](about_MarkdownToHtml.md#conversion-templates-customization)
can be found on the [`about_MarkdownToHtml`](about_MarkdownToHtml.md) help page.





# Parameters

<blockquote>



## -Destination \<String\>

<blockquote>

Location of the new conversion template directory. The template directory
should be empty or non-existent.

Parameter Property         | Value
--------------------------:|:----------
Required?                  | true
Position?                  | 1
Default value              | ``
Accept pipeline input?     | false
Accept wildcard characters?| false

</blockquote>


</blockquote>


# Inputs
This function does not read from the pipe


# Outputs
The new conversion template directory `[System.IO.DirectoryInfo]`.

# Examples

## EXAMPLE 1

<blockquote>

```PowerShell
New-HTMLTemplate -Destination 'E:\MyTemplate'
```


Create a copy of the default template in `E:\MyTemplate` for customization.













</blockquote>


# Related Links

* [https://wethat.github.io/MarkdownToHtml/2.3.1/New-HTMLTemplate.html](https://wethat.github.io/MarkdownToHtml/2.3.1/New-HTMLTemplate.html) 
* [`New-StaticHTMLSiteProject`](New-StaticHTMLSiteProject.md)

---

<cite>Module: MarkDownToHTML; Version: 2.3.1; (c) 2018-2021 WetHat Lab. All rights reserved.</cite>

# New-HTMLTemplate

Create a customizable template directory for building HTML files from
Markdown files.

# Syntax
```PowerShell
 New-HTMLTemplate [-Destination] <String>  [<CommonParameters>] 
```


# Description


The factory-default conversion template is copied to the destination directory
to seed the customization process. The new template directory contains the
resources necesssary to generate fully functional, standalone HTML files.

See
[Conversion Template Customization](about_MarkdownToHTML.md#conversion-template-customization)
for ways to customize the template.





# Parameters

<blockquote>



## -Destination \<String\>

<blockquote>

Location of the new conversion template directory. The template directory
should be empty or non-existent.

---

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
This function does not read from the pipe.


# Outputs
The new conversion template directory `[System.IO.DirectoryInfo]`.

# Examples


## EXAMPLE 1

> ~~~ PowerShell
> New-HTMLTemplate -Destination 'E:\MyTemplate'
> ~~~
>
> 
> Create a copy of the factory template in `E:\MyTemplate` for customization.
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

* [https://wethat.github.io/MarkdownToHtml/2.6/New-HTMLTemplate.html](https://wethat.github.io/MarkdownToHtml/2.6/New-HTMLTemplate.html) 
* [`New-StaticHTMLSiteProject`](New-StaticHTMLSiteProject.md)

---

<cite>Module: MarkDownToHTML; Version: 2.6.0; (c) 2018-2022 WetHat Lab. All rights reserved.</cite>

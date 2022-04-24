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

# Notes

<blockquote>

## Updating Custom Conversion Templates

Updates to the MarkdownToHtml module usually come with an updated factory
template. Unless you want to take advantage of the new template resources or there
is a [known incompatibility](MarkDownToHtml.md#known-incompatibilities),
**no action** is needed.

:point_up: A convenient way to upgrade a custom template is to perform the steps
below:
1. Use `New-HTMLTemplate` to create a temporary custom template:
   ~~~powershell
   PS> New-HTMLTemplate -Destination 'TempTemplate'
   ~~~
2. Replace all resources in the custom template you want to update
   with the resources from `TempTemplate`. Do **not** overwite
   template files you migh have customized. Candidates are
   `Template/md-template.html` and `Template\styles\md-styles.css`
3. Merge changes to `Template/md-template.html` and
   `Template\styles\md-styles.css` using your favorite merge tool.

</blockquote>


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

* [https://wethat.github.io/MarkdownToHtml/2.7/New-HTMLTemplate.html](https://wethat.github.io/MarkdownToHtml/2.7/New-HTMLTemplate.html) 
* [`New-StaticHTMLSiteProject`](New-StaticHTMLSiteProject.md)

---

<cite>Module: MarkDownToHTML; Version: 2.7.1; (c) 2018-2022 WetHat Lab. All rights reserved.</cite>

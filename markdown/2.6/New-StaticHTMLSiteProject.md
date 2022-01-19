# New-StaticHTMLSiteProject

Create a customizable Markdown to HTML site conversion project.

# Syntax
```PowerShell
 New-StaticHTMLSiteProject [-ProjectDirectory] <String>  [<CommonParameters>] 
```


# Description


Create a new static HTML site project directoy with some default content
ready for building.

A single markdown file (`README.md`) is provided as initial content. It explains
some customization options and the typical site authoring process.
It is recommended to build the project by executing its build script
`Build.ps1`. This creates the initial static HTML site with the HTML version of
the README (`docs/README.html`) which is more pleasant to read also showcases
some features.

See [Project Customization](about_MarkdownToHTML.md#static-site-project-customization)
for details about the project directory structure and site customization.





# Parameters

<blockquote>



## -ProjectDirectory \<String\>

<blockquote>

The location of the new Markdown to HTML site conversion project.

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
None


# Outputs
The new project directory object `[System.IO.DirectoryInfo]`

# Examples


## EXAMPLE 1

> ~~~ PowerShell
> New-StaticHTMLSiteProject -ProjectDirectory MyProject
> ~~~
>
> 
> Create a new conversion project names 'MyProject' in the current directory. The
> project is ready for build.
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

* [https://wethat.github.io/MarkdownToHtml/2.6/New-StaticHTMLSiteProject.html](https://wethat.github.io/MarkdownToHtml/2.6/New-StaticHTMLSiteProject.html) 
* [`New-HTMLTemplate`](New-HTMLTemplate.md) 
* [Project Customization](about_MarkdownToHTML.md#static-site-project-customization)

---

<cite>Module: MarkDownToHTML; Version: 2.6.1; (c) 2018-2022 WetHat Lab. All rights reserved.</cite>

#  New-StaticHTMLSiteProject

> ## :bookmark: Synopsis
> Create a customizable Markdown to HTML site conversion project.

# Syntax
```PowerShell
 New-StaticHTMLSiteProject -ProjectDirectory <String>  [<CommonParameters>] 
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
 ## -ProjectDirectory `<String>`
  >The location of the new Markdown to HTML site conversion project.
>
> Parameter Property         | Value
> --------------------------:|:----------
> Required?                  | true
> Position?                  | 1
> Default value              | ``
> Accept pipeline input?     | false
> Accept wildcard characters?| false



# Inputs
None


# Outputs
The new project directory object `[System.IO.DirectoryInfo]`

# Notes

## Upgrading Static Site Projects

Upgrades to the MarkdownToHtml module usually come with an updated factory
template and sometimes also with an updated project build scripts (`Build.ps1`) and
project configurations (`Build.json`).

Unless you want to take advantage of the new template resources and build files
or there is a [Known Incompatibility](MarkDownToHTML.md#known-incompatibilities),
no action is needed.

:point_up: A convenient way to upgrade an existing static site project is described below:

1. Use `New-StaticHTMLSiteProject` to create a temporary static site project:
   ~~~powershell
   PS> New-HTMLTemplate -Destination 'TempProject'
   ~~~
2. Replace all resources in `Template` directory of tje static site project you
   want to update with the resources from `TempProject\Template`. Do **not** overwite
   template files you migh have customized. Candidates are
   `Template\md-template.html` and `Template\styles\md-styles.css`
3. Merge changes to following files using your favorite merge tool:
   * `TempProject\Template\md-template.html`
   * `TempProject\Template\styles\md-styles.css`
   * `TempProject\Build.json`
   * `TempProject\Build.ps1`


# Examples

## EXAMPLE 1

~~~ PowerShell
New-StaticHTMLSiteProject -ProjectDirectory MyProject
~~~


Create a new conversion project names 'MyProject' in the current directory. The
project is ready for build.














# Related Links

* [https://wethat.github.io/MarkdownToHtml/2.8/New-StaticHTMLSiteProject.html](https://wethat.github.io/MarkdownToHtml/2.8/New-StaticHTMLSiteProject.html) 
* [`New-HTMLTemplate`](New-HTMLTemplate.md) 
* [Project Customization](about_MarkdownToHTML.md#static-site-project-customization) 
* [Factory Configuration](MarkdownToHTML.md#factory-configuration)

- - -

_Module: [MarkDownToHTML](MarkDownToHTML.md); Version: 2.8.0; (c) 2018-2024 WetHat Lab. All rights reserved._

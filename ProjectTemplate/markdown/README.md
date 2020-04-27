# Static HTML Site Project Template - Readme

_If you are reading this file as Markdown source (`README.md`), consider building the
project first by running the build script `Build.ps1` and then open `README.html` in the browser._

Site projects allow you to build static HTML sites from Markdown sources
in a fast and simple way. Just add markdown content to the project's `markdown`
directory and run the build script to update the HTML site.

The initial configuration of the project contains all site assets locally.
This allows the site to be viewed offline (without internet connection). 

The project is fully functional with the out-of-the-box configuration.

To author the HTML site following simple steps are needed:
1. Create Markdown files (`*.md`) in the `markdown` directory of the project.
   All resources linked to by Markdown content such as images or videos are
   also added to this directory. Make sure to use only relative links to refer
   to other markdown files or media files.
2. Build the site by executing the build script `Build.ps1`.
3. Open the site's home page in the browser and review the content. 

For information about project structure and customization options
check out the documentation for `New-StaticHTMLSiteProject`

~~~ PowerShell
PS> Get-Help New-StaticHTMLSiteProject
~~~

Also read the module's conceptual documentation:

~~~ PowerShell
PS> Get-Help about_MarkdownToHTML
~~~
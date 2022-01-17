#
# Module manifest for module 'MarkDownToHTML'
#
# Generated by: WetHat
#
# Generated on: 11/7/2017 7:57:32 AM
#

@{
# Script module or binary module file associated with this manifest.
RootModule = 'MarkdownToHtml.psm1'

# Version number of this module.
ModuleVersion = '2.6.0'

# Supported PSEditions
CompatiblePSEditions = 'Desktop'

# ID used to uniquely identify this module
GUID = 'ac6c6204-4097-4693-ba7e-3e0167383c24'

# Author of this module
Author = 'WetHat'

# Company or vendor of this module
CompanyName = 'WetHat Lab'

# Copyright statement for this module
Copyright = '(c) 2018-2022 WetHat Lab. All rights reserved.'

# Description of the functionality provided by this module
Description = @'
A collection of PowerShell commands to convert Markdown files to static
HTML sites in various ways.

## Components packaged with this module:

| Component                                       |Version | Description
|-------------------------------------------------|--------|-----------------------------------
| [Markdig](https://github.com/lunet-io/markdig)  | 0.26.0 | Fast Markdown processor for .NET
| [highlight.js](https://highlightjs.org/)        | 9.17.1 | Code syntax highlighter
| [KaTeX](https://katex.org/)                     | 0.15.2 | Math typesetting
| [Mermaid](http://mermaid-js.github.io/mermaid/) | 8.10.1 | Diagramming
| [Svgbob](https://lib.rs/crates/svgbob_cli)      | 0.5.0  | Text based diagrammimg

# Known Incompatibilities

If you have have conversion projects which use the _mathematics_ extensions and
were created with versions of this module older than 2.0.0 (i.e. 1.* or 0.*).
See [version 2.0.0](../2.4.0/MarkdownToHTML.md#2.0.0) release notes for upgrade instructions.
'@

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
RequiredAssemblies = @('Markdig.dll')

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @('HtmlFragments.psm1')

# Functions to export from this module
FunctionsToExport = @(
                        'Convert-MarkdownToHTML'
                        'Convert-MarkdownToHTMLFragment'
                        'Convert-SvgbobToSvg'
                        'ConvertTo-NavigationItem'
                        'Expand-HtmlTemplate'
                        'Find-MarkdownFiles'
                        'New-PageHeadingNavigation'
                        'New-SiteNavigation'
                        'New-StaticHTMLSiteProject'
                        'New-HTMLTemplate'
                        'Publish-StaticHtmlSite'
                        'Update-ResourceLinks'
	                 )

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# List of all modules packaged with this module
ModuleList = @()

# List of all files packaged with this module
FileList = @(
	            'MarkdownToHtml.psm1'
                'HtmlFragments.psm1'
	            'Markdig.dll'
                'svgbob.exe'
                'System.Memory.dll'
                'System.Runtime.CompilerServices.Unsafe.dll'
                'System.Numerics.Vectors.dll'
            )

# Private data to pass to the module specified in RootModule/ModuleToProcess
PrivateData = @{
    PSData = @{
        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @(
                    'Markdown'
                    'HTML'
			        'Converter'
                )

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/WetHat/MarkdownToHtml/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/WetHat/MarkdownToHtml'

        # A URL to an icon representing this module.
        IconUri = 'https://upload.wikimedia.org/wikipedia/commons/2/2f/PowerShell_5.0_icon.png'

        # ReleaseNotes of this module
        ReleaseNotes = @'
## 2.6.0 {#2.6.0}

* Cascading build configuration. `Build.json` configuration files can be added
  at any level in the Markdown subtree to provide directory specific configuration.
  Can be used to supperseed site configurations or build a directory specific
  navigation bar. See [Subtree Configuration](about_MarkdownToHTML.md#subtree-customization)

* External components updated:
  * [KaTeX](https://katex.org/)
  * [Markdig](https://github.com/lunet-io/markdig)

## 2.5.0 {#2.5.0}

* [Markdig](https://github.com/lunet-io/markdig)  update to version 0.25.0
* Support for publishing static websites to
  [GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages).

  This new feature is backwards compatible with existing static site projects.
  However, if you want to use this new feature in existing site projects
  following changes must be applied:

  `Build.json` project configuration file
  :   The `site_dir` option needs to be changed and a new option `github_pages`
      must be added as shown below:

      ~~~ json
      {
         ...

         "site_dir": "docs",
         ...
         "github_pages": false,
         ...
      }
      ~~~

      Using the name `docs` for the site directory makes it possible to check-in
      the entire conversion project as-is. As soon as _GitHub Pages_ are
      enabled and configured to publish the static site from the `docs`
      directory, the site is accessible on the web through its canonical
      _GitHub Pages_ url.

  `Build.ps1` project build file
  :   Add a statement to disable the GitHub publishing process (jekyll) which
      is not necessary for static sites created by this module. Add
      following code to the end of the build file:

      ~~~ PowerShell
      ...
      if ($config.github_pages) {
	      # Switch off Jekyll publishing when building for GitHub pages
	      New-Item -Path $staticSite -Name .nojekyll -ItemType File
      }
      ~~~
* Added a Html fragment post-processing step to the conversion pipeline.

  The default post-processing function `Convert-SvgbobToSvg`
  converts [Svgbob](https://ivanceras.github.io/content/Svgbob.html)
  ASCII art diagrams to svg images. See the
  [feature showcase](../index.html#svgbob-plain-text-diagrams)
  for an example.

  This new feature is backwards compatible with existing static site projects.
  However, if you want to use `Svgbob` diagrams in existing site projects
  following changes must be made:

  `Build.json` project configuration file
  :   A new option `svgbob` option needs to be added to for configuration
      of the svg conversion.

      ~~~ json
      {
         ...
         "svgbob": {
            "background":   "white",
            "fill_color":   "black",
            "font_size":    14,
            "font_family":  "Monospace",
            "scale":        1,
            "stroke_width": 2
        }
      }
      ~~~

      See [Static Site Project Customization](about_MarkdownToHTML.md#static-site-project-customization)
      for more details.

    `Build.json` project configuration file
    :   A postprocessing stage needs to be inserted into to the conversion pipeline by
        adding a `-Split` switch to `Convert-MarkdownToHTMLFragment` and then piping
        its output to `Convert-SvgbobToSvg` like so:

        ~~~ PowerShell
        # Conversion pipeline
        $SCRIPT:markdown = Join-Path $projectDir $config.markdown_dir
        Find-MarkdownFiles $markdown -Exclude $config.Exclude `
        | Convert-MarkdownToHTMLFragment -IncludeExtension $config.markdown_extensions -Split `
        | Convert-SvgbobToSvg -SiteDirectory $staticSite -Options $SCRIPT:config.svgbob `
        | Publish-StaticHTMLSite -Template (Join-Path $projectDir $config.HTML_Template) `
                                 -ContentMap  $contentMap `
				        	     -MediaDirectory $markdown `
	                             -SiteDirectory $staticSite
        ~~~

## 2.4.0 {#2.4.0}

* Navigation bar improvements (Static HTML site projects):

  * scrollbar added to long navbars.
  * `md-styles.css` overhauled for static site template to make navbar usable
    for overflowing navitems
  * HTML fragments with resource links supported in navitem names.
    Example from a `Build.json` which displays a navigatable image:
    ~~~Json
    "site_navigation": [
        { "<img width='90%' src='site_logo.png'/>": "README.md" },
        { "Home": "README.md" },
        { "---": "" }
    ]
    ~~~
  * New commands implemented to remove code duplication and make the `Build.ps1`
    file more consistent.
    Upgrade of the `Build.ps1` file of existing projects is optional. All changes
    are backeard compatible. If you want to upgrade anyways change the content
    map section of`Build.ps1` file like so:
    ~~~ PowerShell
    $SCRIPT:contentMap = @{
	    # Add additional mappings here...
	    '{{footer}}' =  $config.Footer # Footer text from configuration
	    '{{nav}}'    = {
		    param($fragment) # the html fragment created from a markdown file
		    $navcfg = $config.navigation_bar # navigation bar configuration
		    # Create the navigation items configured in 'Build.json'
		    New-SiteNavigation -NavitemSpecs $config.site_navigation `
		                       -RelativePath $fragment.RelativePath `
		                       -NavTemplate $navcfg.templates
		    # Create navigation items to headings on the local page.
		    # This requires the `autoidentifiers` extension to be enabled.
		    New-PageHeadingNavigation -HTMLfragment $fragment.HTMLFragment `
		                              -NavTemplate $navcfg.templates `
		                              -HeadingLevels $navcfg.capture_page_headings
	    }
    }
    ~~~

* Module Documentation
  * Code and conceptial documentation improved
  * Documentation generated with this module and published to
    [GitHub Pages](https://wethat.github.io/MarkdownToHtml)

## 2.3.1 {#2.3.1}

* Navigation bar improvements (Static HTML site projects):
    * default navigation menu changed to a static vertical sidebar.
    * navigation items pop out dynamically on mouse hover.
    * auto-added navigation items for page headings indented according to heading
    level.
    * navbar formatting made more consistent.
    * navbar small screen support

## 2.3.0

* Page navigation bar made customizable. To take advantage of this feature
    in existing projects following files need to be updated:
    * `Build.ps1`: A `-NavTemplate` parameter needs to be added to the invokation of `ConvertTo-NavigationItem`.
    A `-NavTemplate` and a `-HeadingLevels` parameter needs to be added to
    the invokation of`ConvertTo-PageHeadingNavigation`.
    For example:

    ~~~ PowerShell
    # Set-up the content mapping rules for replacing the templace placeholders
    $SCRIPT:contentMap = @{
	    # Add additional mappings here...
	    '{{footer}}' =  $config.Footer # Footer text from configuration
	    '{{nav}}'    = {
		    param($fragment) # the html fragment created from a markdown file
		    $navcfg = $config.navigation_bar # navigation bar configuration
		    # Create the navigation items configured in 'Build.json'
		    $config.site_navigation | ConvertTo-NavigationItem -RelativePath $fragment.RelativePath `
		                                                        -NavTemplate $navcfg.templates
		    # Create navigation items to headings on the local page.
		    # This requires the `autoidentifiers` extension to be enabled.
		    ConvertTo-PageHeadingNavigation $fragment.HTMLFragment -NavTemplate $navcfg.templates `
		                                                            -HeadingLevels $navcfg.capture_page_headings
	    }
    }
    ~~~

    * `Build.json`: a navigation bar configuration section needs to be added:

    ~~~ json
    ...
    "navigation_bar": {
        "capture_page_headings": "123456",
        "templates": {
            "navitem": "<button class='navitem'><a href='{{navurl}}'>{{navtext}}</a></button>",
            "navlabel": "<div class='navitem'>{{navtext}}</div>",
            "navseparator": "<hr class='navitem'/>",
            "navheading": "<span class='navitem{{level}}'>{{navtext}}</span>"
        }
    },
    ...
    ~~~

* Component updates:
    * `Markdig` update to version 0.24
    * `KateX` update to version 0.13.11
    * `Mermaid` update to version 8.10.1

## 2.2.2

*  added referenced .net assemblies which may not be guaranteed to be present

## 2.2.1

* Katex Updated to version 0.12.0
* Mermaid updated to version 8.8.2
* Markdig updated to version 0.22.0
* Code signed With long term self signed certificate

## 2.2.0

* Fixed issue with `ConvertTo-NavigationItem` not understanding hyperlinks
    with `#` fragments.
* Added `autoidentifiers` to the `Build.json` in the project template so that
    headings get `id` attributes.
* Added navigation items for headings on the current page to the navbar.

## 2.1.1

* Bugfix: Site assets not copied in build script

## 2.1.0

#### Enhancements

* `Publish-StaticHtmlSite` now accepts definition of custom placeholder
    mappins for expansion of `md-template.html`.
* Default template placeholder delimiters changed to `{{` and `}}`.
* Static HTML site projects added: See `New-StaticHTMLSiteProject`.
* Documentation made more `Get-Help` friendly.
* _Mermaid_ assets updated to version 8.5.0

#### Maintenance

* Minimum required Powershell version now 5.1 (Desktop)
'@
    } # End of PSData hashtable
} # End of PrivateData hashtable

# HelpInfo URI of this module
HelpInfoURI = 'https://wethat.github.io/MarkdownToHtml/'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''
}

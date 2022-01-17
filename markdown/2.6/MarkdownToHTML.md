# Module MarkDownToHTML 2.6.0 {.title}

**Tags**: Markdown, HTML, Converter, Markdown, HTML, Converter

A collection of PowerShell commands to convert Markdown files to static
HTML sites in various ways.

## Components packaged with this module:

| Component                                       |Version | Description
|-------------------------------------------------|--------|-----------------------------------
| [Markdig](https://github.com/lunet-io/markdig)  | 0.26.0 | Fast Markdown processor for .NET
| [highlight.js](https://highlightjs.org/)        | 9.17.1 | Code syntax highlighter
| [KaTeX](https://katex.org/)                     | 0.13.11| Math typesetting
| [Mermaid](http://mermaid-js.github.io/mermaid/) | 8.10.1 | Diagramming
| [Svgbob](https://lib.rs/crates/svgbob_cli)      | 0.5.0  | Text based diagrammimg

# Known Incompatibilities

If you have have conversion projects which use the _mathematics_ extensions and
were created with versions of this module older than 2.0.0 (i.e. 1.* or 0.*).
See [version 2.0.0](../2.4.0/MarkdownToHTML.md#2.0.0) release notes for upgrade instructions.

# Exported Functions

* [Convert-MarkdownToHTML](Convert-MarkdownToHTML.md)
* [Convert-MarkdownToHTMLFragment](Convert-MarkdownToHTMLFragment.md)
* [Convert-SvgbobToSvg](Convert-SvgbobToSvg.md)
* [ConvertTo-NavigationItem](ConvertTo-NavigationItem.md)
* [Expand-HtmlTemplate](Expand-HtmlTemplate.md)
* [Find-MarkdownFiles](Find-MarkdownFiles.md)
* [New-HTMLTemplate](New-HTMLTemplate.md)
* [New-PageHeadingNavigation](New-PageHeadingNavigation.md)
* [New-SiteNavigation](New-SiteNavigation.md)
* [New-StaticHTMLSiteProject](New-StaticHTMLSiteProject.md)
* [Publish-StaticHtmlSite](Publish-StaticHtmlSite.md)
* [Update-ResourceLinks](Update-ResourceLinks.md)

# Release Notes

## 2.6.0 {#2.6.0}

TODO

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

  The default post-processing function [`Convert-SvgbobToSvg`](Convert-SvgbobToSvg.md)
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
        adding a `-Split` switch to [`Convert-MarkdownToHTMLFragment`](Convert-MarkdownToHTMLFragment.md) and then piping
        its output to [`Convert-SvgbobToSvg`](Convert-SvgbobToSvg.md) like so:

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
    * `Build.ps1`: A `-NavTemplate` parameter needs to be added to the invokation of [`ConvertTo-NavigationItem`](ConvertTo-NavigationItem.md).
    A `-NavTemplate` and a `-HeadingLevels` parameter needs to be added to
    the invokation of[`ConvertTo-PageHeadingNavigation`](ConvertTo-PageHeadingNavigation.md).
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

* Fixed issue with [`ConvertTo-NavigationItem`](ConvertTo-NavigationItem.md) not understanding hyperlinks
    with `#` fragments.
* Added `autoidentifiers` to the `Build.json` in the project template so that
    headings get `id` attributes.
* Added navigation items for headings on the current page to the navbar.

## 2.1.1

* Bugfix: Site assets not copied in build script

## 2.1.0

#### Enhancements

* [`Publish-StaticHtmlSite`](Publish-StaticHtmlSite.md) now accepts definition of custom placeholder
    mappins for expansion of `md-template.html`.
* Default template placeholder delimiters changed to `{{` and `}}`.
* Static HTML site projects added: See [`New-StaticHTMLSiteProject`](New-StaticHTMLSiteProject.md).
* Documentation made more [`Get-Help`](Get-Help.md) friendly.
* _Mermaid_ assets updated to version 8.5.0

#### Maintenance

* Minimum required Powershell version now 5.1 (Desktop)

---

<cite>Module: MarkDownToHTML; Version: 2.6.0; (c) 2018-2022 WetHat Lab. All rights reserved.</cite>

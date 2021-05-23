# Module MarkDownToHTML 2.3.1 {.title}

**Tags**: Markdown, HTML, Converter, Markdown, HTML, Converter

Highly configurable Markdown to HTML conversion using customizable templates.

For information about concepts and use cases
see [about_MarkdownToHtml](about_MarkdownToHtml.md).

# Backward Compatibility

If you are upgrading the currently installed version to a newer version of the
**same** major revision, all conversion or site projects are still fully functional.
Unless you are having issues with any of the pre-installed _JavaScript_
libraries no action is required.

When updating to a new major revision there may be incompatibilities which
affect existing custom templates and static site projects.
Make sure to read the upgrade instructions in the release notes.
However, you still may want to upgrade existing custom templates and
static site projects to take advantage of new functionality or bug fixes.
See the release notes for details.

# Known Incompatibilities

If you have have conversion projects which use the _mathematics_ extensions and
were created with versions of this module older than 2.0.0 (i.e. 1.* or 0.*).
See [version 2.0.0](#2.0.0) release notes for upgrade instructions.

# Exported Functions

* [Convert-MarkdownToHTML](Convert-MarkdownToHTML.md)
* [Convert-MarkdownToHTMLFragment](Convert-MarkdownToHTMLFragment.md)
* [ConvertTo-NavigationItem](ConvertTo-NavigationItem.md)
* [ConvertTo-PageHeadingNavigation](ConvertTo-PageHeadingNavigation.md)
* [Find-MarkdownFiles](Find-MarkdownFiles.md)
* [New-HTMLTemplate](New-HTMLTemplate.md)
* [New-StaticHTMLSiteProject](New-StaticHTMLSiteProject.md)
* [Publish-StaticHtmlSite](Publish-StaticHtmlSite.md)

# Release Notes

## 2.3.2 {#2.3.2}

* scrollbar added to long navbars.
* `md-styles.css` overhauled for static site template to make navbar usable
  for overflowing navitems
* documentation overhauled and published on [GitHub Pages](https://wethat.github.io/MarkdownToHtml)

## 2.3.1 {#2.3.1}

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

## 2.0.0 {#2.0.0}

The version of _Markdig_ included in this release introduces an
incompatiblity with projects which use the _mathematics_ extension
**and** were created with versions of this module older than 2.0.0
(i.e. 1.* or 0.*).

To address this incompaibility the _KaTex_ configuration in
**all** deployed html templates (`md_template.html`) need to be updated like so:

~~~ html
<script>
    // <![CDATA[
    window.onload = function() {
        var tex = document.getElementsByClassName("math");
        Array.prototype.forEach.call(tex, function(el) {
            katex.render(el.textContent, el, {
                                                displayMode: (el.nodeName == "DIV"),
                                                macros: {
                                                            "\\(": "",
                                                            "\\)": "",
                                                            "\\[": "",
                                                            "\\]": ""
                                                        }
                                            })
        });
    };
    // ]]>
</script>
~~~

#### New Features

* Highlighting languages _Perl_ and _YAML_ added

#### Maintenance

* Updated to _Markdig_ 0.18.0.
* KaTeX updated to version 0.11.1
* Code syntax highlighting updated to version 9.17.1

#### Bugfixes
* Rendering of math blocks now creates centered output with the correct (bigger) font.
* Changed the default html template (`md_template.html`) to address the incompatible
  change in the LaTeX math output of the _mathematics_ extension of _Markdig_.

## 1.3.0

* upgrade of markdig to version 0.17.2
* KaTex upgraded to 0.11.0
* Re-factored the Markdown converter pipeline and made it parts public
  to make it useful for a broader range of Markdown conversion scenarios.

## 1.2.8

* [`Write-Host`](Write-Host.md) replaced by the more benign [`Write-Verbose`](Write-Verbose.md)
* Minor code cleanup

## 1.2.7

* Empty lines allowed im 'md-template.html` to remove an ugly but harmless
  exception.
* Syntax highlighting updated to version 9.14.2
* Upgrade to markdig version 0.15.7
* Added Resources and configuration for the [mermaid](https://mermaidjs.github.io/) diagram and
  flowchart generator version 8.0.0 to the HTML template.
* Added Resources and configuration for the [KaTeX](https://katex.org/) LaTeX Math
  typesetting library version 0.10.0 to the HTML template.
* Documentation improved.

## 1.2.6

* Powershell Gallery metadata added.

## 1.2.4

* Replaced `[System.Web.HttpUtility]` by `[System.Net.WebUtility]` to fix issue
  when powershell is run with `-noprofile`

## 1.2.3

* Fixed regression introduced in 1.2.2
* Regression test setup

## 1.2.2

* Support for markdown files in a directory hierarchy fixed.
  (directory scanning fixed and relative path added to resource links)
## 1.2.1

Handle partially HTML encoded code blocks

## 1.2.0

* Replaced XML template processing with text based template processing,
  to relax constraints on the HTML fragment quality.
* HTML encode text in `<code>` blocks

## 1.1.0

* Setting of Markdown parser options implemented
* Wildcard support for pathes added

## 1.0.0

Initial Release

---

<cite>Module: MarkDownToHTML; Version: 2.3.1; (c) 2018-2021 WetHat Lab. All rights reserved.</cite>

# MarkdownToHtml 2.2.2

**Tags**: Markdown, HTML, Converter, Markdown, HTML, Converter

Highly configurable markdown to HTML conversion using customizable templates.

### Features

* Open Source and fully _hackable_.
* Out-of-the box support for diagrams, math typesetting and code syntax
  highlighting.
* Based on [Markdig](https://github.com/lunet-io/markdig),
  a fast, powerful, [CommonMark](http://commonmark.org/) compliant Markdown
  processor for .NET with more than 20 configurable extensions.
* High quality Open Source web components:
  - **Code Highlighting**: [highlight.js](https://highlightjs.org/); supports
    189 languages and 91 styles.
  - **Math typesetting**: [KaTeX](https://katex.org/); The fastest math
    typesetting library for the web.
  - **Diagramming**: [Mermaid](http://mermaid-js.github.io/mermaid/); Generation
    of diagrams and flowcharts from text in a similar manner as Markdown.
* Highly configurable static website projects with configuration file and build
  script. See [`New-StaticHTMLSiteProject`](New-StaticHTMLSiteProject.md).
* Sites can be used offline (without connection to the internet). All site
  assets are local.

### Prerequisites

To successfully create web sites from Markdown you should know:
* Markdown: A good starting point would be
  [GitHub Flavored Markdown](https://github.github.com/gfm/)
* Some knowledge about HTML and CSS (Cascading Stylesheets).
* Some PowerShell knowledge

See [`about_MarkdownToHTML`](about_MarkdownToHTML.md) for more information about configuration
and operation of this module.

### Incompatibilities

This version is incompatible with existing conversion projects
which use the _mathematics_ extensions and were created with versions of this module
older than 2.0.0 (i.e. 1.* or 0.*).

**Make sure to read the release notes for 2.0.0 below for instructions on how to upgrade your
existing conversion projects.**

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

## 2.0.0

The updated version of _Markdig_ incuded in this release introduces
an incompatiblity in the _mathematics_ extension which breaks _KaTeX_ math rendering.

See [`about_MarkdownToHTML`](about_MarkdownToHTML.md) for options to upgrade existing projects.
To address this incompaibility the KaTex configuration in **all** deployed html templates

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

<cite>Module: MarkdownToHtml; Version: 2.2.2; (c) 2018-2020 WetHat Lab. All rights reserved.</cite>

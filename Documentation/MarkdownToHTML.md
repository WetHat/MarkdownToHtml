# MarkdownToHtml 2.1.0

**Tags**: Markdown, HTML, Converter, Markdown, HTML, Converter

Highly configurable markdown to HTML conversion using customizable templates.

See [`about_MarkdownToHTML`](about_MarkdownToHTML.md) for features and customization options.

# Exported Functions

* [Convert-MarkdownToHTML](Convert-MarkdownToHTML.md)
* [Convert-MarkdownToHTMLFragment](Convert-MarkdownToHTMLFragment.md)
* [Find-MarkdownFiles](Find-MarkdownFiles.md)
* [New-HTMLTemplate](New-HTMLTemplate.md)
* [New-StaticHTMLSiteProject](New-StaticHTMLSiteProject.md)
* [Publish-StaticHtmlSite](Publish-StaticHtmlSite.md)

# Release Notes

## 2.1.0

#### Enhancements

* [`Publish-StaticHtmlSite`](Publish-StaticHtmlSite.md) now supports definition of custom placeholders
  for expansion of `md_template.html`.
* Constraints for template placeholders relaxed.
* Default template placeholder delimiters changed to `{{` and `}}`.

#### Maintenance

* Minimum required Powershell version now 3.0

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

<cite>Module: MarkdownToHtml; Version: 2.1.0; (c) 2018-2020 WetHat Lab. All rights reserved.</cite>

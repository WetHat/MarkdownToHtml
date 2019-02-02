# MarkdownToHTML 1.2.7

<cite><b>Tags</b>: Markdown, HTML, Converter, Markdown, HTML, Converter</cite>

Highly configurable markdown to HTML conversion using customizable templates.

Markdown to HTML conversion is based on [Markdig](https://github.com/lunet-io/markdig),
a fast, powerful, [CommonMark](http://commonmark.org/) compliant,
extensible Markdown processor for .NET.

Following additional extensions are installed with this module:

* **Code syntax highlighting** based on the [highlight.js](https://highlightjs.org/)
  JavaScript library which supports 185 languages and 89 styles as well as
  automatic language detection. Code syntax highlighting is activated by default
  and configured for following languages:
  * Bash
  * C#
  * C++
  * Clojure
  * CMake
  * CSS
  * Diff
  * DOS .bat
  * F#
  * Groovy
  * HTML/XML
  * HTTP
  * Java
  * JavaScript
  * JSON
  * Lisp
  * Makefile
  * Markdown
  * Maxima
  * Python
  * PowerShell
  * SQL

  To obtain syntax highlighting for other/additional languages, please visit
  the [Getting highlight.js](https://highlightjs.org/download/) page and
  get a customized version of highlight.js configured for the languages
  you need.
* **Diagramming** based on the [mermaid](https://mermaidjs.github.io/) diagram
  and flowchart generator. Diagramming is pre-installed and activated.
* *LaTeX Math typesetting* based on the [KaTeX](https://katex.org/) LaTeX Math
  typesetting library. Math typesetting is pre-installed and activated

# Exported Functions

* [Convert-MarkdownToHTML](Convert-MarkdownToHTML.md)
* [New-HTMLTemplate](New-HTMLTemplate.md)

# Release Notes

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

<cite>Module: MarkdownToHTML; Version: 1.2.7; (c) 2019 WetHat Lab. All rights reserved.</cite>

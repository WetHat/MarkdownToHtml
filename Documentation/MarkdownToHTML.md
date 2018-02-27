# MarkdownToHTML 1.2.6

<cite><b>Tags</b>: Markdown, HTML, Converter, Markdown, HTML, Converter</cite>

Highly configurable markdown to HTML conversion using customizable templates.

Markdown to HTML conversion is based on [Markdig](https://github.com/lunet-io/markdig),
a fast, powerful, [CommonMark](http://commonmark.org/) compliant,
extensible Markdown processor for .NET.

Code syntax highlighting is based on the [highlight.js](https://highlightjs.org/)
JavaScript library which supports 176 languages and 79 styles as well as
automatic language detection.

# Exported Functions

* [Convert-MarkdownToHTML](Convert-MarkdownToHTML.md)
* [New-HTMLTemplate](New-HTMLTemplate.md)

# Release Notes

## 1.2.6

* Powershell Gallery matadata added.

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

<cite>Module: MarkdownToHTML; Version: 1.2.6; (c) 2018 WeHat Lab. All rights reserved.</cite>

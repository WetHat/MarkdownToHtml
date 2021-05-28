# *MarkdownToHtml* Documentation {.title}

The content of this documentation site was build from Markdown sources
with the PowerShell module `MarkdownToHtml`. This module is hosted as
Open Source project on GitHub at: [WetHat/MarkdownToHtml](https://github.com/WetHat/MarkdownToHtml).

## Features

> * Fully _hackable_.
> * Out-of-the box support for diagrams, math typesetting and code syntax
>   highlighting.
> * Based on [Markdig](https://github.com/lunet-io/markdig),
>   a fast, powerful, [CommonMark](http://commonmark.org/) compliant Markdown
>   processor for .NET with more than 20 configurable extensions.
> * Built with high quality Open Source web components:
>   - **Code Highlighting**: [highlight.js](https://highlightjs.org/); supports
>     189 languages and 91 styles.
>   - **Math typesetting**: [KaTeX](https://katex.org/); The fastest math
>     typesetting library for the web.
>   - **Diagramming**: [Mermaid](http://mermaid-js.github.io/mermaid/); Generation
>     of diagrams and flowcharts from text in a similar manner as Markdown.
> * Highly configurable static website projects with configuration file and build
>   script.
> * Sites can be used offline (without connection to the internet). All
>   site assets are local.

# Installation and Update

An installable package of this module is hosted on the
[PowerShell Gallery](https://www.powershellgallery.com/packages/MarkdownToHtml)

## Installation
>
> To install the module enter the following command into the command prompt of 
> an admin PowerShell:
>
> ```PowerShell
> PS> Install-Module -Name MarkdownToHTML
> ```
>

## Update
>
> To update the module enter the following command into the command prompt of 
> an admin PowerShell:
>
>
> ```PowerShell
> PS> Update-Module -Name MarkdownToHTML
> ```
>
> Make sure you read the [release notes](#latest-version)
>
> ### Backward Compatibility
>
> If you are upgrading the currently installed version to a newer version of the
> **same** major revision, all conversion or site projects are still fully functional.
> Unless you are having issues with any of the pre-installed _JavaScript_
> libraries no action is required.
>
> When updating to a new major revision there may be incompatibilities which
> affect existing custom templates and static site projects.
> Make sure to read the upgrade instructions in the release notes.
> However, you still may want to upgrade existing custom templates and
> static site projects to take advantage of new functionality.
> Check out the [release notes](#latest-version) in the module's manifest for details.

# Quickstart

1. Install the MarkdownToHTML. See section [Istallation](#installation).
2. Open a PowerShell command shell.

## Convert Some Markdown Files to HTML

> 3. Enter this in a PowerShell command prompt:
>    ~~~ PowerShell
>    PS> Convert-MarkdownToHTML -Path '<directory with markdown files>' -SiteDirectory '<html site directory>' -IncludeExtension 'advanced'
>    ~~~
> 4. Browse to `<html site directory>` and view some of the HTML files in
>    a browser.

## Bootstrap a Static Site Project:

> 3. Enter this in a PowerShell command prompt:
>    ~~~ PowerShell
>    PS> New-StaticHTMLSiteProject -ProjectDirectory 'MyProject'
>    PS> cd 'MyProject'
>    PS> ./Build.ps1
>    ~~~
> 4. Open `html/README.html` a browser and enjoy the showcase section.

# Documentation

## Latest Version

> * **2.4.0**: [Documentation](2.4.0/MarkdownToHTML.md) - [Release Notes](2.4.0/MarkdownToHTML.md#release-notes).

## Old Versions

> * **2.3.1**: [Documentation](2.3.1/MarkdownToHTML.md) - [Release Notes](2.3.1/MarkdownToHTML.md#release-notes).

# Bugs and Enhancements

If you found an issue with the module or want to suggest and enhancement, head over to
the [Issues](https://github.com/WetHat/MarkdownToHtml/issues) page on GitHub and
submit a bug report or enhancement request. Make sure
to also check the
[wiki](https://github.com/WetHat/MarkdownToHtml/wiki) for
tips and the FAQ first.

# Feature Showcase

In the following sections some selected features are demonstrated.

## Mermaid Diagrams

> Markdown extension: `mermaid`:
>
> ``` markdown
> ~~~ mermaid
> stateDiagram
> 	[*] --> Still
> 	Still --> [*]
> 
> 	Still --> Moving
> 	Moving --> Still
> 	Moving --> Crash
> 	Crash --> [*]
> ~~~
> ```
> 
> rendered as:
> 
> ~~~ mermaid
> stateDiagram
> 	[*] --> Still
> 	Still --> [*]
> 
> 	Still --> Moving
> 	Moving --> Still
> 	Moving --> Crash
> 	Crash --> [*]
> ~~~

## LaTeX Math

> Markdown extensions: `mathematics`:
>
> ~~~ markdown
> $$
> \left( \sum_{k=1}^n a_k b_k \right)^2 
> \leq 
> \left( \sum_{k=1}^n a_k^2 \right) \left( \sum_{k=1}^n b_k^2 \right)  
> $$
> ~~~
> 
> renders as:
> 
> $$
> \left( \sum_{k=1}^n a_k b_k \right)^2 
> \leq 
> \left( \sum_{k=1}^n a_k^2 \right) \left( \sum_{k=1}^n b_k^2 \right)  
> $$

## Code Syntax Highlighting

> Markdown extension: `common`
> 
> ``` markdown
> ~~~ cpp
> #include <iostream>
> 
> int main(int argc, char *argv[]) {
> 
>   /* An annoying "Hello World" example */
>   for (auto i = 0; i < 0xFFFF; i++)
>     cout << "Hello, World!" << endl;
> 
>   char c = '\n';
>   unordered_map <string, vector<string> > m;
>   m["key"] = "\\\\"; // this is an error
> 
>   return -2e3 + 12l;
> }
> ~~~
> ```
> 
> renders as:
> 
> ~~~ cpp
> #include <iostream>
> 
> int main(int argc, char *argv[]) {
> 
>   /* An annoying "Hello World" example */
>   for (auto i = 0; i < 0xFFFF; i++)
>     cout << "Hello, World!" << endl;
> 
>   char c = '\n';
>   unordered_map <string, vector<string> > m;
>   m["key"] = "\\\\"; // this is an error
> 
>   return -2e3 + 12l;
> }
> ~~~
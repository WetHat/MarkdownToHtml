# *MarkdownToHtml* Documentation {.title}

The content of this documentation site was build from Markdown sources
with the PowerShell module `MarkdownToHtml`. This module is hosted as
Open Source project on GitHub at: [WetHat/MarkdownToHtml](https://github.com/WetHat/MarkdownToHtml).

## Features

> * Highly configurable static website projects with configuration file and build
>   script.
> * Optional support for [GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages).
> * Sites can be used offline (without connection to the internet). All
>   site assets are local.
> * Out-of-the box support for:
>   - [Mermaid](http://mermaid-js.github.io/mermaid/) diagrams and flowcharts.
>     See the [example](#mermaid-diagrams).
>   - [Svgbob](https://ivanceras.github.io/content/Svgbob.html) plain text,
>     human readable diagrams. See the [example](#svgbob-plain-text-diagrams).
>   - [highlight.js](https://highlightjs.org/) code syntax highlighting.
>     See the [example](#code-syntax-highlighting).
>   - [KaTeX](https://katex.org/) math typesetting.
>     See the [example](#latex-math).
> * Based on [Markdig](https://github.com/lunet-io/markdig),
>   a fast, powerful, [CommonMark](http://commonmark.org/) compliant Markdown
>   processor for .NET with more than 20 configurable extensions.
> * :sparkles: Cascading build configurations. In addition to the top-level `Build.json`
>   project configuration, the _Markdown_ source tree configured in `markdown_dir`
>   can now have dedicated build configurations (`Build.json`). Among other things this makes it
>   easy to configure the navitation bar in a directory specific way.
> * :sparkles: A test function (`Test-LocalSiteLinks`) to report broken relative links
>   in markdown source directorytree.

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
> Make sure you read the [release notes](#releases)
>
> ### Backward Compatibility
>
> If you are upgrading the currently installed version to a newer version of the
> **same** major revision, all conversion or site projects are still fully functional.
> Unless you are having issues with any of the pre-installed _JavaScript_
> libraries no action is required.
>
> :warning: When updating to a new major revision there may be incompatibilities which
> affects existing custom templates and static site projects.
> Make sure to read the upgrade instructions in the release notes.
>
> However, you still may want to upgrade existing custom templates and
> static site projects to take advantage of new functionality.
> Check out the [release notes](#releases) for details.

# Quickstart

1. Install the MarkdownToHTML. See the [Installation](#installation) section for more
   details.
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
> 4. Open `docs/README.html` a browser and enjoy the showcase section.

# Documentation

Documentation for individual commands can be obtained with the `Get-Help` command

~~~ PowerShell
PS> Get-Help New-StaticHTMLSiteProject -Online
~~~

Make sure to use the `-Online` switch for best reading experience.

## Releases

> :sparkles: **2.7.1**: [Documentation](2.7/MarkdownToHTML.md) - [Release Notes](https://github.com/WetHat/MarkdownToHtml/releases/tag/v2.7.1).
>
> * **2.7.0**: [Documentation](2.7/MarkdownToHTML.md) - [Release Notes](https://github.com/WetHat/MarkdownToHtml/releases/tag/v2.7.0).
> * **2.6.1**: [Documentation](2.6/MarkdownToHTML.md) - [Release Notes](https://github.com/WetHat/MarkdownToHtml/releases/tag/v2.6.1).
> * **2.5.0**: [Documentation](2.5.0/MarkdownToHTML.md) - [Release Notes](https://github.com/WetHat/MarkdownToHtml/releases/tag/v2.5.0).
> * **2.4.0**: [Documentation](2.4.0/MarkdownToHTML.md) - [Release Notes](https://github.com/WetHat/MarkdownToHtml/releases/tag/v2.4.0).
> * **2.3.1**: [Documentation](2.3.1/MarkdownToHTML.md) - [Release Notes](https://github.com/WetHat/MarkdownToHtml/releases/tag/v2.3.1).

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

> [Mermaid](https://mermaid-js.github.io/mermaid/#/) is a Javascript based
> diagramming and charting tool that renders Markdown-inspired text definitions
> to create and modify diagrams dynamically.
>
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

## Svgbob Plain Text Diagrams

> [Svgbob](https://ivanceras.github.io/content/Svgbob.html)
> is a diagramming model which uses a set of typing characters to approximate
> the intended shapes (ASCII art). Used to _draw_
> diagrams which are human readable in their Markdown text
> representation.
>
> Available since version 2.5.0. The example below uses
> unicode _box_ drawing characters to make the diagrams more
> readable in Markdown text.
>
> ``` markdown
> ˜˜˜ bob
>        ┌──────┐   .─.  ┌───┐
> o──┬───┤ elem ├──( ; )─┤ n ├──┬──o
>    │   └──────┘   '─'  └───┘  │
>    │ ╭──────>──────╮          │
>    │ │    ┌───┐    │          │
>    ├─┴─┬──┤ x ├──┬─┴──────────┤
>    │   │  └───┘  │            │
>    │   │   .─.   │            │
>    │   ╰──( , )──╯            ^
>    │       '─'                │
>    │  ╭────────>─────────╮    │
>    │  │   ┌───┐   .-.    │    │
>    ╰──┴─┬─┤ x ├──( , )─┬─┴────╯
>         │ └───┘   '-'  │
>         ╰───────<──────╯
> ˜˜˜
> ```
>
> renders as:
>
> ~~~ bob
>        ┌──────┐   .─.  ┌───┐
> o──┬───┤ elem ├──( ; )─┤ n ├──┬──o
>    │   └──────┘   '─'  └───┘  │
>    │ ╭──────>──────╮          │
>    │ │    ┌───┐    │          │
>    ├─┴─┬──┤ x ├──┬─┴──────────┤
>    │   │  └───┘  │            │
>    │   │   .─.   │            │
>    │   ╰──( , )──╯            ^
>    │       '─'                │
>    │  ╭────────>─────────╮    │
>    │  │   ┌───┐   .-.    │    │
>    ╰──┴─┬─┤ x ├──( , )─┬─┴────╯
>         │ └───┘   '-'  │
>         ╰───────<──────╯
> ~~~

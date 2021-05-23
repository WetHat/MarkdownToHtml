# *MarkdownToHtml* Documentation {.title}

# Latest Version

* **2.3.1**: [Documentation](2.3.1/MarkdownToHTML.md) - [Release Notes](2.3.1/MarkdownToHTML.md#release-notes).

# Installation

This module is available on the [PowerShell Gallery](https://www.powershellgallery.com/packages/MarkdownToHtml)
and can be installed from a PowerShell command prompt like so:

```PowerShell
PS> Install-Module -Name MarkdownToHTML
```

# Updates

If the module was installed via `Install-Module` it can be conveniently updated
via the [PowerShell Gallery](https://www.powershellgallery.com/packages/MarkdownToHtml)
from a PowerShell command prompt like so:

```PowerShell
PS> Update-Module -Name MarkdownToHTML
```

Make sure you read the [release notes](https://wethat.github.io/MarkdownToHtml)
for information about backward compatibility.

# Quickstart

1. Install the MarkdownToHTML (see above).
2. Open a PowerShell command shell.

## Convert a bunch of Markdown files to HTML

> 3. Enter this in a PowerShell command prompt:
>    ~~~ PowerShell
>    PS> Convert-MarkdownToHTML -Path '<directory with markdown files>' -SiteDirectory '<html site directory>' -IncludeExtension 'advanced'
>    ~~~
> 4. Browse to `<html site directory>` and view some of the HTML files in
>    a browser.

## Bootstrap a static site project:

> 3. Enter this in a PowerShell command prompt:
>    ~~~ PowerShell
>    PS> New-StaticHTMLSiteProject -ProjectDirectory 'MyProject'
>    PS> cd 'MyProject'
>    PS> ./Build.ps1
>    ~~~
> 4. Open `html/README.html` a browser and enjoy the showcase section.


# Support

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
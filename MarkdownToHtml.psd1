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
ModuleVersion = '2.8.0'

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

# Components packaged with this module:

| Component                                       |Version  | Description
|-------------------------------------------------|-------- |-----------------------------------
| [Markdig](https://github.com/lunet-io/markdig)  | 0.37.0  | Fast Markdown processor for .NET
| [highlight.js](https://highlightjs.org/)        | 11.9.0  | Code syntax highlighter
| [KaTeX](https://katex.org/)                     | 0.16.10 | Math typesetting
| [Mermaid](http://mermaid-js.github.io/mermaid/) | 10.9.0  | Diagramming
| [Svgbob](https://lib.rs/crates/svgbob_cli)      | 0.7.2   | Text based diagramming

## Code Syntax Highlighting (highlight.js)

Pre-configured code syntax highlighting languages in this package:

| Language         | Fenced Code Block Aliases
| ---------------: | : ---------------------------------------------------
| AsciiDoc         | asciidoc, adoc
| Apache           | apache, apacheconf
| autoit           | autoit
| Bash             | bash, sh
| C#               | csharp, cs, c#
| C                | c, h
| C++              | cc, c++, h++, hpp, hh, hxx, cxx
| Clojure          | clojure, clj, edn
| Clojure REPL     | clojure-repl
| CMake            | cmake, cmake.in
| CSS              | css
| Diff             | diff, patch
| DOS .bat         | dos, bat, cmd
| Erlang           |
| Erlang REPL      | erlang-repl
| Excel            | excel, xlsx, xls
| F#               | fsharp, fs. f#
| Fortran          | fortran, f90, f95
| Go               | go, golang
| Graphql          | graphql, gql
| Groovy           | groovy
| HTTP             | http, https
| INI, TOML        | ini, toml
| Java             | java, jsp
| JavaScript       | javascript, js, jsx, mjs, cjs
| JSON             | json
| Julia            | julia, jldoctest
| Julia REPL       | julia-repl
| Kotlin           | kotlin, kt, kts
| LaTeX            | latex, tex
| less             | less
| Lisp             | lisp
| Lua              | lua
| Makefile         | makefile, mk, mak, make
| Markdown         | markdown, md, mkdown, mkd
| Mathematica      | mathematica, mma, wl
| Maxima           | maxima
| nginx            | nginx, nginxconf
| Node REPL        | node-repl
| Perl             | perl, pl, pm
| PHP              | php
| Plain Text       | plaintext, txt, text
| PowerShell       | powershell, pwsh, ps, ps1
| Prolog           | prolog
| Properties       | properties
| Python           | python, py, gyp, ipython
| Python REPL      | python-repl, pycon
| R                | r
| Rust             | rust, rs
| Scala            | scala
| Scheme           | scheme, scm
| scss             | scss
| shell            | shell, console, shellsession
| smalltalk        | smalltalk, st
| SQL              | sql
| tcl              | tcl, tk
| Typescript       | typescript, ts, tsx, mts, cts
| Visual Basic.net | vbnet, vb
| vbscript         | vbscript, vbs
| vbscript-html    | vbscript-html
| vim              | vim
| x86asm           | x86asm
| XML/HTML         | xml, html, xhtml, rss, atom, xjb, xsd, xsl, plist, wsf, svg
| Xquery           | xquery, xpath, xq, xqm
| YAML             | yml, yaml

See also [Customization](about_MarkdownToHTML.md#customization) for more
information.

## Markdown Extensions

Projects generated by `New-StaticHTMLSiteProject` have following
Markdown extensions pre-configured:
* `common`
* `definitionlists`
* `mathematics`
* `diagrams`
* `pipetables`
* `autoidentifiers`
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
RequiredAssemblies = @(
                        'Markdig.dll'
                        'System.Web'
                      )

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @(
                    'SiteNavigation.psm1'
                    'HtmlFragments.psm1'
                 )

# Functions to export from this module
FunctionsToExport = @(
                        'Convert-MarkdownToHTML'
                        'Convert-MarkdownToHTMLFragment'
                        'Convert-SvgbobToSvg'
                        'ConvertTo-NavigationItem'
                        'Expand-HtmlTemplate'
                        'Expand-DirectoryNavigation'
                        'Find-MarkdownFiles'
                        'New-PageHeadingNavigation'
                        'New-SiteNavigation'
                        'New-StaticHTMLSiteProject'
                        'New-HTMLTemplate'
                        'Publish-StaticHtmlSite'
                        'Test-LocalSiteLinks'
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
                'SiteNavigation.psm1'
	            'Markdig.dll'
                'svgbob_cli.exe'
                'System.Memory.dll'
                'System.Runtime.CompilerServices.Unsafe.dll'
                'System.Numerics.Vectors.dll'
                'vcruntime140.dll'
            )

# Private data to pass to the module specified in RootModule/ModuleToProcess
PrivateData = @{
    PSData = @{
        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @(
                    'Markdown'
                    'HTML'
			        'Converter'
                    'StaticHTMLSites'
                    'ConversionTool'
                )

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/WetHat/MarkdownToHtml/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/WetHat/MarkdownToHtml'

        # A URL to an icon representing this module.
        IconUri = 'https://upload.wikimedia.org/wikipedia/commons/2/2f/PowerShell_5.0_icon.png'

        # ReleaseNotes of this module
        ReleaseNotes = @'
Release notes for this and previous releases are on GitHub at:
[MarkdownToHtml Releases](https://github.com/WetHat/MarkdownToHtml/releases).

## Upgrading Custom Templates and Static Site Projects.

Unless there is a known incompatibility (see below) or you want to take
advantage of new capabilities, **no action** is needed.

Refer to
[Upgrading Custom Conversion Templates](New-StaticHTMLSiteProject.md#upgrading-custom-conversion-templates)
for custom template upgrade instructions and to
[Upgrading Static Site Projects](New-StaticHTMLSiteProject.md#upgrading-static-site-projects)
for static site upgrades.

## Known Incompatibilities

### 2.7.0 {#2.7.0}
> The fix for [issue #35](https://github.com/WetHat/MarkdownToHtml/issues/35)
> introduces an issue with `site_navigation` configurations in `Build.json`
> build configuration files which are **below** the directory tree specified in
> the `mardown_dir` option of the top-level build configuration file
> (`Build.json`). The fix now handles relative links correctly. If you have
> gotten navigation links to work by using links which are **not** relative
> to the `Build.json` file they are defined in, the no longer work.
>
> To locate these links you can use the `Test-LocalSiteLinks` function.

### 2.0.0 {#2.0.0}
> If you have have conversion projects which use the _mathematics_ extensions and
> were created with versions of this module older than 2.0.0 (i.e. 1.* or 0.*).
> The version of _Markdig_ included in this release introduces an
> incompatiblity with projects which use the _mathematics_ extension.
>
> To address this incompaibility the _KaTex_ configuration in
> **all** deployed html templates (`md_template.html`) need to be updated like so:
>
> ~~~ html
> <script>
>     // <![CDATA[
>     window.onload = function() {
>         var tex = document.getElementsByClassName("math");
>         Array.prototype.forEach.call(tex, function(el) {
>             katex.render(el.textContent, el, {
>                                                 displayMode: (el.nodeName == "DIV"),
>                                                 macros: {
>                                                             "\\(": "",
>                                                             "\\)": "",
>                                                             "\\[": "",
>                                                             "\\]": ""
>                                                         }
>                                            })
>         });
>     };
>     // ]]>
> </script>
> ~~~

'@
    } # End of PSData hashtable
} # End of PrivateData hashtable

# HelpInfo URI of this module
HelpInfoURI = 'https://wethat.github.io/MarkdownToHtml/'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''
}

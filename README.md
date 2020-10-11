[![GitHub release](https://img.shields.io/github/release/WetHat/MarkdownToHtml)](https://GitHub.com/WetHat/MarkdownToHtml/releases/)
[![Github all releases](https://img.shields.io/github/downloads/WetHat/MarkdownToHTML/total.svg)](https://GitHub.com/WetHat/MarkdownToHtml/releases/)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/WetHat/MarkdownToHtml/graphs/commit-activity)
[![All Contributors](https://img.shields.io/badge/all_contributors-1-orange.svg?style=flat-square)](#contributors-)

# MarkdownToHtml
Highly configurable markdown to HTML conversion using customizable templates.

For details see the [module documentation](Documentation/MarkdownToHTML.md).

# Installation & Update

This module is available on the [PowerShell Gallery](https://www.powershellgallery.com/packages/MarkdownToHtml)
and can be installed from a PowerShell shell like so:

```PowerShell
PS> Install-Module -Name MarkdownToHTML
```

If the module was installed via `Install-Module` it can be conveniently updated by:

```PowerShell
PS> Update-Module -Name MarkdownToHTML
```

**Important Note!** When updating to a new major version of the module there may
be a compatibility change which affects existing custom templates or functionality.
Make sure to read the release notes on the
[Releases](https://github.com/WetHat/MarkdownToHtml/releases)
page or on the [module documentation](Documentation/MarkdownToHTML.md) page.

# Quickstart

**For the very impatient:**

1. Open a PowerShell command shell as _Administrator_ 
2. Install or update the PowerShell Module `MarkdownToHTML`
3. Open a another PowerShell command shell as _normal_ user.
4. Type this:
   ~~~ PowerShell
   PS> Convert-MarkdownToHTML -Path '<directory with markdown files>' -SiteDirectory '<html site directory>' -IncludeExtension 'advanced'
   ~~~
5. Browse to `<html site directory>` and open some html files in browser. 

**For the impatient:**

1. Open a PowerShell command shell as _Administrator_ 
2. Install or update the PowerShell Module `MarkdownToHTML`
3. Open a another PowerShell command shell as _normal_ user.
4. Type this:
   ~~~ PowerShell
   PS> New-StaticHTMLSiteProject -ProjectDirectory 'MyProject'
   PS> cd 'MyProject'
   PS> ./Build.ps1
   ~~~
5. Open `html/README.html` in the browser and enjoy the showcase section.

![Logo](Markdown2HTML.png)

# See Also
* [Install-Module](https://docs.microsoft.com/en-us/powershell/module/powershellget/Install-Module?view=powershell-5.1) -
  Download one or more modules from an online gallery, and installs them on the local computer.
* [Update-Module](https://docs.microsoft.com/en-us/powershell/module/powershellget/update-module?view=powershell-5.1) -
  Downloads and installs the newest version of specified modules from an online gallery to the local computer. 
* [PowerShellGet](https://docs.microsoft.com/en-us/powershell/module/powershellget/?view=powershell-5.1#powershellget) -
  a package manager for Windows PowerShell.

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="http://roose.kz"><img src="https://avatars3.githubusercontent.com/u/277651?v=4" width="100px;" alt=""/><br /><sub><b>roose</b></sub></a><br /><a href="https://github.com/WetHat/MarkdownToHtml/commits?author=roose" title="Code">💻</a></td>
  </tr>
</table>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!

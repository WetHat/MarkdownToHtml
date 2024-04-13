[System.IO.DirectoryInfo]$SCRIPT:moduleDir = Split-Path -Parent $MyInvocation.MyCommand.Path

[string[]]$SCRIPT:advancedMarkdownExtensions = @(
    'abbreviations' ## .UseAbbreviations()
    'autoidentifiers' ## .UseAutoIdentifiers()
    'citations' ## .UseCitations()
    'customcontainers' ## .UseCustomContainers()
    'definitionlists' ## .UseDefinitionLists()
    'emphasisextras' ## .UseEmphasisExtras()
    'figures' ## .UseFigures()
    'footers' ## .UseFooters()
    'footnotes' ## .UseFootnotes()
    'gridtables' ## .UseGridTables()
    'mathematics' ## .UseMathematics()
    'medialinks' ## .UseMediaLinks()
    'pipetables' ## .UsePipeTables()
    'listextras' ## .UseListExtras()
    'tasklists' ## .UseTaskLists()
    'diagrams' ## .UseDiagrams()
    'autolinks' ## .UseAutoLinks()
    'attributes' ## .UseGenericAttributes();
)
<#
.SYNOPSIS
Simple template expansion based on a content substitution dictionary.

.DESCRIPTION
Locates placeholders in the input string abd replaced them
with values found for the placeholders in the given dictionary. The placeholder
expansion is non-recursive.

.PARAMETER InputObject
An string representing an Html fragment.

.PARAMETER ContentMap
A dictionary whose keys define placeholders and whose values define the
replacements.

.INPUTS
HTML template with placeholders.

.OUTPUTS
HTML fragment with all paceholders replaced by the content specified
by the `ContentMap`.

.EXAMPLE
Expand-HtmlTemplate -InputObject $template -ContentMap $map

Expand the HTML template `$template` mappings provided with `$map`.

With:

~~~ PowerShell
$template = '<span class="navitem{{level}}">{{navtext}}</span>'
$map = @{
    '{{level}}'   = 1
    '{{navtext}}' = 'foo'
}
~~~

this HTML fragment is generated:

~~~ html
<span class="navitem1">foo</span>
~~~

.LINK
https://wethat.github.io/MarkdownToHtml/2.8/Expand-HtmlTemplate.html
#>
function Expand-HtmlTemplate {
    [OutputType([string])]
    [CmdletBinding()]

    param(
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [AllowEmptyString()]
        [Alias('Template')]
        [string]$InputObject,

        [parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [hashtable]$ContentMap
    )

    PROCESS {
        # map the locations of placeholders found in the current line of the
        # HTML template
        $placeholderMap = @{}
        foreach ($placeholder in $ContentMap.keys) {
            [int]$ndx = $InputObject.IndexOf($placeholder)
            while ($ndx -ge 0)  { # map all occurrences of the placeholder
                $placeholderMap[$ndx] = $placeholder; # map it
                $ndx = $InputObject.IndexOf($placeholder,$ndx+$placeholder.Length)
            }
        }
        # replace the placeholders bottom up
        $placeholderMap.keys | Sort-Object -Descending | ForEach-Object {
            [int]$ndx = $_
            [string]$placeholder = $placeholderMap[$ndx]
            $InputObject = $InputObject.Substring(0,$ndx) + $ContentMap[$placeholder] + $InputObject.Substring($ndx+$placeholder.Length)
        }
        Write-Output $InputObject # expanded fragment
    }
}
<#
.SYNOPSIS
Create a static HTML site from HTML fragment objects.

.DESCRIPTION
Html fragment objects piped into this function (or passed via the `InputObject`
parameter) are converted into standalone HTML documents and saved to a Html site
directory.

The Markdown to HTML document conversion uses default or custom templates with
stylesheets and JavaScript resources to render Markdown extensions for:
* LaTeX math
* code syntax highlighting
* diagrams

See `New-HtmlTemplate` for details.

.PARAMETER InputObject
An object representing an Html fragment. Ideally this is an output object
returned by `Convert-MarkdownToHTMLFragment`, but any object will
work provided following properties are present:

`RelativePath`
:   A string representing the relative path to the Markdown file with respect to
    a base (static site) directory.
    This property is automatically provided by:
    * using the PowerShell function `Find-MarkdownFiles`
    * piping a file object `[System.IO.FileInfo]` into
      `Convert-MarkdownToHTMLFragment` (or passing it as a parameter).

`Title`
:   The page title.

`HtmlFragment`
:   A html fragment, as string or array of strings to be used as main content of
    the HTML document.

.PARAMETER Template
Optional directory containing the html template file `md-template.html` and its
resources which will be used to convert the Html fragments into standalone Html
documents. If no template directory is specified, a default factory-installed
template is used. For infomations about creating custom templates see
`New-HTMLTemplate`. See
[Template Customization](about_MarkdownToHTML.md#conversion-template-customization)
for customization options.

.PARAMETER ContentMap
Placeholder substitution mapping as described in
[Template Customization](about_MarkdownToHTML.md#conversion-template-customization).

Following substitution mappings are used by default unless explicitely defined.

| Placeholder   | Description                  | Origin                      |
|:------------- | :--------------------------- | :-------------------------- |
| `{{title}}`   | Auto generated page title    | `$inputObject.Title`        |
| `[title]`     | For backwards compatibility. | `$inputObject.Title`        |
| `{{content}}` | HTML content                 | `$inputObject.HtmlFragment` |
| `[content]`   | For backwards compatibility. | `$inputObject.HtmlFragment` |

For static HTML site projects additional mappings are defined:

| Placeholder   | Description                  | Origin       |
|:------------- | :--------------------------- | :----------- |
| `{{nav}}`     | Navigation bar content       | `Build.json` |
| `{{footer}}`  | Page footer content          | `Build.json` |

For static HTML site projects additional placeholders can be added to the map.
See
[Defining Content Mapping Rules](about_MarkdownToHTML.md#defining-content-mapping-rules)

.PARAMETER MediaDirectory
An optional directory containing additional media for the HTML site
such as images, videos etc.

.PARAMETER SiteDirectory
Directory for the generated HTML files. The Html files will be placed
in the same relative location below this directory as related Markdown document
has below the input directory. If the site directory does not exist it will be created.
If the site directory already exists its files will be retained, but possibly overwitten
by generated HTML files.

.INPUTS
An Html Fragment objects having the properties `RelativePath`,`Title`, `HtmlFragment` , and
optionally `ContentMap`. See the description of the `InputObject` parameter for details

.OUTPUTS
File objects [System.IO.FileInfo] of the generated HTML documents.

.EXAMPLE
Find-MarkdownFiles '...\Modules\MarkdownToHtml' | Convert-MarkdownToHTMLFragment | Publish-StaticHtmlSite -SiteDirectory 'e:\temp\site'

Generates a static HTML site from the Markdown files in '...\Modules\MarkdownToHtml'. This is
a simpler version of the functionality provided by the function `Convert-MarkdownToHTML`.

The generated Html file objects are returned like so:

    Mode                LastWriteTime         Length Name
    ----                -------------         ------ ----
    -a----       15.09.2019     10:03          16395 Convert-MarkdownToHTML.html
    -a----       15.09.2019     10:03          14714 Convert-MarkdownToHTMLFragment.html
    -a----       15.09.2019     10:03           4612 Find-MarkdownFiles.html
    -a----       15.09.2019     10:03           6068 MarkdownToHTML.html
    ...          ...            ...            ...

.LINK
https://wethat.github.io/MarkdownToHtml/2.8/Publish-StaticHtmlSite.html
.LINK
`Convert-MarkdownToHTML`
.LINK
`Find-MarkdownFiles`
.LINK
`Convert-MarkdownToHTMLFragment`
.LINK
`New-HTMLTemplate`
.LINK
[Defining Content Mapping Rules](about_MarkdownToHTML.md#defining-content-mapping-rules)
#>
function Publish-StaticHtmlSite {
    [OutputType([System.IO.FileInfo])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateScript({$_.RelativePath})]
        [Alias('HtmlFragment')]
        $InputObject,

        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [string]$Template = (Join-Path $SCRIPT:moduleDir.FullName 'Template'),

        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [hashtable]$ContentMap,

        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [string]$MediaDirectory,

        [parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [ValidateNotNull()]
        [string]$SiteDirectory
    )

    BEGIN {
        # Load the template
        [string[]]$htmlTemplate = Get-Content -LiteralPath (Join-Path $Template 'md-template.html')`
                                              -Encoding    UTF8

        # Create the site directory, if neccessary
        $siteDir = Get-Item -LiteralPath $SiteDirectory -ErrorAction:SilentlyContinue
        if (!$siteDir) {
            $siteDir = New-Item -Path $SiteDirectory -ItemType Directory -ErrorAction:SilentlyContinue
        }

        if (!$siteDir) {
            throw("Unable to create site directory: $SiteDirectory")
        }
        Write-Verbose "Publishing to '$siteDir' using HTML template '$Template'."

        # Copy the template resources to the site directory
        Copy-Item -Path "$Template/*" -Recurse -Exclude 'md-template.html' -Destination $siteDir -Force
    }

    PROCESS {
        [System.IO.FileInfo]$htmlFile = Join-Path $siteDir.FullName ([System.IO.Path]::ChangeExtension($InputObject.RelativePath,'html'))
        Write-Verbose  "$($InputObject.RelativePath) -> $($htmlFile.Name)"
        $htmlfile.Directory.Create() # make sure we have all directories

        # prepare the map for content injection
        # we need a pristine map every time
        if ( $InputObject.HTMLFragment -is [Array]) {
            # a single string wanted
            $InputObject.HTMLFragment = $InputObject.HTMLFragment -join ''
        }
        $map = @{
            '{{title}}'   = $InputObject.Title
            '[title]'     = $InputObject.Title
            '{{content}}' = $InputObject.HTMLFragment
            '[content]'   = $InputObject.HTMLFragment
        }

        # transfer the properties from the given map
        foreach ($k in $ContentMap.Keys) {
            $value = $ContentMap[$k]
            if ($value -is [ScriptBlock]) {
                # Compute the substitution value
                $value = Invoke-Command -ScriptBlock $value -ArgumentList $InputObject | Out-String
            }
            $map[$k] = $value
        }

        # Inject page content
        $htmlTemplate | Update-ResourceLinks -RelativePath $InputObject.RelativePath `
        | Expand-HtmlTemplate -ContentMap $map `
        | Out-File -LiteralPath $htmlFile -Encoding utf8
        $htmlFile
    }

    END {
        if ($MediaDirectory) {
          # copy all assets to the site directory
          Copy-Item -Path "$MediaDirectory/*" -Recurse -Exclude '*.md','*.markdown','Build.json' -Destination $SiteDirectory -Force
        }
    }
}

<#
.SYNOPSIS
Find all Markdown file below a given directory.

.DESCRIPTION
Recursively scans a directory and generates annotated `[System.IO.FileInfo]`
objects for each Markdown file.

The annotations are of type `NoteProperty`. They are used in the downstream
conversion process to determine the relative path of a markdown file (property
`RelativePath`) and the build configuration in effect for the Markdown file
(property `EffectiveConfiguration`).

.PARAMETER Path
Path to a directory containing Markdown files.

.PARAMETER Exclude
Omit the specified files. A comma separated list of path elements or
patterns, such as "D*.md". Wildcards are permitted.

.PARAMETER BuildConfiguration
Build configuration object. Usually obtained by reading a `Build.json` configuration
file. See the [Static Site](about_MarkdownToHTML.md#static-site-project-customization)
for details about configuration options and structure. This configuration is
cascaded with configurations from `Build.json` files found at or above the
location of the Markdown file.

.INPUTS
None

.OUTPUTS
An `[System.IO.FileInfo]` object for each Markdown file found below
the given directory. The emitted
`[System.IO.FileInfo]` objects are annotated with properties of type `NoteProperty`:

`RelativePath`
:   Specifies the relative path of the Markdown file below the
    directory specified in the `Path` parameter. The `RelativePath` property is
    **mandatory** if `Publish-StaticHtmlSite` is used in the downstream conversion
    pipeline to generate HTML files in the correct locations.

`EffectiveConfiguration`
:   An object similar to the one specified in parameter `-BuildConfiguration`.
    Describes the build configuration in effect at the location of the Markdown
    file. The effective configuration is determined by cascading all `Build.json`
    files in at and above the location of the Markdown file.

.EXAMPLE
Find-MarkdownFiles -Path '...\Modules\MarkdownToHtml' | Select-Object -Property Mode,LastWriteTime,Length,Name,RelativePath | Format-Table

Returns following annotated Markdown file objects of type `[System.IO.FileInfo]` for this PowerShell module:

    LastWriteTime        Length Name                       RelativePath
    -------------        ------ ----                       ------------
    13.09.2019 13:56:21  10751  Convert-MarkdownToHTML.md  Documentation\Convert-MarkdownToHTML.md
    13.09.2019 13:56:20   3348  MarkdownToHTML.md          Documentation\MarkdownToHTML.md
    13.09.2019 13:56:21   7193  New-HTMLTemplate.md        Documentation\New-HTMLTemplate.md
    11.09.2019 17:01:13   4455  README.md                  ReferenceData\katex\README.md
    ...                   ...   ...                        ...

.LINK
https://wethat.github.io/MarkdownToHtml/2.8/Find-MarkdownFiles.html
.LINK
`Convert-MarkdownToHTML`
.LINK
`Convert-MarkdownToHTMLFragment`
.LINK
`Publish-StaticHtmlSite`
.LINK
`New-HTMLTemplate`
#>
function Find-MarkdownFiles {
    [OutputType([System.IO.FileInfo])]
    [CmdletBinding()]
    param (
        [SupportsWildcards()]
        [parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [ValidateNotNullorEmpty()]
        [string]$Path,

        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [string[]]$Exclude,

        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [PSCustomObject]$BuildConfiguration
    )

    $except = if ($Exclude) {$exclude} else {@()}
    Write-Verbose "Scanning $Path for Markdown files except $except"

    # collect all build configurations and annotate the file objects with the
    # effective configuration.
    foreach ($topItem in Get-Item -Path $Path) {
        [string]$basePath=$null
        switch ($topItem) {
            {$_ -is [System.IO.FileInfo]} {
                $basePath = $topItem.DirectoryName
                break
            }
            {$_ -is [System.IO.DirectoryInfo]} {
                $basePath = $topItem.FullName
                break
            }
        }
        if ($basePath) {
            # process everything under this starting point
            $basePath = $basePath.TrimEnd('/\')

            Get-ChildItem -Path $topItem `
                          -Recurse `
                          -File `
                          -Include '*.md','*.Markdown' `
                          -Exclude $except `
            | ForEach-Object {
                    # Annotate the markdown file object with the relative path
                    # to root
                    [string]$relativePath = $_.FullName.Substring($basePath.Length+1)
                    # Annotate the file object with a relative path (contains backslashes)
                    Add-Member -InputObject $_ `
                               -MemberType NoteProperty `
                               -Name 'RelativePath' `
                               -Value $relativePath
                    $_ # pass it on
              } `
            | ForEach-Object `
                -Begin {
                    # Cache all local build configurations so that the effective
                    # configuration for each markdown file can be determined.
                    $effectiveBuildConfigs = $null
                    if ($BuildConfiguration) {
                        # Expand directories in the site_navigation
                        if ($BuildConfiguration.site_navigation) {
                            $BuildConfiguration.site_navigation = @(
                            $BuildConfiguration.site_navigation `
                            | Expand-DirectoryNavigation -LiteralPath $basePath)
                        }

                        # gather all available local configurations and cache them
                        # Mark the root configuration
                        Add-Member -InputObject $BuildConfiguration `
                                   -MemberType NoteProperty `
                                   -Name 'Joined' `
                                   -Value $true
                        $effectiveBuildConfigs = @{'..' = $BuildConfiguration} # default build configurations
                        # collect and load all Build.json files.
                        Write-Verbose "Scanning $($topItem) for Build.json configuration files..."
                        Get-ChildItem -LiteralPath $topItem -Recurse -File -Filter 'Build.json' `
                        | ForEach-Object {
                            # load the configuration file we found
                            $thisConfig = Get-Content $_.FullName | ConvertFrom-Json
                            # make sure the accumulating properties exist
                            if ($thisConfig.site_navigation) {
                                $thisConfig.site_navigation = @(
                                    $thisConfig.site_navigation `
                                    | Expand-DirectoryNavigation -LiteralPath $_.DirectoryName)
                            } else {
                                Add-Member -InputObject $thisConfig `
                                           -MemberType NoteProperty `
                                           -Name 'site_navigation' `
                                           -Value @()
                            }
                            # Relative path to this config file. This information
                            # is used later to shorten the relative URLs as much as
                            # possible.
                            $navRoot = $_.DirectoryName.Substring($basepath.Length).TrimStart('\')
                            # set the relative root path for the additional site navigation specs
                            foreach ($navspec in $thisConfig.site_navigation) {
                                if ($navspec -is [hashtable]) {
                                    $navspec['NavRoot'] = $navRoot
                                } else {
                                    Add-Member -InputObject $navspec `
                                               -MemberType NoteProperty `
                                               -Name 'NavRoot' `
                                               -Value $navRoot
                                }
                            }
                            $effectiveBuildConfigs[$navRoot] = $thisConfig }
                    }
                    # these configuration options are ignored in subtree
                    # Build.json files.
                    $bannedProperties = @('site_navigation'
                                          'Exclude'
                                          'HTML_template'
                                          'markdown_extensions'
                                          'github_pages')
                } `
                -Process {
                    # Annotate each markdown file with the effective build
                    # configuration.
                    if ($effectiveBuildConfigs) {
                        $md = $_
                        # determine and attach the effective build configuration
                        # to this markdown file
                        [string]$context = Split-Path $md.RelativePath -Parent
                        $effectiveCfg = $effectiveBuildConfigs[$context];
                        if (!$effectiveCfg) {
                            $effectiveCfg = New-Object 'PSCustomObject' `
                                                       -Property @{'site_navigation' = @()}
                            # make a root configuration for this configuration
                            # context directory.
                            $effectiveBuildConfigs[$context] = $effectiveCfg
                        }
                        if (!$effectiveCfg.Joined) {
                            # walk up the directory tree joining all configurations

                            while (!$context.Equals('..')) {
                                $context = if ([string]::Empty.Equals($context)) {
                                                '..' # default configuration at last
                                            } else {
                                                Split-Path $context -Parent
                                            }

                                $thisCfg = $effectiveBuildConfigs[$context]
                                if ($thisCfg) {
                                    # found an effective build configuration
                                    $effectiveCfg.site_navigation =  $thisCfg.site_navigation + $effectiveCfg.site_navigation

                                    Get-Member -InputObject $thisCfg `
                                               -MemberType NoteProperty `
                                    | Where-Object { -Not ($_.Name -in $bannedProperties) `
                                                     -and -Not (Get-Member -InputObject $effectiveCfg `
                                                                           -MemberType NoteProperty `
                                                                           -Name $_.Name)} `
                                    | ForEach-Object {
                                        Add-Member -InputObject $effectiveCfg `
                                                   -MemberType NoteProperty `
                                                   -Name $_.Name `
                                                   -Value $thisCfg."$($_.Name)"

                                    }
                                    if ($thisCfg.Joined) {
                                        break
                                    }
                                }
                            }
                        }
                        Add-Member -InputObject $md `
                                    -MemberType NoteProperty `
                                    -Name 'EffectiveConfiguration' `
                                    -Value $effectiveCfg
                        $md # pass on annotated object
                    } else {
                        $_ # pass on
                    }
                }
        }
    }
}

<#
.SYNOPSIS
Convert Markdown files to static HTML files.

.DESCRIPTION
This function reads all Markdown files from a source folder and converts each
of them to a standalone html document using:

* configurable [Markdown extensions](about_MarkdownToHTML.md#supported-markdown-extensions)
* a customizable or default HTML template. See `New-HTMLTemplate` about
  the creation of custom templates.

.PARAMETER Path
Path to Markdown files or directories containing Markdown files.

.PARAMETER Template
Optional directory containing the html template file `md-template.html` and its resources.
If no template directory is specified, the factory-installed default template is used.
For information about creating custom templates see `New-HTMLTemplate`.

.PARAMETER IncludeExtension
Comma separated list of Markdown parsing extensions to use.
See [about_MarkdownToHTML](MarkdownToHTML.md#markdown-extensions) for an
annotated list of supported extensions.

.PARAMETER ExcludeExtension
Comma separated list of Markdown parsing extensions to exclude.
Mostly used when the the 'advanced' parsing option is included and
certain individual options need to be removed,

.PARAMETER MediaDirectory
An optional directory containing additional media for the Html site
such as images, videos etc. Defaults to the directory given in `-Path`

.PARAMETER SiteDirectory
Directory for the generated HTML files. The Html files will be placed
in the same relative location below this directory as related Markdown document
has below the Markdown source directory.

.INPUTS
This function does not read from the pipe.

.OUTPUTS
File objects `[System.IO.FileInfo]` of the generated HTML files.

.EXAMPLE
Convert-MarkdownToHTML -Path 'E:\MyMarkdownFiles' -SiteDirectory 'E:\MyHTMLFiles'

Convert all Markdown files in `E:\MyMarkdownFiles` and save the generated HTML
files to `E:\MyHTMLFiles`.

.EXAMPLE
Convert-MarkdownToHTML -Path 'E:\MyMarkdownFiles' -Template 'E:\MyTemplate' -SiteDirectory 'E:\MyHTMLFiles'

Convert all Markdown files in `E:\MyMarkdownFiles` using the 'common' parsing
configuration and the custom template in `E:\MyTemplate`.

The generated HTML files are saved to `E:\MyHTMLFiles`.

.EXAMPLE
Convert-MarkdownToHTML -Path 'E:\MyMarkdownFiles' -SiteDirectory 'E:\MyHTMLFiles' -IncludeExtension 'advanced','diagrams'

Convert all Markdown files in `E:\MyMarkdownFiles` using the 'advanced' and
'diagrams' parsing extension and the default template.

The generated HTML files are saved to `E:\MyHTMLFiles`.

.EXAMPLE
Convert-MarkdownToHTML -Path 'E:\MyMarkdownFiles' -MediaDirectory 'e:\Media' -SiteDirectory 'E:\MyHTMLFiles' -IncludeExtension 'advanced','diagrams'

Convert all Markdown files in `E:\MyMarkdownFiles` using
* the 'advanced' and 'diagrams' parsing extension.
* the default template
* Media files (images, Videos, etc.) from the directory `e:\Media`

The generated HTML files are saved to the directory `E:\MyHTMLFiles`.

.LINK
https://wethat.github.io/MarkdownToHtml/2.8/Convert-MarkdownToHTML.html
.LINK
`New-HTMLTemplate`
.LINK
[Markdown extensions](about_MarkdownToHTML.md#supported-markdown-extensions)
#>
function Convert-MarkdownToHTML {
    [OutputType([System.IO.FileInfo])]
    [CmdletBinding()]
    param(
            [SupportsWildcards()]
            [parameter(Mandatory=$true,ValueFromPipeline=$false)]
            [ValidateNotNullorEmpty()]
            [Alias('Markdown')]
            [string]$Path,

            [parameter(Mandatory=$false,ValueFromPipeline=$false)]
            [string]$Template =  (Join-Path $SCRIPT:moduleDir.FullName 'Template'),

            [parameter(Mandatory=$false,ValueFromPipeline=$false)]
            [string[]]$IncludeExtension = @('common'),

            [parameter(Mandatory=$false,ValueFromPipeline=$false)]
            [string[]]$ExcludeExtension = @(),

            [parameter(Mandatory=$false,ValueFromPipeline=$false)]
            [string]$MediaDirectory = $Path,

            [parameter(Mandatory=$true,ValueFromPipeline=$false)]
            [ValidateNotNullorEmpty()]
            [Alias('Destination')]
            [string]$SiteDirectory
        )
    Write-Verbose "$Path -> $SiteDirectory"

    Find-MarkdownFiles -Path $Path `
    | Convert-MarkdownToHTMLFragment -IncludeExtension $IncludeExtension `
                                     -ExcludeExtension $ExcludeExtension `
    | Publish-StaticHtmlSite -MediaDirectory $MediaDirectory `
                             -SiteDirectory $SiteDirectory `
                             -Template $Template
}

<#
.SYNOPSIS
Create a customizable template directory for building HTML files from
Markdown files.

.DESCRIPTION
The factory-default conversion template is copied to the destination directory
to seed the customization process. The new template directory contains the
resources necesssary to generate fully functional, standalone HTML files.

See
[Conversion Template Customization](about_MarkdownToHTML.md#conversion-template-customization)
for ways to customize the template.

.PARAMETER Destination
Location of the new conversion template directory. The template directory
should be empty or non-existent.

.EXAMPLE
New-HTMLTemplate -Destination 'E:\MyTemplate'

Create a copy of the factory template in `E:\MyTemplate` for customization.

.INPUTS
This function does not read from the pipe.

.OUTPUTS
The new conversion template directory `[System.IO.DirectoryInfo]`.

.NOTES
## Updating Custom Conversion Templates

Updates to the MarkdownToHtml module usually come with an updated factory
template. Unless you want to take advantage of the new template resources or there
is a [known incompatibility](MarkDownToHTML.md#known-incompatibilities),
**no action** is needed.

:point_up: A convenient way to upgrade a custom template is to perform the steps
below:
1. Use `New-HTMLTemplate` to create a temporary custom template:
   ~~~powershell
   PS> New-HTMLTemplate -Destination 'TempTemplate'
   ~~~
2. Replace all resources in the custom template you want to update
   with the resources from `TempTemplate`. Do **not** overwite
   template files you migh have customized. Candidates are
   `Template/md-template.html` and `Template\styles\md-styles.css`
3. Merge changes to `Template/md-template.html` and
   `Template\styles\md-styles.css` using your favorite merge tool.

.LINK
https://wethat.github.io/MarkdownToHtml/2.8/New-HTMLTemplate.html
.LINK
`New-StaticHTMLSiteProject`

#>
function New-HTMLTemplate {
    [OutputType([System.IO.DirectoryInfo])]
    [CmdletBinding()]
    param(
            [parameter(Mandatory=$true,ValueFromPipeline=$false)]
            [ValidateNotNullorEmpty()]
            [string]$Destination
         )
    $template = Join-Path $SCRIPT:moduleDir.FullName 'Template'
    $assets = Join-Path $SCRIPT:moduleDir.FullName 'Template.assets'
    $outdir = Get-Item -LiteralPath $Destination -ErrorAction:SilentlyContinue

    # Create the site directory
    if ($null -eq $outdir ) {
        $outdir = New-Item -Path $Destination -ItemType Directory -ErrorAction:SilentlyContinue
    }

    if ($null -eq $outdir -or $outdir -isnot [System.IO.DirectoryInfo]) {
        throw("Unable to create directory $Destination")
    }
    ## Copy the template to the output directory
    Copy-Item -Path "${template}/*" -Recurse -Destination $outDir
    Copy-Item -Path "${assets}/*" -Recurse -Destination $outDir -ErrorAction:SilentlyContinue
    $outDir
}
<#
.SYNOPSIS
Create a customizable Markdown to HTML site conversion project.

.DESCRIPTION
Create a new static HTML site project directoy with some default content
ready for building.

A single markdown file (`README.md`) is provided as initial content. It explains
some customization options and the typical site authoring process.
It is recommended to build the project by executing its build script
`Build.ps1`. This creates the initial static HTML site with the HTML version of
the README (`docs/README.html`) which is more pleasant to read also showcases
some features.

See [Project Customization](about_MarkdownToHTML.md#static-site-project-customization)
for details about the project directory structure and site customization.

.PARAMETER ProjectDirectory
The location of the new Markdown to HTML site conversion project.

.INPUTS
None

.OUTPUTS
The new project directory object `[System.IO.DirectoryInfo]`

.EXAMPLE
New-StaticHTMLSiteProject -ProjectDirectory MyProject

Create a new conversion project names 'MyProject' in the current directory. The
project is ready for build.

.NOTES
## Upgrading Static Site Projects

Upgrades to the MarkdownToHtml module usually come with an updated factory
template and sometimes also with an updated project build scripts (`Build.ps1`) and
project configurations (`Build.json`).

Unless you want to take advantage of the new template resources and build files
or there is a [Known Incompatibility](MarkDownToHTML.md#known-incompatibilities),
no action is needed.

:point_up: A convenient way to upgrade an existing static site project is described below:

1. Use `New-StaticHTMLSiteProject` to create a temporary static site project:
   ~~~powershell
   PS> New-HTMLTemplate -Destination 'TempProject'
   ~~~
2. Replace all resources in `Template` directory of tje static site project you
   want to update with the resources from `TempProject\Template`. Do **not** overwite
   template files you migh have customized. Candidates are
   `Template\md-template.html` and `Template\styles\md-styles.css`
3. Merge changes to following files using your favorite merge tool:
   * `TempProject\Template\md-template.html`
   * `TempProject\Template\styles\md-styles.css`
   * `TempProject\Build.json`
   * `TempProject\Build.ps1`

.LINK
https://wethat.github.io/MarkdownToHtml/2.8/New-StaticHTMLSiteProject.html
.LINK
`New-HTMLTemplate`
.LINK
[Project Customization](about_MarkdownToHTML.md#static-site-project-customization)
.LINK
[Factory Configuration](MarkdownToHTML.md#factory-configuration)
#>
function New-StaticHTMLSiteProject {
    [OutputType([System.IO.DirectoryInfo])]
    [CmdletBinding()]
    param(
            [parameter(Mandatory=$true,ValueFromPipeline=$false)]
            [ValidateNotNull()]
            [string]$ProjectDirectory
         )
    $diritem = Get-Item -Path $ProjectDirectory -ErrorAction:SilentlyContinue

    if ($diritem) {
        throw "$ProjectDirectory already exists!"
    }

    $diritem = New-Item -Path $ProjectDirectory -ItemType Directory

    # Copy project template to new directory
    Write-Information "Copying project files ..." -InformationAction Continue
    Copy-Item -Path "$moduleDir/ProjectTemplate/*" -Destination $diritem -Recurse
        # copy the standard assets too
    Copy-Item -Path "$moduleDir/Template.assets/*" `
              -Destination "$diritem/Template" `
              -Recurse -ErrorAction:SilentlyContinue

    Write-Information '' -InformationAction Continue
    Write-Information "Project '$($diritem.Name)' ready!" -InformationAction Continue
    Write-Information "1. Run the build script '$ProjectDirectory/Build.ps1'" -InformationAction Continue
    Write-Information "2. Open '$ProjectDirectory/docs/README.html' in the browser!" -InformationAction Continue
    $diritem
}

# Match resource links
[regex]$SCRIPT:linkRE = New-Object regex '((src|href)\s*=\s*[''"])(?!http|ftp|\.|/|#)'

<#
.SYNOPSIS
Rewrite resource links which are relative to the projects root to make them
valid for other site locations.

.DESCRIPTION
HTML templates use links which are relative to the HTML site root directory
to link to resources such as JavaScript, css, or image files. When a HTML
file is assembled (e.g with ``Publish-StaticHtmlSite``) using such a template,
the resource links in the template may not be valid for the location of that
HTML file. This command uses the relative position of the new HTML file in the
site to compute valid resource links and update the template.

.PARAMETER InputObject
An html fragment containing root-relative resource links.

.PARAMETER RelativePath
The path to a Markdown (`*.md`) or HTML (`*.html`) file relative to its root
directory. That file's relative path
is used to adjust the links of in the given navigation bar item,
so that it can be reached from the location of the HTML page currently being
assembled.

The given path should use forward slash '/' path separators.

.INPUTS
HTML fragments containing resource links relative to the HTML site root.

.OUTPUTS
HTML fragment with updated resource links.

.EXAMPLE
Update-ResourceLinks -HtmlFragment $fragment -RelativePath 'a/b/v/test.html'

Adjust link to a resource at `images/logo.png` so that it is valid for a
file located at `a/b/v/test.html`. The input `$fragment` is defined as:

~~~ PowerShell
$fragment = '<img width="90%" src="images/logo.png"/>'
~~~

Outut:

~~~ html
<img width="90%" src="../../../images/logo.png"/>
~~~

.LINK
https://wethat.github.io/MarkdownToHtml/2.8/Update-ResourceLinks.html
.LINK
`Publish-StaticHtmlSite`
#>
function Update-ResourceLinks {
    [OutputType([string])]
    [CmdletBinding()]

    param(
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [AllowEmptyString()]
        [Alias('HtmlFragment')]
        [string]$InputObject,

        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [string]$RelativePath = '')

    BEGIN {
        # Determine the relative navigation path of the current page to root
	    $up = '../' * ($RelativePath.Replace("\","/").Split('/').Length - 1)
    }
    PROCESS {
        $SCRIPT:linkRE.Replace($InputObject,'$1' + $up)
    }
}

<#
.SYNOPSIS
Verify that relative links to files and images exist in a Markdown
source tree.

.DESCRIPTION
Scans a directory tree for Markdown files and `Build.json` files. Relative links found in these
files are checked. Broken links are reported. Link checking is not restricted to files in a
static site project generated by `New-StaticHTMLSiteProject`, though that is most likely its
primary use.

.PARAMETER Path
Path to the root of a directory tree containing Markdown sources.
Typically this is the sources directory configured in `Build.json` by
`markdown_dir`. See
[Static Site Project Customization](about_MarkdownToHTML.md#static-site-project-customization)
for more information.

.INPUTS
None. This function does not read anything from the pipe.

.OUTPUTS
Error objects having the following properties:

| Property | Description                                                           |
| :------: | --------------------------------------------------------------------- |
| `File`   | Path to file containing the proken link.                              |
| `Line`   | Line number or config option containing the error.                    |
| `Link`   | The broken link or navigation specification (for `Build.jdon files`). |
| `Error`  | Description of the error                                              |

.EXAMPLE
Test-LocalSiteLinks -Path E:\lab\...\markdown

Generate a report for broken relative links in Markdown files and `Build.json`
files found under the `E:\lab\...\markdown` directory tree.

The broken links report looks similar to this:
~~~
File                                              Line Link                      Error
----                                              ---- ----                      -----
E:\lab\...\Settings\Manage Settings.md               5 images/RibbonSetting1.png File not found
E:\lab\...\Settings\Manage Settings.md              14 Tabs/About Tab.md         Malformed url
E:\lab\...\Settings\Build.json         site_navigation {"Options": "Tabs1"}     File not found
~~~

The output above shows the theww types of error that are currently recognized:
1. The file `RibbonSetting1.png` is not found in the `images` directory next
   to file `Manage Settings.md`
2. The link `Tabs/About Tab.md` is malformed because urls cannot contain spaces.
   The link needs to be URL encoded. The correct way ro write this url is:
   `Tabs/About%20Tab.md`
3. A navigation specification with label `Options` in the `site_navigation`
   section of the reported `Build.json` file points to the non-existing
   file or directory `Tabs1`

.EXAMPLE
Test-LocalSiteLinks -Path E:\lab\...\markdown | Out-GridView

Generates a report for broken relative links in Markdown files and `Build.json`
files found under the `E:\lab\...\markdown` directory tree and opens a
dialog window to display the errors.

.LINK
https://wethat.github.io/MarkdownToHtml/2.8/Test-LocalSiteLinks.html
.LINK
[Static Site Project Customization](about_MarkdownToHTML.md#static-site-project-customization)
.LINK
`New-StaticHTMLSiteProject`
#>
function Test-LocalSiteLinks {
    [OutputType([string])]
    [CmdletBinding()]
    param(
        [SupportsWildcards()]
        [parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [ValidateNotNullorEmpty()]
        [string]$Path
    )
    $mdlinkRE = New-Object regex '\]\(([^()]+)\)'

    foreach ($siteDir in Get-Item -Path $Path) {
        # Inspect links in Markdown files
        Get-ChildItem $siteDir -Recurse -File -Include '*.md','*.markdown' `
        | ForEach-Object {
            [string[]]$content = Get-Content $_
            for ($i = 0; $i -lt $content.Length; $i++) {
                $line = $content[$i]
                foreach ($m in  $mdlinkRE.Matches($line)) {
                   $group = $m.Groups[1]
                   [System.Uri]$u = $group.Value
                   if (-not $u.IsAbsoluteUri) {
                        $parts = [System.Web.HttpUtility]::UrlDecode($u.OriginalString) -split '#'
                        $target = Join-Path $_.DirectoryName $parts[0]
                        if (-not (Test-Path $target)) {
                            $error = 'File not found'
                        } elseif ($u.OriginalString.Contains(' ')) {
                            $error = 'Malformed url'
                        } else {
                            $error  = [string]::Empty
                        }
                        if (-not [string]::IsNullOrEmpty($error)) {
                            $reportObject = New-Object PSCustomObject
                            Add-Member -InputObject $reportObject `
                                       -Name 'File' `
                                       -MemberType NoteProperty `
                                       -Value $_.FullName
                            Add-Member -InputObject $reportObject `
                                       -Name 'Line' `
                                       -MemberType NoteProperty `
                                       -Value ($i+1)
                            Add-Member -InputObject $reportObject `
                                       -Name 'Link' `
                                       -MemberType NoteProperty `
                                       -Value $u.OriginalString
                            Add-Member -InputObject $reportObject `
                                       -Name 'Error' `
                                       -MemberType NoteProperty `
                                       -Value $error
                            $reportObject
                        }
                   }
                }
            }
        }
        # Inspect navigation links in Build.json files
        Get-ChildItem $siteDir -Recurse -File -Include 'Build.json' `
        | ForEach-Object {
            $json = $_
            $thisConfig = Get-Content $json.FullName | ConvertFrom-Json
            $thisConfig.site_navigation | ForEach-Object {
               $name = Get-NavSpecKey -NavSpec $_
               [System.Uri]$u = $_.$name
               if (-not $u.IsAbsoluteUri) {
                   $parts = [System.Web.HttpUtility]::UrlDecode($u.OriginalString) -split '#'
                   $target = Join-Path $json.DirectoryName $parts[0]
                        if (-not (Test-Path $target)) {
                            $reportObject = New-Object PSCustomObject
                            Add-Member -InputObject $reportObject `
                                       -Name 'File' `
                                       -MemberType NoteProperty `
                                       -Value $json.FullName
                            Add-Member -InputObject $reportObject `
                                       -Name 'Line' `
                                       -MemberType NoteProperty `
                                       -Value 'site_navigation'
                            Add-Member -InputObject $reportObject `
                                       -Name 'Link' `
                                       -MemberType NoteProperty `
                                       -Value "{`"$name`": `"$($u.OriginalString)`"}"
                            Add-Member -InputObject $reportObject `
                                       -Name 'Error' `
                                       -MemberType NoteProperty `
                                       -Value 'File not found'
                            $reportObject
                        }
               }
            }
        }
    }
}

# SIG # Begin signature block
# MIIFYAYJKoZIhvcNAQcCoIIFUTCCBU0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUBXu1Qu6Cg2LRrfxJnbJ2rS9w
# rHqgggMAMIIC/DCCAeSgAwIBAgIQaejvMGXYIKhALoN4OCBcKjANBgkqhkiG9w0B
# AQUFADAVMRMwEQYDVQQDDApXZXRIYXQgTGFiMCAXDTIwMDUwMzA4MTMwNFoYDzIw
# NTAwNTAzMDgyMzA0WjAVMRMwEQYDVQQDDApXZXRIYXQgTGFiMIIBIjANBgkqhkiG
# 9w0BAQEFAAOCAQ8AMIIBCgKCAQEArNo5GzE4BkP8HagZLFT7h189+EPxP0pmiSC5
# yi34ZctnpyFUz+Cv547+MvzAr0uRuLkxn6ArBkVLeHVAB58jenSeLwDFls5gS0I+
# pRJWO9eyyT64EcUSCMlfMLW2q1hzjfFckFR6iFnGp3TkE0s1kQANUNjAR9axC6ju
# 4dpilIupCHW+/0s9aGz7LYuRQGcy3uIL9TURKdBtOsMOBeclUsEoFSEp/0D30E8r
# PNk/VLu57G5H9n3HuX/DSBR2CL8LzOOv981hiS+SCds/pHqjCX9Qj+j47Kv7xZ1i
# ha2fg4AEHDGbL/WJGnTpUKath+EmgmFRlsP7PgnZr4anvGdcdQIDAQABo0YwRDAO
# BgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFKtE
# 8xMwn4kGbe8AzXY0ineK5ToHMA0GCSqGSIb3DQEBBQUAA4IBAQAgaUJkHD9192H7
# OUhf9W3gR0ZkApD5fnPqsIgS91JFQ2fCnonudJinwbODs01yA55uUw4GJUnAKQOx
# 6auVAC5KVzE2dMDbOrBOseoKj12EbzbF509FkVoT5O77NDpFrGErR1zmQ8fd1DXw
# FAFC1x1vpxW7/F6g+xewpqlFKzjkPeEvLgyoUmKMCOnT0JdXS0BfyAyyIfHwvILo
# 2eJWVG2UMioKOJ6vsttTu8mQgVZlfcoF6r81ee3hTEK24aHNR+frHmyrL9UplZxD
# AuoUGVzYdDyOejlLPm+d+ew1d6dTf9QfurRxoKgI6OMOVI3iIIXd6HTiIW4ACwI9
# iUjry3dVMYIByjCCAcYCAQEwKTAVMRMwEQYDVQQDDApXZXRIYXQgTGFiAhBp6O8w
# ZdggqEAug3g4IFwqMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgACh
# AoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAM
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRaI7CmUUeCEGLHHHfmGKmUYNld
# 8jANBgkqhkiG9w0BAQEFAASCAQAojAs5/5qH035DrdFhC8xD96q2M5ELtfEh1Frf
# oP7DOut4/lOrMw/GWwxtDzZ9tZkXBeUHgrjL33hNv/oaYaO47CCsimP5MkVhjGkr
# 7km7vZrrwWr+w94DpmB36KxvDfBjWaDzS8KGcfgc2I9r4s84TK7WotMFnP5WNjuj
# dG7FYIsqsQvLEzA/hc28+KbfGSzxr/SVDgygAuUbri4h9kTQ1cs6AWbCOFptnLxc
# ry2TQ5fft21DDCy6zuR60/DtvSB2L3N8t/Oi8BMbCaheyZucT2wcpsqu95OYnBQN
# DKIH7QHcAuUACWYloISJGRxbc2Y2bSqQv7PsWUwRtDHpTNdI
# SIG # End signature block

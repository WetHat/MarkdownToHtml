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
https://wethat.github.io/MarkdownToHtml/2.6/Expand-HtmlTemplate.html
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
https://wethat.github.io/MarkdownToHtml/2.6/Publish-StaticHtmlSite.html
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
          Copy-Item -Path "$MediaDirectory/*" -Recurse -Exclude '*.md','*.markdown' -Destination $SiteDirectory -Force
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
https://wethat.github.io/MarkdownToHtml/2.6/Find-MarkdownFiles.html
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
                        # gather all available local configurations and cache them
                        # Mark the root configuration
                        Add-Member -InputObject $BuildConfiguration `
                                   -MemberType NoteProperty `
                                   -Name 'Joined' `
                                   -Value $true
                        $effectiveBuildConfigs = @{'' = $BuildConfiguration} # location specific build configurations
                        # collect and load all Build.json files.
                        Write-Verbose "Scanning $($topItem) for Build.json configuration files..."
                        Get-ChildItem -LiteralPath $topItem -Recurse -File -Filter 'Build.json' `
                        | ForEach-Object {
                            # load the configuration file we found
                            $thisConfig = Get-Content $_.FullName | ConvertFrom-Json
                            # make sure the accumulating properties exist
                            if (!$thisConfig.site_navigation) {
                                Add-Member -InputObject $thisConfig `
                                           -MemberType NoteProperty `
                                           -Name 'site_navigation' `
                                           -Value @()
                            }
                            # Relative path to this config file. This information
                            # is used later to shorten the relative URLs as much as
                            # possible.
                            $navRoot = $_.DirectoryName.Substring($basepath.Length + 1)
                            # set the relative root path for the additional site navigation specs
                            foreach ($navspec in $thisConfig.site_navigation) {
                                Add-Member -InputObject $navspec `
                                           -MemberType NoteProperty `
                                           -Name 'NavRoot' `
                                           -Value $navRoot
                            }
                            # record this configuration
                            $effectiveBuildConfigs[$navRoot] = $thisConfig }
                    }
                    # these configuration options are ignored in local
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

                            while ($context.Length -gt 0) {
                                $context = Split-Path $context -Parent
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
https://wethat.github.io/MarkdownToHtml/2.6/Convert-MarkdownToHTML.html
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

    Find-MarkdownFiles -Path $Path -Verbose:$Verbose `
    | Convert-MarkdownToHTMLFragment -IncludeExtension $IncludeExtension `
                                     -ExcludeExtension $ExcludeExtension `
                                     -Verbose:$Verbose `
    | Publish-StaticHtmlSite -MediaDirectory $MediaDirectory `
                             -SiteDirectory $SiteDirectory `
                             -Template $Template `
                             -Verbose:$Verbose
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

.LINK
https://wethat.github.io/MarkdownToHtml/2.6/New-HTMLTemplate.html
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

.LINK
https://wethat.github.io/MarkdownToHtml/2.6/New-StaticHTMLSiteProject.html
.LINK
`New-HTMLTemplate`
.LINK
[Project Customization](about_MarkdownToHTML.md#static-site-project-customization)
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

# Default template specifications for page navigation
$SCRIPT:defaultNavTemplate = @{
     navitem      = '<button class="navitem"><a href="{{navurl}}">{{navtext}}</a></button>';
     navlabel     = '<div class="navlabel">{{navtext}}</div>';
     navseparator = '<hr/>';
     navheading   = '<span class="navitem{{level}}">{{navtext}}</span>'
}

<#
.SYNOPSIS
Convert a navigation specification to a single item in a navigation bar of pages
in a static HTML site project created by `New-StaticHTMLSiteProject`.

.DESCRIPTION
Converts the specification for a single item in the navigation bar by
* finding an HTML template to represent the item in the navigation bar.
* replacing placeholders in the template by data taken from the
  specification.
* adjusting the navigation link based on the location in the directory tree.

.PARAMETER RelativePath
The path to a Markdown (`*.md`) or HTML (`*.html`) file relative to its
corresponding root configured in `Build.json`. For Markdown files the
root is configured by parameter `"markdown_dir"` for html files it is
`"site_dir"`. This parameter will be used to compute relative resource
and navigation bar links for the HTML page currently
being assembled.

The given path should use forward slash '/' path separators.

.PARAMETER NavSpec
An object or dictionary with exactly one `NoteProperty` or key representing
a single key-value pair. This parameter provides the data for one item in
the navigation bar.

Following key-value pairs are recognized:

+ :----: + :---: + :--------: + ---------------------------------------------- +
| Key    | Value | Template   | Description
|        |       | Name       |
+ ====== + ===== + ========== + ============================================== +
|"_text_"|"_url_"| navitem    | A clickable hyperlink where _text_ is the link
|        |       |            | text and _url_ a link to a web page or a local
|        |       |            | Markdown file. Local file links must be
|        |       |            | relative to the project root.
+ ------ + ----- + ---------- + ---------------------------------------------- +
|"_text_"| ""    | navlabel   | A label without hyperlink.
+ ------ + ----- + ---------- + ---------------------------------------------- +
| "---"  | ""    |navseparator| A speparator line.
+ ------ + ----- + ---------- + ---------------------------------------------- +

The structure of the data determines the type of navigation bar item to build.
The table above maps supported key-value combinations to the associated named
HTML templates.

.PARAMETER NavTemplate
An optional dictionary of named HTML templates.

+ :--------: + :----------: + ----------------------------------------
| Type       | Key          | HTML Template
+ ========== + ============ + ========================================
| clickable  | "navitem"    | ~~~ html
| link       |              | <button class='navitem'>
|            |              |     <a href='{{navurl}}'>{{navtext}}</a>
|            |              | </button>
|            |              | ~~~
+ ---------- + ------------ + ----------------------------------------
| label (no  | "navlabel"   | ~~~ html
| link)      |              | <div class='navlabel'>{{navtext}}</div>
|            |              | ~~~
+ ---------- + ------------ + ----------------------------------------
| separator  |"navseparator"| ~~~ html
|            |              | <hr/>
|            |              | ~~~
+ ---------- + ------------ + ----------------------------------------

The HTML templates listed represent are the values configured in `Build.json`.
These values are used for keys not provided in the given dictionary or if no
dictionary is given at all.  Additional mappings contained in dictionary are
ignored.

For more customization options see
[Static Site Project Customization](about_MarkdownToHTML.md#static-site-project-customization).

The css styles used in the templates are defined in `md-styles.css`.

During the build process the placeholders contained in the HTML template
are replaced with content extracted from the `NavSpec` parameter .

| Placeholder   | Description
| :-----------: | -----------
| `{{navurl}}`  | hyperlink to web-page or local file.
| `{{navtext}}` | link or label text

.INPUTS
Objects or hashtables with one NoteProperty or key.

.OUTPUTS
HTML element representing one navigation item for use in a vertical navigation
bar.

.EXAMPLE
ConvertTo-NavigationItem @{'Project HOME'='https://github.com/WetHat/MarkdownToHtml'} -RelativePath 'intro/about.md'

Generates a web navigation link to be put on the page `intro/about.md`.
Note:
the parameter `RelativePath` is specified but not used because the link is
non-local.

Output:

~~~ html
<button class='navitem'>
    <a href="https://github.com/WetHat/MarkdownToHtml">Project HOME</a>
</button><br/>
~~~

.EXAMPLE
ConvertTo-NavigationItem @{'Index'='index.md'} -RelativePath 'intro/about.md'

Generates a navigation link relative to `intro/about.md`. The
link target `index.md` is a page at the root of the same site, hence the link is
adjusted accordingly.

Output:

~~~ html
<button class="navitem">
    <a href="../index.html">Index</a>
</button>
~~~

.EXAMPLE
ConvertTo-NavigationItem @{'Index'='index.md'} -RelativePath 'intro/about.md' -NavTemplate $custom

Generates a navigation link relative to `intro/about.md`.
A custom template definition `$custom` is used:

~~~ PowerShell
    $custom = @{ navitem = '<li class="li-item"><a href="{{navurl}}">{{navtext}}</a></li>'}
~~~

The link target `index.md` is a page at the root of the same site, hence the link is
adjusted accordingly.

Output:

~~~ html
<li class="li-item">
    <a href="../index.html">Index</a>
</li>
~~~

.EXAMPLE
ConvertTo-NavigationItem @{'---'=''} -RelativePath 'intro/about.md'

Generates a separator line in the navigation bar. The _RelativePath_ parameter
is not used (the specification does not contain a link).

Output:

~~~ html
<hr class="navitem" />
~~~

.EXAMPLE
ConvertTo-NavigationItem @{'---'=''} -NavTemplate $custom

Generates a separator line in the navigation bar using a custom template `$custom`:

~~~ PowerShell
    $custom = @{ navseparator = '<hr class="li-item" />'}
~~~

Output:

~~~ html
<hr class="li-item" />
~~~

.EXAMPLE
ConvertTo-NavigationItem @{'Introduction'=''}

Generates a label in the navigation bar.

Output:

~~~ html
<div class='navitem'>Introduction</div>
~~~

.EXAMPLE
ConvertTo-NavigationItem @{'Introduction'=''} -NavTemplate $custom

Generates a label in the navigation bar using the custom template `$custom`:

~~~ PowerShell
    $custom = @{ navlabel = '<div class='li-item'>Introduction</div>'}
~~~

Output:

~~~ html
<div class='li-item'>Introduction</div>
~~~

.NOTES
This function is typically used in the build script `Build.ps1` to define
the contents of the navigation bar (placeholder `{{nav}}`).

.LINK
https://wethat.github.io/MarkdownToHtml/2.6/ConvertTo-NavigationItem.html
.LINK
`New-StaticHTMLSiteProject`
.LINK
`New-PageHeadingNavigation`
#>
function ConvertTo-NavigationItem {
    [OutputType([string])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [object]$NavSpec,
        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [string]$RelativePath = '',
        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [object]$NavTemplate = $defaultNavTemplate
    )
    PROCESS {
	    # create page specific navigation links by making the path relative to
        # the current location specified by `RelativePath`
        $name = if ($NavSpec -is [hashtable]) {
                    $NavSpec.Keys | Select-Object -First 1
                } else { # json object
                    (Get-Member -InputObject $NavSpec -MemberType NoteProperty | Where-Object {!$_.Name.Equals('NavRoot')}).Name
                }

        $link = $NavSpec.$name
	    if ([string]::IsNullOrWhiteSpace($link)) {
		    if ($name.StartsWith('---')) { # separator line
                [string]$navseparator = $NavTemplate.navseparator
                if (!$navseparator) {
                    $navseparator = $SCRIPT:defaultNavTemplate.navseparator
                }
			    Write-Output $navseparator # separator
		    } else { # label
                [string]$navlabel = $NavTemplate.navlabel
                if (!$navlabel) {
                    $navlabel = $SCRIPT:defaultNavTemplate.navlabel
                }
                Expand-HtmlTemplate -InputObject $navlabel -ContentMap @{'{{navtext}}' = $name}
		    }
	    } else {
            # we have an actual link
		    if (!$link.StartsWith('http')) {
			    # handle fragment on page

                $hash = $link.IndexOf('#')

                switch ($hash) {
                    {$_ -eq 0 } { # '#target'
                        $file = ''
                        $fragment = $link
                        Break
                    }
                    {$_ -ge 0} {
                        $file = $link.Substring(0,$hash)
                        $fragment = $link.Substring($hash)
                        Break
                    }
                    default {
                        $file = $link
                        $fragment = ''
                    }
                }

                # fix file type
                if ($file.EndsWith('.md') -or $file.EndsWith('.markdown')) {
	                $file = [System.IO.Path]::ChangeExtension($file,'html')
                 }

                # Re-assemble the link
                $link = $file + $fragment
		    }

            [string]$navitem = $NavTemplate.navitem
            if (!$navitem) {
                $navitem = $SCRIPT:defaultNavTemplate.navitem
            }

            # optimize the path if the nav spec has a NavRoot property
            if ($NavSpec.NavRoot) {
                $fromPathSegments = $RelativePath.Split("\")
                $toPathSegments = $NavSpec.NavRoot.Split("\")
                [int]$n = [Math]::min($fromPathSegments.Length, $toPathSegments.Length)
                [int]$unique=0
                while ($fromPathSegments[$unique] -eq $toPathSegments[$unique] -and $unique -lt $n) {
                    $unique++
                }
                $RelativePath = $fromPathSegments[$unique..$($fromPathSegments.Count-1)] -join '/'
            }
            Expand-HtmlTemplate -InputObject $navitem -ContentMap @{
                '{{navurl}}'  = $link
                '{{navtext}}' = $name
            } |  Update-ResourceLinks -RelativePath $RelativePath
	    }
    }
}

<#
.SYNOPSIS
Build navigation bar content for a HTML page from a specification and
redering templates

.DESCRIPTION
A navigation bar section for a HTML page is built by:
* processing a list of item specification which define the navigation bar
  content
* picking the appropriate HTML template for each navigation bar item
  and expanding the template using data from the item specification

.PARAMETER NavitemSpecs
An array where each item is an object or dictionary with exactly one NoteProperty`
or key representing a single key-value pair. This parameter provides the data
for **one** item in the navigation bar.

Following key-value pairs are recognized:

+ :----: + :---: + :--------: + ---------------------------------------------- +
| Key    | Value | Template   | Description
|        |       | Name       |
+ ====== + ===== + ========== + ============================================== +
|"_text_"|"_url_"| navitem    | A clickable hyperlink where _text_ is the link
|        |       |            | text and _url_ a link to a web page or a local
|        |       |            | Markdown file. Local file links must be
|        |       |            | relative to the project root.
+ ------ + ----- + ---------- + ---------------------------------------------- +
|"_text_"| ""    | navlabel   | A label without hyperlink.
+ ------ + ----- + ---------- + ---------------------------------------------- +
| "---"  | ""    |navseparator| A speparator line.
+ ------ + ----- + ---------- + ---------------------------------------------- +

The structure of the data determines the type of navigation bar item to build.
The table above maps supported key-value combinations to the associated named
HTML templates.

.PARAMETER RelativePath
The path to a Markdown (`*.md`) or HTML (`*.html`) file relative to its
corresponding root configured in `Build.json`. For Markdown files the
root is configured by parameter `"markdown_dir"` for HTML files it is
`"site_dir"`. This parameter will be used to compute relative resource
and navigation bar links for the HTML page currently
being assembled.

The given path should use forward slash '/' path separators.

.PARAMETER NavTemplate
An optional dictionary of named HTML templates.

+ :--------: + :----------: + ----------------------------------------
| Type       | Key          | HTML Template
+ ========== + ============ + ========================================
| clickable  | "navitem"    | ~~~ html
| link       |              | <button class='navitem'>
|            |              |     <a href='{{navurl}}'>{{navtext}}</a>
|            |              | </button>
|            |              | ~~~
+ ---------- + ------------ + ----------------------------------------
| label (no  | "navlabel"   | ~~~ html
| link)      |              | <div class='navlabel'>{{navtext}}</div>
|            |              | ~~~
+ ---------- + ------------ + ----------------------------------------
| separator  |"navseparator"| ~~~ html
|            |              | <hr/>
|            |              | ~~~
+ ---------- + ------------ + ----------------------------------------

The HTML templates listed represent are the values configured in `Build.json`.
These values are used for keys not provided in the given dictionary or if no
dictionary is given at all.  Additional mappings contained in dictionary are
ignored.

For more customization options see
[Static Site Project Customization](about_MarkdownToHTML.md#static-site-project-customization).

The css styles used in the templates are defined in `md-styles.css`.

During the build process the placeholders contained in the HTML template
are replaced with content extracted from the `NavSpec` parameter .

| Placeholder   | Description
| :-----------: | -----------
| `{{navurl}}`  | hyperlink to web-page or local file.
| `{{navtext}}` | link or label text

.INPUTS
None

.OUTPUTS
HTML fragment for a navigation bar.

.EXAMPLE
New-SiteNavigation -NavitemSpecs $specs -RelativePath 'a/b/c/bob.md'

Create navigation content for a file with relative path `a/b/c/bob.md` and
the specification `$specs` and default templates:

`$specs` is defined like so:

~~~PowerShell
$specs = @(
    @{ "<img width='90%' src='logo.png' />" = "README.md" },
    @{ "README" = "" },
    @{ "Home" = "README.md" },
    @{ "---" = "" }
)
~~~

Output:

~~~ html
<button class="navitem">
   <a href="../../../README.html">
      <img width='90%' src='../../../logo.png' />
   </a>
</button>
<div class="navlabel">README</div>
<button class="navitem">
   <a href="../../../README.html">Home</a>
</button>
<hr/>
~~~

Note how the relative path parameter was used to update the links.

.LINK
https://wethat.github.io/MarkdownToHtml/2.6/New-SiteNavigation.html
#>
function New-SiteNavigation {
    [OutputType([string])]
    [CmdletBinding()]

    param(
        [parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [ValidateNotNull()]
        [object[]]$NavitemSpecs,

        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [string]$RelativePath = '',

        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [object]$NavTemplate = $defaultNavTemplate
    )

    $NavitemSpecs | ConvertTo-NavigationItem -RelativePath $RelativePath `
                                             -NavTemplate $NavTemplate
}

# find headings h1 .. h6 in an HTML fragment.
$SCRIPT:hRE   = New-Object regex '<h(\d)[^<>]* id="([^"])+"[^<]*>(.+?)\s*(?=<\/h\d.*|$)'

# Match a hyperlink
$aRE = New-Object regex '</{0,1} *a[^>]*>'
Set-Alias -Name 'ConvertTo-PageHeadingNavigation' -Value 'New-PageHeadingNavigation'

<#
.SYNOPSIS
Generate navigation specifications for specified headings found in an HTML
fragment.

.DESCRIPTION
Generates a link specification for each heading in an HTML fragment which
* has an `id` attribute
* matches heading level constraint

The link specifications have the format required by `ConvertTo-NavigationItem`
to generate navigation bar items.

.PARAMETER HTMLfragment
HTML fragment object whose HTMLfragment property contains a HTMLfragment string.
Such objects are generated by `Convert-MarkdownToHTMLFragment`.

For backward compatibility this parameter can also be a plain string representing
the HTML fragment. This is deprecated.

.PARAMETER NavitemSpecs

Navigation specification for links which are to appear on every page right
before the page heading navigation links.

Usually this specification is something like:

`@{ '---' = ''}`
:   to add a separator line between the site navigation links from the
    page heading navigation links.

`@{ 'Page Content' = ''}`
:   to add the label _Page Content_ separating the site navigation links from
    the page heading navigation links.

However, all link specifications supported by the `NavitemSpecs`
of the function `New-SiteNavigation` are supported for this parameter too.

**Note!** If this parameter is specified, the HTMLfragment parameter must be
a HTML fragment object (such as the one returned by
`Convert-MarkdownToHTMLFragment`).

.PARAMETER NavTemplate
An optional dictionary of the named HTML template needed to add a heading
link to the navigation bar. The dictionary should at least contain a
`navheading` specification:

+ :--------: + :----------: + ----------------------------------------
| Type       | Key          | HTML Template
+ ========== + ============ + ========================================
| Heading    | "navheading" | ~~~ html
| link       |              |<span class='navitem{{level}}'>{{navtext}}</span>"
| template   |              | ~~~
+ ---------- + ------------ + ----------------------------------------

The HTML template above is the value defined in
`Build.json`. That value is used if the given dictionary does not define the
"navheading" mapping or if no dictionary is given at all. Additional mappings
contained in the dictionary not used by this function.

For more customization options see
[Static Site Project Customization](about_MarkdownToHTML.md#static-site-project-customization).

The css styles used in the template is defined in `md-styles.css`.

Following placeholders in the HTML template are recognized.

| Placeholder   | Description
| :-----------: | -----------
| `{{level}}`   | heading level.
| `{{navtext}}` | heading text

During the build process the placeholders are replaced with content taken from
the `NavSpec` parameter.

.PARAMETER HeadingLevels
A string of numbers denoting the levels of the headings to add to the navigation
bar. By default the headings at level 1,2 and 3 are added to the Navigation bar.
If headings should not be automatically added to the navigation bar, use the
empty string `''` for this parameter. If omitted, the default configuration
defined by option "capture_page_headings" in `Build.json` is used.

.INPUTS
None. This function does not read from a pipe.

.OUTPUTS
HTML elements representing navigation links to headings on the input HTML
fragment for use in the navigation bar of sites created by
`New-StaticHTMLSiteProject`.

.EXAMPLE
New-PageHeadingNavigation $fragment -HeadingLevels '234'

Create an HTML element for navigation to page headings `<h2>`, `<h3>`, `<h4>`.
All other headings are ignored. `$fragment` is a HTML framgment defined as:

~~~ PowerShell
$fragment = '<h2 id="bob">Hello World</h2>'
~~~

Output:

~~~ HTML
<button class="navitem">
   <a href="#bob"><span class="navitem2">Hello World</span></a>
</button>
~~~

Note that the heading level has been added to the css class.

.EXAMPLE
New-PageHeadingNavigation '<h2 id="bob">Hello World</h2>' -NavTemplate $custom

Create an HTML element for navigation to an heading using the custom template `$custom`.

~~~ PowerShell
    $custom = @{ navheading = '<span class="li-item{{level}}">{{navtext}}</span>'}
~~~

Output:

~~~ HTML
<button class="navitem">
    <a href="#bob"><span class="li-item2">Hello World</span></a>
</button>
~~~

Note that the heading level is used as a postfix for the css class.

.NOTES
This function is typically used in the build script `Build.ps1` to define
the contents of the navigation bar (placeholder `{{nav}}`).

.LINK
https://wethat.github.io/MarkdownToHtml/2.6/New-PageHeadingNavigation.html
.LINK
`Convert-MarkdownToHTMLFragment`
.LINK
`ConvertTo-NavigationItem`
.LINK
`New-SiteNavigation`
.LINK
`New-StaticHTMLSiteProject`
#>
function New-PageHeadingNavigation {
    [OutputType([string])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [ValidateNotNull()]
        [object]$HTMLfragment,

        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [object[]]$NavitemSpecs,

        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [object]$NavTemplate,

        [parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [string]$HeadingLevels
    )
    # determine the values of missing parameters
    if ($cfg = $HTMLFragment.EffectiveConfiguration) {
        if (!$NavTemplate -and ($navbar = $cfg.navigation_bar )) {
            $NavTemplate = $navbar.templates
        }
        if (!$HeadingLevels -and $navbar -and $navbar.capture_page_headings) {
            $HeadingLevels = $navbar.capture_page_headings
        }
    }
    # provide defaults if needed
    if (!$NavTemplate) {
            $NavTemplate = $SCRIPT:defaultNavTemplate
    }
    if (!$HeadingLevels) {
            $HeadingLevels = "123" # capture levels 1 .. 3 by default
    }

    # Emit the page header navbar items

    if ($NavitemSpecs -and $HTMLfragment.RelativePath) {
        New-SiteNavigation -NavitemSpecs $NavitemSpecs `
		            -RelativePath $HTMLfragment.RelativePath `
		            -NavTemplate  $NavTemplate
    }
    if ($HTMLfragment -isnot [string]) {
        # fall back to string for backwards compatibility
        $HTMLfragment = $HTMLfragment.HTMLfragment
    }

    $HTMLfragment -split "`n" | ForEach-Object {
        $m = $hRE.Match($_)
        if ($m.Success -and $m.Groups.Count -eq 4) {
            # found an heading with an id attribute
            $level = $m.Groups[1].Captures.Value
            if ($headingLevels.Contains($level)) {
                # this level is enabled
                $id = $m.Groups[2].Captures -join ''
                $txt = $m.Groups[3].Captures -join ''
                # strip hyperlinks in heading text
                $txt = $aRE.Replace($txt,'')
                [string]$navheading = $NavTemplate.navheading
                if (!$navheading) {
                    $navheading = $SCRIPT:defaultNavTemplate.navheading
                }
                @{ $navheading.Replace('{{level}}',$level).Replace('{{navtext}}',$txt) = "#$($id)"}
            }
        }
    } | ConvertTo-NavigationItem -NavTemplate $NavTemplate
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
https://wethat.github.io/MarkdownToHtml/2.6/Update-ResourceLinks.html
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

# SIG # Begin signature block
# MIIFYAYJKoZIhvcNAQcCoIIFUTCCBU0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUCcL2EBg4UEf1z9dCkifgyBJV
# V/egggMAMIIC/DCCAeSgAwIBAgIQaejvMGXYIKhALoN4OCBcKjANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRJd99J2e2/UR2wy3vQwoXya120
# TTANBgkqhkiG9w0BAQEFAASCAQCF9vF1/nRK/9agaH9VaVpzA8otBCIs0UU0rsiU
# KoPLu5bkjxjB9kWRGJCp9nnyuK1DVjYS4/8upkomNIqXqwOxjTwrC0TrsYkXQRgW
# 63JMA13HhYxaDyisMKAFYydhQ8gZICWTHbN8kEpwnI9ykcm2fFe19jszyY3k+OGq
# ThzbtYHmg/Oqlp7ODLxa6jrJcMUMnMoe4rmkePJ29Xe+xhyEweUhYvCV4a9VzAOc
# M7w2H3qIDy/Z03dxG+Wyby32252GJ2Cw76wP4rwRb2kaBtaHKpQPzDPrjoJFEqTE
# ClKm1SCx3nTM1T+muaWcYDisIo777Phr2FqzQY265RTQmAWE
# SIG # End signature block

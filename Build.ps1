<#
.SYNOPSIS
Build a static HTML site from Markdown files.
#>

[string]$SCRIPT:projectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module -Name '../MarkDownToHTML' -Force

# Generate Markdown Docs for the current module version
import-module -Name '../MarkdownCodeDocs' -Force

$version = (Get-Module MarkDownToHTML).Version
Write-Information -MessageData "Version: $version" -InformationAction Continue
# Only major and minor revisions generate new docs
$version = "$($version.Major).$($version.Minor)"

# JSON configuration
$SCRIPT:config = Get-Content (Join-Path $projectDir 'Build.json') | ConvertFrom-Json
if (!$config) {
    throw 'No build configuration found!'
}

$markdown = Join-Path $SCRIPT:projectDir $config.markdown_dir
$markdown_version = Join-Path $markdown $version

# Clear previously generated Markdown
Remove-Item $markdown_version -Recurse -Force -ErrorAction:SilentlyContinue -Exclude 'Build.json'
# Generate new docs
Publish-PSModuleMarkdown -moduleName 'MarkdownToHTML' -Destination $markdown_version

# make / update  version specific config files
[System.io.Fileinfo]$configTemplate = Join-Path $projectDir 'Build_template.json'

Get-ChildItem "$markdown/[0-9]*" -Directory `
| ForEach-Object {
    [System.io.FileInfo]$cfg = Join-Path $_.FullName 'Build.json'
    $ver = $_.Name
    if (!$cfg.Exists -or ($cfg.LastWriteTime -lt $configTemplate.LastWriteTime)) {
        Write-Information "Creating version specific configuration $($cfg.FullName)"
        Get-Content $configTemplate `
        | ForEach-Object {
            $_.Replace("{{version}}", $ver)
        } > $cfg.FullName
    } 
       
}

# Location of the static HTML site to build
$SCRIPT:staticSite = Join-Path $projectDir $config.site_dir

# Clean up the static HTML site before build
Remove-Item $staticSite -Recurse -Force -ErrorAction:SilentlyContinue

# Set-up the content mapping rules for replacing template placeholders
# of the form {{name}}.
$SCRIPT:contentMap = @{
	# Add additional mappings here...
	'{{footer}}' = {
		param($fragment)
		$fragment.EffectiveConfiguration.Footer # Fetch footer text from configuration
	}
	'{{nav}}'    = {
		param($fragment) # the html fragment created from a markdown file
		$cfg = $fragment.EffectiveConfiguration
		$navcfg = $cfg.navigation_bar # navigation bar configuration
		# Create the navigation items configured in 'Build.json'
		New-SiteNavigation -NavitemSpecs $cfg.site_navigation `
		                   -RelativePath $fragment.RelativePath `
		                   -NavTemplate $navcfg.templates
		# Create navigation items to headings on the local page.
		# This requires the `autoidentifiers` extension to be enabled!
		New-PageHeadingNavigation -NavitemSpecs $cfg.page_navigation_header `
		                          -HTMLfragment $fragment `
		                          -NavTemplate $navcfg.templates `
		                          -HeadingLevels $navcfg.capture_page_headings
	}
}

# Conversion pipeline
$SCRIPT:markdown = Join-Path $projectDir $config.markdown_dir
Find-MarkdownFiles $markdown -Exclude $config.Exclude -BuildConfiguration $config `
| Convert-MarkdownToHTMLFragment -IncludeExtension $config.markdown_extensions -Split `
| Convert-SvgbobToSvg -SiteDirectory $staticSite `
| Publish-StaticHTMLSite -Template (Join-Path $projectDir $config.HTML_Template) `
                         -ContentMap  $contentMap `
						 -MediaDirectory $markdown `
	                     -SiteDirectory $staticSite

if ($config.github_pages) {
	# Switch off Jekyll publishing when building for GitHub pages
	New-Item -Path $staticSite -Name .nojekyll -ItemType File
}
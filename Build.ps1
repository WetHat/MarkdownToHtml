<#
.SYNOSIS
Build a static HTML site from Markdown files.
#>
[string]$SCRIPT:projectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module -Name '../MarkDownToHTML' -Force

# Generate Markdown Docs for the current module version
import-module -Name '../MarkdownCodeDocs' -Force

$version = (Get-Module MarkDownToHTML).Version.ToString()
Write-Output "Version: $version"

$markdown = "markdown/$version" 
# Clear previously generated Markdown
Remove-Item $markdown -Recurse -Force -ErrorAction:SilentlyContinue
Publish-PSModuleMarkdown -moduleName 'MarkdownToHTML' -Destination $markdown

# JSON configuration
$SCRIPT:config = Get-Content (Join-Path $projectDir 'Build.json') | ConvertFrom-Json
if (!$config) {
    throw 'No build configuration found!'
}

# Update version dependent navigation links
$SCRIPT:config.site_navigation  = $SCRIPT:config.site_navigation | ForEach-Object {
    $props = Get-Member -InputObject $_ -MemberType NoteProperty
    $name = $props.Name
    @{ $name = $_.$name -Replace '{{version}}',$version}
}

# Location of the static HTML site to build
$SCRIPT:staticSite = Join-Path $projectDir $config.site_dir

# Clean up the static HTML site before build
Remove-Item $staticSite -Recurse -Force -ErrorAction:SilentlyContinue

# Set-up the content mapping rules for replacing the templace placeholders
$SCRIPT:contentMap = @{
	# Add additional mappings here...
	'{{footer}}' =  $config.Footer # Footer text from configuration
	'{{nav}}'    = {
		param($fragment) # the html fragment created from a markdown file
		$navcfg = $config.navigation_bar # navigation bar configuration
		# Create the navigation items configured in 'Build.json'
		$config.site_navigation | ConvertTo-NavigationItem -RelativePath $fragment.RelativePath `
		                                                   -NavTemplate $navcfg.templates
		# Create navigation items to headings on the local page.
		# This requires the `autoidentifiers` extension to be enabled.
		ConvertTo-PageHeadingNavigation $fragment.HTMLFragment -NavTemplate $navcfg.templates `
		                                                       -HeadingLevels $navcfg.capture_page_headings
	}
}

$SCRIPT:markdown = Join-Path $projectDir $config.markdown_dir
Find-MarkdownFiles $markdown -Exclude $config.Exclude `
| Convert-MarkdownToHTMLFragment -IncludeExtension $config.markdown_extensions `
| Publish-StaticHTMLSite -Template (Join-Path $projectDir $config.HTML_Template) `
                         -ContentMap  $contentMap `
						 -MediaDirectory $markdown `
	                     -SiteDirectory $staticSite


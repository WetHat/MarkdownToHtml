<#
.SYNOSIS
Build a static HTML site from Markdown files.
#>
[string]$SCRIPT:projectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module -Name MarkDownToHTML

# JSON configuration
$SCRIPT:config = Get-Content (Join-Path $projectDir 'Build.json') | ConvertFrom-Json
if (!$config) {
    throw 'No build configuration found!'
}

# Location of the static HTML site to build
$SCRIPT:staticSite = Join-Path $projectDir $config.site_dir

# Clean up the static HTML sote before build
Remove-Item $staticSite -Recurse -Force -ErrorAction:SilentlyContinue

# Set-up the content mapping rules
$SCRIPT:contentMap = @{
	# Add additional mappings here...
	'{{footer}}' =  $config.Footer # Footer text from configuration
	'{{nav}}'    = {
		param($fragment)
		$config.site_navigation | ConvertTo-NavigationItem -RelativePath $fragment.RelativePath
	}
}

$SCRIPT:markdown = Join-Path $projectDir $config.markdown_dir
Find-MarkdownFiles $markdown -Exclude $config.Exclude `
| Convert-MarkdownToHTMLFragment -IncludeExtension $config.markdown_extensions `
| Publish-StaticHTMLSite -Template (Join-Path $projectDir $config.HTML_Template) `
                         -ContentMap  $contentMap `
						 -MediaDirectory $markdown `
	                     -SiteDirectory $staticSite


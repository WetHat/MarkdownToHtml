<#
.SYNOSIS
Build a static HTML site from Markdown files.
#>
[string]$SCRIPT:moduleDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module -Name MarkDownToHTML

# JSON configuration
$SCRIPT:config = Get-Content (Join-Path $moduleDir 'Build.json') | ConvertFrom-Json

# Location of the static HTML site to build
$SCRIPT:staticSite = Join-Path $moduleDir $config.site_dir

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

Find-MarkdownFiles (Join-Path $moduleDir $config.markdown_dir) -Exclude $config.Exclude `
| Convert-MarkdownToHTMLFragment -IncludeExtension $config.markdown_extensions `
| Publish-StaticHTMLSite -Template (Join-Path $moduleDir $config.HTML_Template) `
                         -ContentMap  $contentMap `
	                     -SiteDirectory $staticSite


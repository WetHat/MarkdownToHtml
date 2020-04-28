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

# Set-up the global mapping rules
$SCRIPT:contentMap = @{
	'{{footer}}' =  $config.Footer
	'{{nav}}'    = {
		param($fragment)

		# Determine the relative navigation path of this page to root
		$up = '../' * ($fragment.RelativePath.Split('/').Length - 1)

		# create page specific navigation links
		foreach ($item in $config.site_navigation) {
			$name = (Get-Member -InputObject $item -MemberType NoteProperty).Name
			$link = $item.$name # navlink relative to root
			if (!$link.StartsWith('http')) {
				# rewrite the link so that it works from the location of the current page
				$link = $up +  [System.IO.Path]::ChangeExtension($link,'html')
			}
			Write-Output "<button><a href=`"$link`">$name</a></button><br/>"
		}
	}
}

Find-MarkdownFiles (Join-Path $moduleDir $config.markdown_dir) -Exclude $config.Exclude `
| Convert-MarkdownToHTMLFragment -IncludeExtension $config.markdown_extensions `
| Add-ContentSubstitutionMap -ContentMap $contentMap `
| Publish-StaticHTMLSite -Template (Join-Path $moduleDir $config.HTML_Template) `
	                     -SiteDirectory $staticSite


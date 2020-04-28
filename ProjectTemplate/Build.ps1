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
	'{{nav}}'    = { # compute the navigation links
		param($fragment)

		# Determine the relative navigation path of this page to root
		$up = '../' * ($fragment.RelativePath.Split('/').Length - 1)

		# create page specific navigation links
		foreach ($item in $config.site_navigation) {
			$name = (Get-Member -InputObject $item -MemberType NoteProperty).Name
			$link = $item.$name # navlink relative to root
			if ([string]::IsNullOrWhiteSpace($link)) {
				if ($name.StartsWith('---')) {
					Write-Output '<hr class="navitem" />'
				} else {
					Write-Output "<div class='navitem'>$name</div>"
				}
			} else {
				if (!$link.StartsWith('http')){
					# rewrite the link so that it works from the current location
					$link = $up +  [System.IO.Path]::ChangeExtension($link,'html')
				}
				Write-Output "<button class='navitem'><a href=`"$link`">$name</a></button><br/>"
			}
		}
	}
}

Find-MarkdownFiles (Join-Path $moduleDir $config.markdown_dir) -Exclude $config.Exclude `
| Convert-MarkdownToHTMLFragment -IncludeExtension $config.markdown_extensions `
| Publish-StaticHTMLSite -Template (Join-Path $moduleDir $config.HTML_Template) `
                         -ContentMap  $contentMap `
	                     -SiteDirectory $staticSite


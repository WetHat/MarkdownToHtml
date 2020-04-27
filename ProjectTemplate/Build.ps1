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
}

Find-MarkdownFiles (Join-Path $moduleDir $config.markdown_dir) -Exclude $config.Exclude `
| Convert-MarkdownToHTMLFragment -IncludeExtension $config.markdown_extensions `
| Add-ContentSubstitutionMap -ContentMap $contentMap `
| ForEach-Object {
	$map = $_.ContentMap
	# Determine directory level below the site root
	$level = $_.RelativePath.Split('/').Length - 1

	# Create relative navigation links
	$nav = ''
	foreach ($item in $config.site_navigation) {
		$name = (Get-Member -InputObject $item -MemberType NoteProperty).Name
        $link = ('../' * $level) +  [System.IO.Path]::ChangeExtension($item.$name,'html')
		$nav += "<button><a href=`"$link`">$name</a></button><br/>"
	}
	# set up a page specific mapping rule
	$map['{{nav}}'] = $nav
	$_
  } `
| Publish-StaticHTMLSite -Template (Join-Path $moduleDir $config.HTML_Template) `
	                     -SiteDirectory $staticSite


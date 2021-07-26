#
# This is a PowerShell Unit Test file.
# You need a unit test framework such as Pester to run PowerShell Unit tests.
# You can download Pester from http://go.microsoft.com/fwlink/?LinkID=534084
#

Describe 'Convert-MarkdownToHTML' {
	It 'Converts markdown file ''<Markdown>'' to ''<ResultPath>''' -ForEach @(
		   @{Markdown='markdown/mermaid.md'; ReferencePath='html/mermaid.html'; ResultPath='TestDrive:/mermaid.html'; Extensions = 'diagrams'}
		   @{Markdown='markdown/KaTex.md';   ReferencePath='html/KaTex.html';   ResultPath='TestDrive:/KaTex.html' ;  Extensions = 'mathematics'}
		   @{Markdown='markdown/KaMaid.md';  ReferencePath='html/KaMaid.html';  ResultPath='TestDrive:/KaMaid.html';  Extensions = 'diagrams','mathematics'}
		   @{Markdown='markdown/Code.md';    ReferencePath='html/Code.html';    ResultPath='TestDrive:/Code.html';    Extensions = 'advanced'}
	   ) {
		   $testPath = Join-Path $testdata -ChildPath $Markdown
           $refPath  = Join-Path $refdata  -ChildPath $ReferencePath

		   $destination =  'TestDrive:/'
		   #$destination = 'e:/temp/ttt/'
		   #$ResultPath = $ResultPath -replace 'TestDrive:/',$destination

		   Convert-MarkdownToHTML -Path $testPath `
		                          -Template $template `
		                          -Destination $destination `
		                          -IncludeExtension $Extensions `
		                          -Verbose

		   $refPath    | Should -Exist
		   $ResultPath | Should -Exist

		   $refFileContents = Get-Content -LiteralPath $refPath -Encoding UTF8 | Out-String
		   Get-Content -LiteralPath $ResultPath -Encoding UTF8 | Out-String | Should -BeExactly $refFileContents
	   }
	BeforeAll {
		[System.IO.DirectoryInfo]$moduleDir = (Get-Location).Path
		[System.IO.DirectoryInfo]$testdata = Join-Path $moduleDir -ChildPath 'TestData'
		[System.IO.DirectoryInfo]$refdata  = Join-Path $moduleDir -ChildPath 'ReferenceData'
		[System.IO.DirectoryInfo]$template = $null
		$template = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
		New-HTMLTemplate -Destination  $template
	}
    AfterAll {
        Remove-Item $template -Recurse
    }
}

Describe 'Convert-MarkdownToHTMLFragment' {
	It 'Converts markdown file ''<MDPath>'' to HTMLFragments' -ForEach @(
		   @{MDPath='markdown/mermaid.md'; ReferencePath='mermaid.html'; Extensions = 'diagrams' ; Title = 'Mermaid Diagramming Tool'}
		   @{MDPath='markdown/KaTex.md';   ReferencePath='KaTex.html';   Extensions = 'mathematics'; Title = 'KaTEx Typesetting'}
		   @{MDPath='markdown/KaMaid.md';  ReferencePath='KaMaid.html';  Extensions = 'diagrams','mathematics'; Title = 'KaTEx Typesetting'}
		   @{MDPath='markdown/Code.md';    ReferencePath='Code.html';    Extensions = 'advanced'; Title = 'Testing Code Symtax Highlighting '}
		) {
			[System.IO.FileInfo]$testPath = Join-Path $testdata -ChildPath $MDPath
			$refPath  = Join-Path $refdata  -ChildPath $ReferencePath

            $ResultPath = Join-Path 'TestDrive:/' $ReferencePath
            #$ResultPath = Join-Path 'e:\temp\ttt' $ReferencePath

			$fragment = Get-Item -LiteralPath $testPath `
			| Convert-MarkdownToHTMLFragment -IncludeExtension $Extensions

			$fragment.RelativePath | Should -BeExactly $testPath.Name # Should be Markdown Filename
			$fragment.Title | Should -BeExactly $Title

			Out-File -InputObject $fragment.HtmlFragment -LiteralPath $ResultPath -Encoding utf8

			$refPath    | Should -Exist
			$ResultPath | Should -Exist
			$refFileContents = Get-Content -LiteralPath $refPath -Encoding UTF8 | Out-String
			Get-Content -LiteralPath $ResultPath -Encoding UTF8 | Out-String | Should -BeExactly $refFileContents
		}
	BeforeAll {
		[System.IO.DirectoryInfo]$moduleDir = (Get-Location).Path
		[System.IO.DirectoryInfo]$testdata = Join-Path $moduleDir -ChildPath 'TestData'
		[System.IO.DirectoryInfo]$refdata  = Join-Path $moduleDir -ChildPath 'ReferenceData'
	}
}

Describe 'ConversionProjects' {
	It 'Converts markdown file(s) from ''<MDPath>'' to ''<ResultPath>'' with a custom converter pipeline' -ForEach @(
		   @{MDPath='markdown'; Config='ProjectConfigs/Build1.json';ReferencePath='html_p1';  ResultPath='TestDrive:/P1'}
		   @{MDPath='markdown'; Config='ProjectConfigs/Build2.json';ReferencePath='html_p2';  ResultPath='TestDrive:/P2'}
		   @{MDPath='markdown'; Config='ProjectConfigs/Build3.json';ReferencePath='html_p3';  ResultPath='TestDrive:/P3'}

		) `
		{
			[string]$markdown = Join-Path $testdata -ChildPath $MDPath
			$configPath = (Join-Path $testdata -ChildPath $Config)
            $config  = Get-Content $configPath -Encoding UTF8 | ConvertFrom-Json

			# Debug
		    #$ResultPath = $ResultPath -replace 'TestDrive:/',"e:/temp/"

            # Create a new Project
            New-StaticHTMLSiteProject -ProjectDirectory $ResultPath

            # copy the build config
            Copy-Item -Path $configPath -Destination (Join-Path $ResultPath 'Build.json')

            # cleanup the readme
            $readme = (Join-Path $ResultPath 'markdown/README.md')
            Remove-Item -LiteralPath $readme

            $readme |  Should -Not -Exist
            $ResultPath | Should -Exist

            # populate the project with markdown content
            Copy-Item "$markdown/*" -Destination (Join-Path $ResultPath $config.markdown_dir) -Recurse

            # Build the project
            &(Join-Path $ResultPath 'Build.ps1')

            # Verify the results
            $excluded = $config.Exclude | ForEach-Object {
                [System.IO.Path]::ChangeExtension($_,'html')
            }
            $html = Join-Path $ResultPath $config.site_dir
            if ($config.Exclude.Count -gt 0) {
                # Check that excluded files do not exist
                $found = (Get-ChildItem $html -Recurse -Include $excluded | Measure-Object).Count
                $found | Should -BeExactly 0
            }

            # check that all files exists and are equal
            $ref = Join-Path $refdata $ReferencePath

            Get-ChildItem $ref -Include '*.html' -Exclude $excluded -Recurse | ForEach-Object {
                $relpath = $_.Fullname.Substring($ref.Length)
                $target = Join-Path $html $relpath
                $target | Should -Exist

                # compare contents
                $refFileContents = Get-Content -LiteralPath $_ -Encoding UTF8 | Out-String
				Write-Verbose "Comparing with $_"
			    Get-Content -LiteralPath $target -Encoding UTF8 | Out-String | Should -BeExactly $refFileContents
            }
		}
		BeforeAll {
			[System.IO.DirectoryInfo]$moduleDir = (Get-Location).Path
			[System.IO.DirectoryInfo]$testdata = Join-Path $moduleDir -ChildPath 'TestData'
			[System.IO.DirectoryInfo]$refdata  = Join-Path $moduleDir -ChildPath 'ReferenceData'
		}
}

Describe 'ConvertTo-NavigationItem' {
	It 'Converts links relative to root ''<Link>'' to navitems relative to page' -ForEach @(
           @{Link='test.doc'; RelativePath='intro/page.md'; Result = '<button class="navitem"><a href="../test.doc">Test</a></button>'}
           @{Link='#test'; RelativePath='intro/page.md'; Result = '<button class="navitem"><a href="#test">Test</a></button>'}
		   @{Link='test.md'; RelativePath='intro/page.md'; Result = '<button class="navitem"><a href="../test.html">Test</a></button>'}
           @{Link='test.md#test'; RelativePath='intro/page.md'; Result = '<button class="navitem"><a href="../test.html#test">Test</a></button>'}
           @{Link='http://www.hp.com/test.md'; RelativePath='intro/page.md'; Result = '<button class="navitem"><a href="http://www.hp.com/test.md">Test</a></button>'}
		) `
		{
			@{'Test' = $Link} | ConvertTo-NavigationItem -RelativePath $RelativePath `
			                                             -NavTemplate @{navitem='<button class="navitem"><a href="{{navurl}}">{{navtext}}</a></button>'}`
			| Should -BeExactly $result
		}
}

Describe 'ConvertTo-PageHeadingNavigation' {
	It 'Converts heading ''<html>'' to page local navitem' -ForEach @(
          @{html='<h1 id="bob">Test</h1>'; Result = '<button class="navitem"><a href="#bob"><span class="navitem1">Test</span></a></button>'}
		  @{html='<h1 id="bob"><b>Test</b></h1>'; Result = '<button class="navitem"><a href="#bob"><span class="navitem1"><b>Test</b></span></a></button>'}
		  @{html='<h1 id="bob"><b>Test</b>'; Result = '<button class="navitem"><a href="#bob"><span class="navitem1"><b>Test</b></span></a></button>'}
		  @{html='<h1 id="bob"><a href="x.md">Test</a></h1>'; Result = '<button class="navitem"><a href="#bob"><span class="navitem1">Test</span></a></button>'}
		) `
		{
			ConvertTo-PageHeadingNavigation $html -NavTemplate @{navitem='<button class="navitem"><a href="{{navurl}}">{{navtext}}</a></button>'}` | Should -BeExactly $result
		}
}
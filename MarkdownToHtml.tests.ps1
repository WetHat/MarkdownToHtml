#
# This is a PowerShell Unit Test file.
# You need a unit test framework such as Pester to run PowerShell Unit tests.
# You can download Pester from http://go.microsoft.com/fwlink/?LinkID=534084
#

[System.IO.DirectoryInfo]$SCRIPT:moduleDir = Split-Path -Parent $MyInvocation.MyCommand.Path
[System.IO.DirectoryInfo]$SCRIPT:testdata = Join-Path $SCRIPT:moduleDir -ChildPath 'TestData'
[System.IO.DirectoryInfo]$SCRIPT:refdata  = Join-Path $SCRIPT:moduleDir -ChildPath 'ReferenceData'
[System.IO.FileInfo]$SCRIPT:template      = Join-Path $SCRIPT:moduleDir  -ChildPath 'Template'

Describe 'Convert-MarkdownToHTML' {
	It 'Converts markdown file(s) from ''<Path>'' to HTML' `
	   -TestCases @(
		   @{Path='markdown/mermaid.md'; ReferencePath='html/mermaid.html';       ResultPath='TestDrive:/mermaid.html' ;             Extensions = 'diagrams'}
		   @{Path='markdown/KaTex.md';   ReferencePath='html/KaTex.html';         ResultPath='TestDrive:/KaTex.html' ;               Extensions = 'mathematics'}
		   @{Path='markdown/KaMaid.md';  ReferencePath='html/KaMaid.html';        ResultPath='TestDrive:/KaMaid.html' ;              Extensions = 'diagrams','mathematics'}
		   @{Path='markdown/Code.md';    ReferencePath='html/Code.html';          ResultPath='TestDrive:/Code.html' ;                Extensions = 'advanced'}
	   ) `
	   {
		   param($Path,$ReferencePath,$ResultPath,$Extensions)

		   $testPath = Join-Path $SCRIPT:testdata -ChildPath $Path
           $refPath  = Join-Path $SCRIPT:refdata  -ChildPath $ReferencePath

		   $destination =  'TestDrive:/'
		   #$destination = 'e:/temp/ttt/'
		   #$ResultPath = $ResultPath -replace 'TestDrive:/',$destination

		   Convert-MarkdownToHTML -Path $testPath `
		                          -Template $SCRIPT:template `
		                          -Destination $destination `
		                          -IncludeExtension $Extensions `
		                          -Verbose

		   $refPath    | Should -Exist
		   $ResultPath | Should -Exist

		   $refFileContents = Get-Content -LiteralPath $refPath -Encoding UTF8 | Out-String
		   Get-Content -LiteralPath $ResultPath -Encoding UTF8 | Out-String | Should -BeExactly $refFileContents
	   }
}

Describe 'Convert-MarkdownToHTMLFragment' {
	It 'Converts markdown file(s) from ''<Path>'' to HTMLFragments' `
		-TestCases @(
		   @{Path='markdown/mermaid.md'; ReferencePath='mermaid.html'; Extensions = 'diagrams' ; Title = 'Mermaid Diagramming Tool'}
		   @{Path='markdown/KaTex.md';   ReferencePath='KaTex.html';   Extensions = 'mathematics'; Title = 'KaTEx Typesetting'}
		   @{Path='markdown/KaMaid.md';  ReferencePath='KaMaid.html';  Extensions = 'diagrams','mathematics'; Title = 'KaTEx Typesetting'}
		   @{Path='markdown/Code.md';    ReferencePath='Code.html';    Extensions = 'advanced'; Title = 'Testing Code Symtax Highlighting '}
		) `
		{
			param($Path,$ReferencePath,$Extensions, $Title)

			[System.IO.FileInfo]$testPath = Join-Path $SCRIPT:testdata -ChildPath $Path
			$refPath  = Join-Path $SCRIPT:refdata  -ChildPath $ReferencePath

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
}

Describe 'CustomConverterPipeline' {
	It 'Converts markdown file(s) from ''<Path>'' to HTML with a custom converter pipeline' `
		-TestCases @(
		   @{Path='markdown'; ReferencePath='html_cust';  ResultPath='TestDrive:/html1' ; Extensions = 'diagrams','mathematics' ; Exclude=$null}
		   @{Path='markdown'; ReferencePath='html_cust';  ResultPath='TestDrive:/html2' ; Extensions = 'diagrams','mathematics' ; Exclude='Code.md'}
		) `
		{
			param($Path,$ReferencePath,$ResultPath, $Extensions, $Exclude, $Title)

			[System.IO.FileInfo]$testPath = Join-Path $SCRIPT:testdata -ChildPath $Path
			$refPath  = Join-Path $SCRIPT:refdata  -ChildPath $ReferencePath

		    $ResultPath = $ResultPath -replace 'TestDrive:/','e:/temp/ttt/'

			# inject navigation code to all pages
			$contentMap = @{'[navigation]' = @"
					<button><a href="http://www.hp.com">Hewlett-Packard</a></button>
					<button><a href="http://www.ptc.com">Parametric Technologies</a></button>
"@
			}

			Find-MarkdownFiles $testPath -Exclude $Exclude `
			| Convert-MarkdownToHTMLFragment -IncludeExtension $Extensions -Verbose `
		    | Add-ContentSubstitutionMap -ContentMap $contentMap `
			| Publish-StaticHTMLSite -Template (Join-Path $SCRIPT:testdata 'CustomTemplate') `
	                                 -SiteDirectory $ResultPath `
		                             -Verbose

			$refPath    | Should -Exist
		    $ResultPath | Should -Exist

			# Check that all files exist and are identical
			Get-ChildItem $testPath -Recurse -File -Exclude $Exclude `
			| ForEach-Object {
				# make path to file relative so that we find it in various places
                $relpath = [System.IO.Path]::ChangeExtension($_.FullName.Substring($testPath.FullName.Length),'html')

				$refFile = Join-Path $refPath $relpath
				$resultFile = Join-Path $ResultPath $relpath

                $refFile | Should -Exist
                $resultFile | should -Exist

				$refFileContents = Get-Content -LiteralPath $refFile -Encoding UTF8 | Out-String
			    Get-Content -LiteralPath $resultFile -Encoding UTF8 | Out-String | Should -BeExactly $refFileContents
			}

			# Check that excluded files are not present
			if ($Exclude){
				Get-ChildItem $testPath -Recurse -File -Include $Exclude `
				| ForEach-Object {
					$relpath = [System.IO.Path]::ChangeExtension($_.FullName.Substring($testPath.FullName.Length),'html')
					Join-Path $ResultPath $relpath | Should -Not -Exist
				}
			}
		}
}


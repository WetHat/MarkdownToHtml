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
		   @{Path='markdown/Dir';        ReferencePath='html/SubDir/SubDirSingle.html';  ResultPath='TestDrive:/Subdir/SubdirSingle.html' ; Extensions = 'advanced'}
		   @{Path='markdown/Dir2';       ReferencePath='html/SubDir2/SubDir2/SubDirSingle.html';  ResultPath='TestDrive:/Subdir2/SubDir2/SubdirSingle.html' ; Extensions = 'advanced'}
	   ) `
	   {
		   param($Path,$ReferencePath,$ResultPath,$Extensions)

		   $testPath = Join-Path $SCRIPT:testdata -ChildPath $Path
           $refPath  = Join-Path $SCRIPT:refdata  -ChildPath $ReferencePath

		   $destination =  'TestDrive:/'
		   #$destination = 'e:/temp/ttt'
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
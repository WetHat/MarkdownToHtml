#
# This is a PowerShell Unit Test file.
# You need a unit test framework such as Pester to run PowerShell Unit tests.
# You can download Pester from http://go.microsoft.com/fwlink/?LinkID=534084
#

[System.IO.DirectoryInfo]$SCRIPT:moduleDir = Split-Path -Parent $MyInvocation.MyCommand.Path
[System.IO.DirectoryInfo]$SCRIPT:testdata = Join-Path $SCRIPT:moduleDir -ChildPath 'TestData'
[System.IO.DirectoryInfo]$SCRIPT:refdata  = Join-Path $SCRIPT:moduleDir -ChildPath 'ReferenceData'
[System.IO.FileInfo]$SCRIPT:template      = Join-Path $SCRIPT:testdata  -ChildPath 'Template'

Describe 'Convert-MarkdownToHTML' {
	It 'Converts markdown file(s) from ''<Path>'' to HTML' `
	   -TestCases @(
		   @{Path='markdown/mermaid.md'; ReferencePath='mermaid.html';       ResultPath='TestDrive:/mermaid.html' ;             Extensions = 'diagrams'}
		   @{Path='markdown/KaTex.md';   ReferencePath='KaTex.html';         ResultPath='TestDrive:/KaTex.html' ;               Extensions = 'mathematics'}
		   @{Path='markdown/KaMaid.md';  ReferencePath='KaMaid.html';        ResultPath='TestDrive:/KaMaid.html' ;              Extensions = 'diagrams','mathematics'}
		   @{Path='markdown/Dir';        ReferencePath='SubDirSingle.html';  ResultPath='TestDrive:/Subdir/SubdirSingle.html' ; Extensions = 'advanced'}
	   ) `
	   {
		   param($Path,$ReferencePath,$ResultPath,$Extensions)

		   $testPath = Join-Path $SCRIPT:testdata -ChildPath $Path
           $refPath  = Join-Path $SCRIPT:refdata  -ChildPath $ReferencePath

		   Convert-MarkdownToHTML -Path $testPath -Template $SCRIPT:template -Destination 'TestDrive:/' -IncludeExtension $Extensions

		   $refPath    | Should -Exist
		   $ResultPath | Should -Exist

		   $refFileContents = Get-Content -LiteralPath $refPath -Encoding UTF8 | Out-String
		   Get-Content -LiteralPath $ResultPath -Encoding UTF8 | Out-String | Should -BeExactly $refFileContents
	   }
}
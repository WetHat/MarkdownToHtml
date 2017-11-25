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
		   @{Path='markdown/SubDir/Single.md';  ReferencePath='Flat/Single.html';    ResultPath='TestDrive:/Single.html'}
		   @{Path='markdown/SubDir';            ReferencePath='Flat/Single.html';    ResultPath='TestDrive:/Single.html'}
		   @{Path='markdown/SubDir/';           ReferencePath='Flat/Single.html';    ResultPath='TestDrive:/Single.html'}
		   @{Path='markdown';                   ReferencePath='SubDir/Single.html';  ResultPath='TestDrive:/SubDir/Single.html'}
	   ) `
	   {
		   param($Path,$ReferencePath,$ResultPath)

		   $testPath = Join-Path $SCRIPT:testdata -ChildPath $Path
           $refPath  = Join-Path $SCRIPT:refdata  -ChildPath $ReferencePath

		   Convert-MarkdownToHTML -Path $testPath -Template $SCRIPT:template -Destination 'TestDrive:/' -IncludeExtension 'advanced'

		   $refPath    | Should -Exist
		   $ResultPath | Should -Exist

		   $refFileContents = Get-Content -LiteralPath $refPath -Encoding UTF8 | Out-String
		   Get-Content -LiteralPath $ResultPath -Encoding UTF8 | Out-String | Should -BeExactly $refFileContents
	   }
}
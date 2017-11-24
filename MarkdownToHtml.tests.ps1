#
# This is a PowerShell Unit Test file.
# You need a unit test framework such as Pester to run PowerShell Unit tests.
# You can download Pester from http://go.microsoft.com/fwlink/?LinkID=534084
#

[System.IO.DirectoryInfo]$SCRIPT:moduleDir = Split-Path -Parent $MyInvocation.MyCommand.Path
[System.IO.DirectoryInfo]$SCRIPT:testdata = Join-Path $SCRIPT:moduleDir -ChildPath 'TestData'
[System.IO.DirectoryInfo]$SCRIPT:refdata  = Join-Path $SCRIPT:moduleDir -ChildPath 'ReferenceData'
[System.IO.DirectoryInfo]$SCRIPT:failures = Join-Path $SCRIPT:moduleDir -ChildPath 'Failures'
[System.IO.FileInfo]$SCRIPT:template      = Join-Path $SCRIPT:testdata  -ChildPath 'Template'

Describe 'Convert-MarkdownToHTML' {
	It 'Converts a single markdown file to HTML' {
		$testPath = Join-Path $SCRIPT:testdata -ChildPath 'markdown/SubDir/Single.md'
        $refPath  = Join-Path $SCRIPT:refdata  -ChildPath 'Flat/Single.html'

		Convert-MarkdownToHTML -Path $testPath -Template $SCRIPT:template -Destination 'TestDrive:/' -IncludeExtension 'advanced'

		$refPath                 | Should -Exist
		'TestDrive:/Single.html' | Should -Exist

		$refFileContents = Get-Content -LiteralPath $refPath -Encoding UTF8 | Out-String
		Get-Content -LiteralPath 'TestDrive:/Single.html' -Encoding UTF8 | Out-String | Should -BeExactly $refFileContents
	}

	It 'Converts a directory with a single markdown file to HTML' {
		$testPath = Join-Path $SCRIPT:testdata -ChildPath 'markdown/SubDir'
        $refPath  = Join-Path $SCRIPT:refdata  -ChildPath 'Flat/Single.html'

		Convert-MarkdownToHTML -Path $refPath -Template $SCRIPT:template -Destination 'TestDrive:/' -IncludeExtension 'advanced'

		$refPath                 | Should -Exist
		'TestDrive:/Single.html' | Should -Exist

		$refFileContents = Get-Content -LiteralPath $refPath -Encoding UTF8 | Out-String
		Get-Content -LiteralPath 'TestDrive:/Single.html' -Encoding UTF8 | Out-String | Should -BeExactly $refFileContents
	}

	It 'Converts a directory (trailing /) with a single markdown file to HTML' {
		$testPath = Join-Path $SCRIPT:testdata -ChildPath 'markdown/SubDir/'
        $refPath  = Join-Path $SCRIPT:refdata  -ChildPath 'Flat/Single.html'

		Convert-MarkdownToHTML -Path $testPath -Template $SCRIPT:template -Destination 'TestDrive:/' -IncludeExtension 'advanced'

		$refPath                 | Should -Exist
		'TestDrive:/Single.html' | Should -Exist

		$refFileContents = Get-Content -LiteralPath $refPath -Encoding UTF8 | Out-String
		Get-Content -LiteralPath 'TestDrive:/Single.html' -Encoding UTF8 | Out-String | Should -BeExactly $refFileContents
	}

	It 'Converts a directory structure with a single markdown file to HTML' {
		$testPath = Join-Path $SCRIPT:testdata -ChildPath 'markdown'
        $refPath  = Join-Path $SCRIPT:refdata  -ChildPath 'SubDir/Single.html'

		Convert-MarkdownToHTML -Path $testPath -Template $SCRIPT:template -Destination 'TestDrive:/' -IncludeExtension 'advanced'

		$refPath                        | Should -Exist
		'TestDrive:/SubDir/Single.html' | Should -Exist

		$refFileContents = Get-Content -LiteralPath $refPath -Encoding UTF8 | Out-String
		Get-Content -LiteralPath 'TestDrive:/SubDir/Single.html' -Encoding UTF8 | Out-String | Should -BeExactly $refFileContents
	}
}
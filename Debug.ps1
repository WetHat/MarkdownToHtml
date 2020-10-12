param($TestName)

[System.IO.DirectoryInfo]$SCRIPT:moduleDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$saved = $env:PSModulePath
$env:PSModulePath = "$($SCRIPT:moduleDir.Parent.Fullname);" + $env:PSModulePath

import-module MarkdownToHTML -force
Invoke-Pester -FullNameFilter $TestName -Verbose
$env:PSModulePath = $saved
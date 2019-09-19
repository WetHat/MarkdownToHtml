# Testing Code Symtax Highlighting {.title}

## Lisp
~~~ Lisp
(defun test (c &key message)
    (format t "~A - ~S~%" c message)
)
~~~

## PowerShell

~~~ PowerShell
function New-HTMLTemplate {
    [OutputType([System.IO.DirectoryInfo])]
    [CmdletBinding()]
    param(
            [parameter(Mandatory=$true,ValueFromPipeline=$false)]
            [ValidateNotNullorEmpty()]
            [string]$Destination
         )
    $template = Join-Path $SCRIPT:moduleDir.FullName 'Template'
    ## Copy the template to the output directory

    $outdir = Get-Item -LiteralPath $Destination -ErrorAction:SilentlyContinue

    if ($outdir -eq $null) {
        $outdir = New-Item -Path $Destination -ItemType Directory -ErrorAction:SilentlyContinue
    }

    if ($outdir -eq $null -or $outdir -isnot [System.IO.DirectoryInfo]) {
        throw("Unable to create directory $Destination")
    }
    Copy-Item -Path "${template}/*" -Recurse -Destination $outDir
    $outDir
}
~~~

## HTML

~~~ html
<body>
    <p style="background:green;">Hello world.</p>
</body>
~~~



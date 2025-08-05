<#
.SYNOPSIS
    Builds the PS2EXE.Core module.

.PARAMETER Load
    Imports the built PS2EXE.Core module in a separate PowerShell session
    and measure how fast it imports. If the module cannot be imported it throws
    an error.

.PARAMETER Clean
    Cleans the build folder ./bin.
#>

[CmdletBinding()]
param (
    [switch] $Load,
    [switch] $Clean,
    [switch] $Test
)

$ErrorActionPreference = 'Stop'
Get-Module PS2EXE.Core | Remove-Module

if ($Clean -and (Test-Path "$PSScriptRoot/bin")) {
    Remove-Item "$PSScriptRoot/bin" -Recurse -Force
}

function Copy-Content ($Content) {
    foreach ($c in $content) {
        $source, $destination = $c

        $null = New-Item -Force $destination -ItemType Directory
        Get-ChildItem $source -File | Copy-Item -Destination $destination
    }
}

$content = @(
    , ("$PSScriptRoot/resources/base.csproj", "$PSScriptRoot/bin/")
    , ("$PSScriptRoot/resources/main.cs", "$PSScriptRoot/bin/")
    , ("$PSScriptRoot/src/main/PS2EXE.Core.psm1", "$PSScriptRoot/bin/")
    , ("$PSScriptRoot/src/main/PS2EXE.Core.psd1", "$PSScriptRoot/bin/")
    , ("$PSScriptRoot/src/main/Variables.json", "$PSScriptRoot/bin/")
    , ("$PSScriptRoot/resources/Win-PS2EXE.exe", "$PSScriptRoot/bin/")
)

Copy-Content -Content $content

New-Item "$PSScriptRoot/bin" -ItemType Directory -Force | Out-Null

$script = @(
    "$PSScriptRoot/src/main/Private/*.ps1",
    "$PSScriptRoot/src/main/Public/*.ps1"
)

$files = Get-ChildItem $script -File | Select-Object -Unique
$sb = [System.Text.StringBuilder]::new()

foreach ($file in $files) {
    $lines = Get-Content $file
    $relativePath = ($file.FullName -replace ([regex]::Escape($PSScriptRoot))).TrimStart('\').TrimStart('/')
    $sb.AppendLine("# file $relativePath") | Out-Null
    foreach ($l in $lines) {
        $sb.AppendLine($l) | Out-Null
    }
}

$psm1Content = Get-Content "$PSScriptRoot/bin/PS2EXE.Core.psm1" -Raw
$sb.AppendLine($psm1Content) | Out-Null

$sb.ToString() | Set-Content "$PSScriptRoot/bin/PS2EXE.Core.psm1" -Encoding UTF8

$powershell = Get-Process -Id $PID | Select-Object -ExpandProperty Path

if ($Load) {
    & $powershell -Command "'Load: ' + (Measure-Command { Import-Module '$PSScriptRoot/bin/PS2EXE.Core.psd1' -ErrorAction Stop}).TotalMilliseconds + 'ms'"
    if (0 -ne $LASTEXITCODE) {
        throw "Failed to load PS2EXE.Core module!"
    }
}

if ($Test) {
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'src\test\TestHarness.psm1') -Force
    Invoke-TestHarness -IgnoreCodeCoverage
}

# Define aliases
Set-Alias -Name "Win-PS2EXE" -Value "$PSScriptRoot\Win-PS2EXE.exe" -Scope Global
Set-Alias -Name "Win-PS2EXE.exe" -Value "$PSScriptRoot\Win-PS2EXE.exe" -Scope Global

$ErrorActionPreference = 'Stop'

# Load Module variables file
try {
    $variables = Get-Content "$PSScriptRoot\Variables.json" -Raw | ConvertFrom-Json
    foreach ($variable in $variables) {
        New-Variable -Name $variable.Name -Value $variable.Value -Scope Script -Option Constant
    }
} catch {
    throw 'Could not load Variables.json file.'
}

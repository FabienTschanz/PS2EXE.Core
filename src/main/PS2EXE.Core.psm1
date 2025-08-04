# Define aliases
Set-Alias ps2exe Invoke-PS2EXE -Scope Global
Set-Alias ps2exe.ps1 Invoke-PS2EXE -Scope Global
Set-Alias Win-PS2EXE "$PSScriptRoot\Win-PS2EXE.exe" -Scope Global
Set-Alias Win-PS2EXE.exe "$PSScriptRoot\Win-PS2EXE.exe" -Scope Global

# Export aliases
Export-ModuleMember -Alias @('ps2exe', 'ps2exe.ps1', 'Win-PS2EXE', 'Win-PS2EXE.exe')

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

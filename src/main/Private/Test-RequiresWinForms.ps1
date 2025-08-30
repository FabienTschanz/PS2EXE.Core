<#
.SYNOPSIS
    Tests if the script requires the System.Windows.Forms assembly.

.DESCRIPTION
    This function checks if the System.Windows.Forms assembly is loaded and available for use in the script.

.PARAMETER FilePath
    The path to the PowerShell script file to be tested.

.EXAMPLE
    Test-RequiresWinForms -FilePath "C:\Scripts\Test.ps1"

    This command tests the specified PowerShell script file for the required System.Windows.Forms assembly.

.OUTPUTS
    System.Boolean. True if the assembly is required, False otherwise.
#>
function Test-RequiresWinForms {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $FilePath
    )

    if (-not (Test-Path -Path $FilePath)) {
        Write-Error "The file '$FilePath' does not exist."
        return $false
    }

    # Use the AST to check for issues
    $tokens = @()
    $errors = @()
    $null = [System.Management.Automation.Language.Parser]::ParseFile($FilePath, [ref]$tokens, [ref]$errors)

    if ($errors.Count -gt 0) {
        throw "Errors found in script '$FilePath':`n $($errors -join "`n")"
    }

    $requiresWinForms = $false
    if ($tokens.Value -contains "System.Windows.Forms") {
        if ($IsLinux -or $IsMacOS) {
            throw "The script requires System.Windows.Forms, which is not supported on Linux or macOS."
        }
        $requiresWinForms = $true

        if ($tokens.Value -contains "Write-Output" -or $tokens.Value -contains "Write-Host") {
            Write-Warning -Message "Script uses Write-Output and/or Write-Host, which will not work as expected in a WinForms application.
            WinForms applications do not have a console output."
        }
    }

    return $requiresWinForms
}

<#
.SYNOPSIS
    Tests the input file for syntax and semantic errors.

.DESCRIPTION
    This function analyzes the PowerShell script file for common issues and provides feedback.

.PARAMETER FilePath
    The path to the PowerShell script file to be tested.

.EXAMPLE
    Test-ScriptFile -FilePath "C:\Scripts\Test.ps1"

    This command tests the specified PowerShell script file for syntax and semantic errors.

.OUTPUTS
    System.Boolean. True if the script is valid, False otherwise.
#>
function Test-ScriptFile {
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
        Write-Error "Errors found in script '$FilePath':`n $($errors -join "`n")"
        return $false
    } else {
        Write-Verbose -Message "No issues found in script '$FilePath'."
    }

    return $true
}

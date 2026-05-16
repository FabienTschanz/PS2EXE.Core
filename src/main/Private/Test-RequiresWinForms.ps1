<#
.SYNOPSIS
    Tests if the script requires the System.Windows.Forms assembly.

.DESCRIPTION
    This function checks if the System.Windows.Forms assembly is loaded and available for use in the script.
    Uses AST analysis to detect type expressions and using statements rather than naive token matching,
    avoiding false positives from string literals or comments.

.PARAMETER FilePath
    The path to the PowerShell script file to be tested.

.EXAMPLE
    Test-RequiresWinForms -FilePath "C:\Scripts\Test.ps1"

    This command tests the specified PowerShell script file for the required System.Windows.Forms assembly.

.OUTPUTS
    System.Boolean. True if the assembly is required, False otherwise.
#>
function Test-RequiresWinForms {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification='This function targets Windows Forms, which is plural by design.')]
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

    # Use the AST to check for WinForms usage via type expressions and using statements
    $tokens = @()
    $errors = @()
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($FilePath, [ref]$tokens, [ref]$errors)

    if ($errors.Count -gt 0) {
        throw "Errors found in script '$FilePath':`n $($errors -join "`n")"
    }

    $requiresWinForms = $false

    # Check for type expressions like [System.Windows.Forms.Form] in AST nodes
    $typeExpressions = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.TypeExpressionAst] }, $true)
    $typeConstraints = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.TypeConstraintAst] }, $true)
    $memberExpressions = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.InvokeMemberExpressionAst] }, $true)

    $allTypeNames = @()
    $allTypeNames += $typeExpressions | ForEach-Object { $_.TypeName.FullName }
    $allTypeNames += $typeConstraints | ForEach-Object { $_.TypeName.FullName }
    $allTypeNames += $memberExpressions | Where-Object { $_.Expression -is [System.Management.Automation.Language.TypeExpressionAst] } | ForEach-Object { $_.Expression.TypeName.FullName }

    # Also check for Add-Type with Windows.Forms or using namespace statements
    $usingStatements = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.UsingStatementAst] }, $true)
    $addTypeCommands = $ast.FindAll({
        $args[0] -is [System.Management.Automation.Language.CommandAst] -and
        $args[0].GetCommandName() -eq 'Add-Type' -and
        $args[0].Extent.Text -match 'System\.Windows\.Forms'
    }, $true)

    if (($allTypeNames | Where-Object { $_ -like 'System.Windows.Forms*' -or $_ -like 'Windows.Forms*' }) -or
        ($usingStatements | Where-Object { $_.Name.Value -like '*Windows.Forms*' }) -or
        $addTypeCommands.Count -gt 0) {

        if ($IsLinux -or $IsMacOS) {
            throw "The script requires System.Windows.Forms, which is not supported on Linux or macOS."
        }
        $requiresWinForms = $true

        # Check for Write-Output/Write-Host that won't work in WinForms mode
        $writeCommands = $ast.FindAll({
            $args[0] -is [System.Management.Automation.Language.CommandAst] -and
            ($args[0].GetCommandName() -eq 'Write-Output' -or $args[0].GetCommandName() -eq 'Write-Host')
        }, $true)

        if ($writeCommands.Count -gt 0) {
            Write-Warning -Message "Script uses Write-Output and/or Write-Host, which will not work as expected in a WinForms application.
            WinForms applications do not have a console output."
        }
    }

    return $requiresWinForms
}

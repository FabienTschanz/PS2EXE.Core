# Tests for WinForms detection improvements
$moduleName = "PS2EXE.Core"

BeforeAll {
    $here       = $PSScriptRoot.Replace("test", "main")
    $rootPath   = Join-Path -Path $here -ChildPath '../../' -Resolve
    $moduleName = "PS2EXE.Core"

    Get-Module -Name $moduleName | Remove-Module -Force

    $modulePath = Join-Path -Path $rootPath -ChildPath "bin/$moduleName/$moduleName.psd1"
    if (-not (Test-Path -Path $modulePath)) {
        throw "Module path '$modulePath' does not exist. Ensure the module is built before running tests."
    }
    Import-Module -Name $modulePath
}

Describe "$moduleName WinForms Detection Tests" {

    Context "True positives - should detect WinForms usage" {
        It "detects type expression [System.Windows.Forms.Form]" {
            $script = Join-Path $TestDrive 'winforms-type.ps1'
            Set-Content -Path $script -Value @'
$form = [System.Windows.Forms.Form]::new()
$form.Text = "Hello"
$form.ShowDialog()
'@
            # Use InModuleScope to call private function
            InModuleScope $moduleName {
                param($path)
                Test-RequiresWinForms -FilePath $path
            } -Parameters @{ path = $script } | Should -BeTrue
        }

        It "detects Add-Type with WinForms assembly" {
            $script = Join-Path $TestDrive 'winforms-addtype.ps1'
            Set-Content -Path $script -Value @'
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.MessageBox]::Show("Hello")
'@
            InModuleScope $moduleName {
                param($path)
                Test-RequiresWinForms -FilePath $path
            } -Parameters @{ path = $script } | Should -BeTrue
        }
    }

    Context "True negatives - should NOT detect WinForms" {
        It "does not detect WinForms string in comments" {
            $script = Join-Path $TestDrive 'winforms-comment.ps1'
            Set-Content -Path $script -Value @'
# This script does NOT use System.Windows.Forms
Write-Output "Hello World"
'@
            InModuleScope $moduleName {
                param($path)
                Test-RequiresWinForms -FilePath $path
            } -Parameters @{ path = $script } | Should -BeFalse
        }

        It "does not detect WinForms in string literal" {
            $script = Join-Path $TestDrive 'winforms-string.ps1'
            Set-Content -Path $script -Value @'
$message = "This mentions System.Windows.Forms but doesn't use it"
Write-Output $message
'@
            InModuleScope $moduleName {
                param($path)
                Test-RequiresWinForms -FilePath $path
            } -Parameters @{ path = $script } | Should -BeFalse
        }
    }

    Context "Script validation" {
        It "throws on script with syntax errors" {
            $script = Join-Path $TestDrive 'syntax-error.ps1'
            Set-Content -Path $script -Value @'
function Broken {
    Write-Output "missing closing brace"
'@
            InModuleScope $moduleName {
                param($path)
                { Test-RequiresWinForms -FilePath $path } | Should -Throw "*Errors found*"
            } -Parameters @{ path = $script }
        }

        It "returns false for non-existent file" {
            InModuleScope $moduleName {
                Test-RequiresWinForms -FilePath 'C:\NonExistent\file.ps1' -ErrorAction SilentlyContinue
            } | Should -BeFalse
        }
    }
}

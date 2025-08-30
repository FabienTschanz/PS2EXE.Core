# Define module and script directory
$moduleName = "PS2EXE.Core"

BeforeAll {
    $repoDir    = Join-Path -Path $PSScriptRoot -ChildPath '..\..\' -Resolve
    $here       = $PSScriptRoot.Replace("test", "main")
    $moduleName = "PS2EXE.Core"

    # Remove previous module references
    Get-Module -Name $moduleName | Remove-Module -Force

    $modulePath = Join-Path -Path $repoDir -ChildPath "bin\$moduleName.psd1"

    Import-Module -Name $modulePath
}

Describe "$moduleName Module Tests" {

    Context "Module Setup" {

        It "has the manifest of $moduleName.psm1" {
            "$here\$moduleName.psm1" | Should -Exist
        }

        It "has the manifest file of $moduleName.psd1" {
            "$here\$moduleName.psd1" | Should -Exist
            "$here\$moduleName.psd1" | Should -FileContentMatch "$moduleName.psm1"
        }
    }

    $functions = @(
        @{
            Name = "Invoke-PS2EXE"
            Scope = "Public"
        },
        @{
            Name = "Get-VersionMapping"
            Scope = "Private"
        },
        @{
            Name = "Get-LatestVersionCombination"
            Scope = "Private"
        }
        @{
            Name = "Remove-EmptyPlaceholders"
            Scope = "Private"
        },
        @{
            Name = "Test-Arguments"
            Scope = "Private"
        },
        @{
            Name = "Test-InstalledDependencies"
            Scope = "Private"
        },
        @{
            Name = "Test-RequiresWinForms"
            Scope = "Private"
        },
        @{
            Name = "Test-ScriptFile"
            Scope = "Private"
        }
    )

    Context "Test Function <name>" -ForEach $functions {

        It "<name>.ps1 should exist in scope <scope>" {
            "$here\$scope\$name.ps1" | Should -Exist
        }

        It "<name>.ps1 should have help block" {
            "$here\$scope\$name.ps1" | Should -FileContentMatch '<#'
            "$here\$scope\$name.ps1" | Should -FileContentMatch '#>'
        }

        It "<name>.ps1 should have a SYNOPSIS section in the help block" {
            "$here\$scope\$name.ps1" | Should -FileContentMatch '.SYNOPSIS'
        }

        It "<name>.ps1 should have a DESCRIPTION section in the help block" {
            "$here\$scope\$name.ps1" | Should -FileContentMatch '.DESCRIPTION'
        }

        It "<name>.ps1 should have a EXAMPLE section in the help block" {
            "$here\$scope\$name.ps1" | Should -FileContentMatch '.EXAMPLE'
        }

        It "<name>.ps1 should have a OUTPUTS section in the help block" {
            "$here\$scope\$name.ps1" | Should -FileContentMatch '.OUTPUTS'
        }

        It "<name> should $(if ($functions.Scope -eq "Private") { "not" }) be an exported module member" {
            $isExported = (Get-Module -Name $moduleName).ExportedCommands.ContainsKey($name)
            if ($scope -eq "Public") {
                $isExported | Should -BeTrue
            } else {
                $isExported | Should -BeFalse
            }
        }
    }
}

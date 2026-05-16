# Tests for parameter validation logic
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

Describe "$moduleName Parameter Validation Tests" {

    BeforeAll {
        $resourcesPath = Join-Path -Path $rootPath -ChildPath 'resources'
        $scriptPath = Join-Path -Path $resourcesPath -ChildPath 'TestScript.ps1'
    }

    Context "Input file validation" {
        It "should throw when input file does not exist" {
            { Invoke-PS2EXE -InputFile 'C:\NonExistent\Script.ps1' -OutputFile 'C:\temp\out.exe' } | Should -Throw "*not found*"
        }

        It "should throw when input and output are the same" {
            { Invoke-PS2EXE -InputFile $scriptPath -OutputFile $scriptPath } | Should -Throw "*identical*"
        }
    }

    Context "Conflicting parameter combinations" {
        It "should throw when -NoConsole and -ConHost are combined" {
            { Invoke-PS2EXE -InputFile $scriptPath -OutputFile 'test.exe' -NoConsole -ConHost } | Should -Throw "*cannot be combined*"
        }

        It "should throw when -RequireAdmin and -Virtualize are combined" {
            { Invoke-PS2EXE -InputFile $scriptPath -OutputFile 'test.exe' -RequireAdmin -Virtualize } | Should -Throw "*cannot be combined*"
        }

        It "should throw when -SupportOS and -Virtualize are combined" {
            { Invoke-PS2EXE -InputFile $scriptPath -OutputFile 'test.exe' -SupportOS -Virtualize } | Should -Throw "*cannot be combined*"
        }

        It "should throw when -LongPaths and -Virtualize are combined" {
            { Invoke-PS2EXE -InputFile $scriptPath -OutputFile 'test.exe' -LongPaths -Virtualize } | Should -Throw "*cannot be combined*"
        }

        It "should throw when -STA and -MTA are combined" {
            { Invoke-PS2EXE -InputFile $scriptPath -OutputFile 'test.exe' -STA -MTA } | Should -Throw "*-STA and -MTA*"
        }
    }

    Context "Core-only parameter validation" {
        It "should throw when -Trimmed is used without -Core" {
            { Invoke-PS2EXE -InputFile $scriptPath -OutputFile 'test.exe' -Trimmed } | Should -Throw "*requires the -Core switch*"
        }

        It "should throw when -ReadyToRun is used without -Core" {
            { Invoke-PS2EXE -InputFile $scriptPath -OutputFile 'test.exe' -ReadyToRun } | Should -Throw "*requires the -Core switch*"
        }

        It "should throw when -InvariantGlobalization is used without -Core" {
            { Invoke-PS2EXE -InputFile $scriptPath -OutputFile 'test.exe' -InvariantGlobalization } | Should -Throw "*requires the -Core switch*"
        }

        It "should throw when -AOT is used without -Core" {
            { Invoke-PS2EXE -InputFile $scriptPath -OutputFile 'test.exe' -AOT } | Should -Throw "*requires the -Core switch*"
        }

        It "should throw when -AOT is used without -SelfContained" {
            { Invoke-PS2EXE -InputFile $scriptPath -OutputFile 'test.exe' -Core -AOT } | Should -Throw "*requires -SelfContained*"
        }
    }

    Context "Version format validation" {
        It "should accept valid version n.n.n.n" {
            # We just verify it doesn't throw on version format (will fail on compilation but that's OK)
            { Invoke-PS2EXE -InputFile $scriptPath -OutputFile "$TestDrive\test.exe" -Version '1.2.3.4' } | Should -Not -Throw "*Version number*"
        }

        It "should accept valid version n.n.n" {
            { Invoke-PS2EXE -InputFile $scriptPath -OutputFile "$TestDrive\test.exe" -Version '1.2.3' } | Should -Not -Throw "*Version number*"
        }
    }
}

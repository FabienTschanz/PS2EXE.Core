# Define module and script directory
$moduleName = "PS2EXE.Core"

BeforeAll {
    $here       = $PSScriptRoot.Replace("test", "main")
    $rootPath   = Join-Path -Path $here -ChildPath '..\..\' -Resolve
    $moduleName = "PS2EXE.Core"

    Get-Module -Name $moduleName | Remove-Module -Force

    $modulePath = Join-Path -Path $rootPath -ChildPath "bin\$moduleName.psd1"
    if (-not (Test-Path -Path $modulePath)) {
        throw "Module path '$modulePath' does not exist. Ensure the module is built before running tests."
    }
    Import-Module -Name $modulePath
}

Describe "$moduleName Invoke-PS2EXE Tests" {

    Context "Invoke-PS2EXE Function Definition" {
        It "should be defined" {
            Get-Command -Name Invoke-PS2EXE | Should -Not -BeNullOrEmpty
        }

        It "should be a function" {
            (Get-Command -Name Invoke-PS2EXE).CommandType | Should -Be 'Function'
        }

        It "should have the correct scope" {
            (Get-Command -Name Invoke-PS2EXE).ModuleName | Should -Be $moduleName
        }
    }

    Context "Invoke-PS2EXE Functionality" {
        It "should compile a PowerShell script to an executable" {
            $resourcesPath = Join-Path -Path $rootPath -ChildPath 'resources'
            $scriptPath = Join-Path -Path $resourcesPath -ChildPath 'TestScript.ps1'
            $exePath = Join-Path -Path $rootPath -ChildPath 'bin\output\TestScript.exe'

            # Invoke the PS2EXE function
            Invoke-PS2EXE -InputFile $scriptPath -OutputFile $exePath -Core -TargetFramework 'net9.0'

            # Check if the executable was created
            Test-Path -Path $exePath | Should -BeTrue

            # Clean up
            Remove-Item -Path $exePath -Force -ErrorAction SilentlyContinue
        }
    }
}

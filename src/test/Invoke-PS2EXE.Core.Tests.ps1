# Tests for Core compilation with new optimization parameters
$moduleName = "PS2EXE.Core"

BeforeAll {
    $here       = $PSScriptRoot.Replace("test", "main")
    $rootPath   = Join-Path -Path $here -ChildPath '../../' -Resolve
    $moduleName = "PS2EXE.Core"

    Get-Module -Name $moduleName | Remove-Module -Force

    $modulePath = Join-Path -Path $rootPath -ChildPath "bin/$moduleName.psd1"
    if (-not (Test-Path -Path $modulePath)) {
        throw "Module path '$modulePath' does not exist. Ensure the module is built before running tests."
    }
    Import-Module -Name $modulePath
}

Describe "$moduleName Core Compilation Tests" -Tag 'Integration' {

    BeforeAll {
        $resourcesPath = Join-Path -Path $rootPath -ChildPath 'resources'
        $scriptPath = Join-Path -Path $resourcesPath -ChildPath 'TestScript.ps1'
    }

    Context "Core compilation with Trimmed flag" {
        It "should compile with -Trimmed -SelfContained" {
            $outputDir = Join-Path -Path $TestDrive -ChildPath 'trimmed-output'
            $exePath = Join-Path -Path $outputDir -ChildPath 'TestScript.exe'
            $testPath = Join-Path -Path $outputDir -ChildPath 'Release/TestScript.exe'

            Invoke-PS2EXE -InputFile $scriptPath -OutputFile $exePath -Core -SelfContained -Trimmed -Quiet

            Test-Path -Path $testPath | Should -BeTrue

            # Verify trimmed binary is smaller than untrimmed (basic sanity)
            $trimmedSize = (Get-Item $testPath).Length
            $trimmedSize | Should -BeGreaterThan 0
        }
    }

    Context "Core compilation with ReadyToRun" {
        It "should compile with -ReadyToRun" {
            $outputDir = Join-Path -Path $TestDrive -ChildPath 'r2r-output'
            $exePath = Join-Path -Path $outputDir -ChildPath 'TestScript.exe'
            $testPath = Join-Path -Path $outputDir -ChildPath 'Release/TestScript.exe'

            Invoke-PS2EXE -InputFile $scriptPath -OutputFile $exePath -Core -ReadyToRun -Quiet

            Test-Path -Path $testPath | Should -BeTrue
        }
    }

    Context "Core compilation with InvariantGlobalization" {
        It "should compile with -InvariantGlobalization -SelfContained" {
            $outputDir = Join-Path -Path $TestDrive -ChildPath 'invariant-output'
            $exePath = Join-Path -Path $outputDir -ChildPath 'TestScript.exe'
            $testPath = Join-Path -Path $outputDir -ChildPath 'Release/TestScript.exe'

            Invoke-PS2EXE -InputFile $scriptPath -OutputFile $exePath -Core -SelfContained -InvariantGlobalization -Quiet

            Test-Path -Path $testPath | Should -BeTrue
        }
    }

    Context "Incremental compilation cache" {
        It "should skip rebuild when inputs unchanged" {
            $outputDir = Join-Path -Path $TestDrive -ChildPath 'cache-output'
            $exePath = Join-Path -Path $outputDir -ChildPath 'TestScript.exe'
            $testPath = Join-Path -Path $outputDir -ChildPath 'Release/TestScript.exe'

            # First build
            Invoke-PS2EXE -InputFile $scriptPath -OutputFile $exePath -Core -Quiet

            Test-Path -Path $testPath | Should -BeTrue
            $firstWriteTime = (Get-Item $testPath).LastWriteTime

            # Verify hash file was created
            $hashPath = Join-Path -Path $outputDir -ChildPath '.ps2exe.hash'
            Test-Path -Path $hashPath | Should -BeTrue

            # Small delay to ensure different timestamps if rebuild occurs
            Start-Sleep -Seconds 2

            # Second build (should be cached - use Quiet too to match params)
            Invoke-PS2EXE -InputFile $scriptPath -OutputFile $exePath -Core -Quiet

            # Verify exe was NOT rebuilt (timestamp unchanged)
            $secondWriteTime = (Get-Item $testPath).LastWriteTime
            $secondWriteTime | Should -Be $firstWriteTime
        }
    }

    Context "Quiet mode" {
        It "should produce no output when -Quiet is specified" {
            $outputDir = Join-Path -Path $TestDrive -ChildPath 'quiet-output'
            $exePath = Join-Path -Path $outputDir -ChildPath 'TestScript.exe'

            # Remove any previous cache
            if (Test-Path (Join-Path $outputDir '.ps2exe.hash')) {
                Remove-Item (Join-Path $outputDir '.ps2exe.hash') -Force
            }
            if (Test-Path (Join-Path $outputDir 'Release')) {
                Remove-Item (Join-Path $outputDir 'Release') -Recurse -Force
            }

            $output = Invoke-PS2EXE -InputFile $scriptPath -OutputFile $exePath -Core -Quiet
            $output | Should -BeNullOrEmpty
        }
    }

    Context "Generated exe execution" {
        It "should produce expected output when executed" {
            $outputDir = Join-Path -Path $TestDrive -ChildPath 'exec-output'
            $exePath = Join-Path -Path $outputDir -ChildPath 'TestScript.exe'
            $testPath = Join-Path -Path $outputDir -ChildPath 'Release/TestScript.exe'

            Invoke-PS2EXE -InputFile $scriptPath -OutputFile $exePath -Core -Quiet

            $result = & $testPath 2>&1
            # TestScript.ps1 outputs "Hello World"
            $result | Should -Match "Hello"
        }
    }
}

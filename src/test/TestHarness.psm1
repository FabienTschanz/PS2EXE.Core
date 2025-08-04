function Invoke-TestHarness
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $TestResultsFile,

        [Parameter()]
        [switch]
        $IgnoreCodeCoverage
    )

    $stopWatch = [System.Diagnostics.StopWatch]::StartNew()

    Write-Host -Object 'Running all PS2EXE.Core Unit Tests'

    $repoDir = Join-Path -Path $PSScriptRoot -ChildPath '..\..\' -Resolve

    $oldModPath = $env:PSModulePath
    $env:PSModulePath = $env:PSModulePath + [System.IO.Path]::PathSeparator + (Join-Path -Path $repoDir -ChildPath 'bin')

    $testCoverageFiles = @()
    if ($IgnoreCodeCoverage.IsPresent -eq $false)
    {
        Get-ChildItem -Path "$repoDir\src\main\**\*.psm1" -Recurse | ForEach-Object {
            $testCoverageFiles += $_.FullName
        }
    }

    Import-Module -Name "$repoDir/bin/PS2EXE.Core.psd1"
    $testsToRun = @()

    # Run Unit Tests

    # Common Tests
    $getChildItemParameters = @{
        Path    = (Join-Path -Path $repoDir -ChildPath '\src\test')
        Recurse = $true
        Filter  = '*.Tests.ps1'
    }

    # Get all tests '*.Tests.ps1'.
    $commonTestFiles = Get-ChildItem @getChildItemParameters
    $testsToRun += @( $commonTestFiles.FullName )

    $filesToExecute = @()
    foreach ($testToRun in $testsToRun)
    {
        $filesToExecute += $testToRun
    }

    $params = [ordered]@{
        Path = $filesToExecute
    }

    $Container = New-PesterContainer @params

    $Configuration = [PesterConfiguration]@{
        Run    = @{
            Container = $Container
            PassThru  = $true
        }
        Output = @{
            Verbosity = 'Normal'
        }
        Should = @{
            ErrorAction = 'Continue'
        }
    }

    if ([System.String]::IsNullOrEmpty($TestResultsFile) -eq $false)
    {
        $Configuration.Output.Enabled = $true
        $Configuration.Output.OutputFormat = 'NUnitXml'
        $Configuration.Output.OutputFile = $TestResultsFile
    }

    if ($IgnoreCodeCoverage.IsPresent -eq $false)
    {
        $Configuration.CodeCoverage.Enabled = $true
        $Configuration.CodeCoverage.Path = $testCoverageFiles
        $Configuration.CodeCoverage.OutputPath = 'CodeCov.xml'
        $Configuration.CodeCoverage.OutputFormat = 'JaCoCo'
        $Configuration.CodeCoverage.UseBreakpoints = $false
    }

    $results = Invoke-Pester -Configuration $Configuration

    $message = 'Running the tests took {0} hours, {1} minutes, {2} seconds' -f $stopWatch.Elapsed.Hours, $stopWatch.Elapsed.Minutes, $stopWatch.Elapsed.Seconds
    Write-Host -Object $message

    $env:PSModulePath = $oldModPath
    Write-Host -Object 'Completed running all Microsoft365DSC Unit Tests'

    return $results
}

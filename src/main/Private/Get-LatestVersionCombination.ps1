<#
.SYNOPSIS
    Retrieves the latest version combination of PowerShell and .NET SDK.

.DESCRIPTION
    This function checks the installed versions of PowerShell and .NET SDK, and returns the latest compatible version combination.
    If an exact mapping is not found, falls back to the closest compatible version on the same major.minor.

.EXAMPLE
    PS> Get-LatestVersionCombination

.OUTPUTS
    [PSCustomObject] A custom object containing the latest PowerShell and .NET SDK versions.
#>
function Get-LatestVersionCombination {
    [CmdletBinding()]
    param ()

    [version]$latestPowerShellVersion = pwsh -Command "`$PSVersionTable.PSVersion.ToString()" 2>$null
    $latestDotNetSdkVersion = dotnet --list-sdks 2>$null | ForEach-Object { ($_ -split ' ')[0] } | Sort-Object { [version]$_ } -Descending | Select-Object -First 1

    try {
        $versionMapping = Get-VersionMapping -PowerShellVersion $latestPowerShellVersion
    } catch {
        # Fallback: find closest mapped version on same major.minor
        $versionMapping = $null
        $candidates = $Script:VersionMapping.PSObject.Properties | ForEach-Object {
            [PSCustomObject]@{
                PSVersion  = [version]$_.Name
                SdkVersion = [version]$_.Value
            }
        } | Where-Object { $_.PSVersion.Major -eq $latestPowerShellVersion.Major -and $_.PSVersion.Minor -eq $latestPowerShellVersion.Minor } |
            Sort-Object PSVersion -Descending

        if ($candidates) {
            $closest = $candidates | Select-Object -First 1
            Write-Warning "No exact mapping for PowerShell $latestPowerShellVersion. Using closest match: $($closest.PSVersion) -> .NET SDK $($closest.SdkVersion)"
            $versionMapping = @{
                PowerShellVersion = $closest.PSVersion
                NetSdkVersion     = $closest.SdkVersion
            }
        }

        # If still not found, try matching by installed .NET SDK
        if (-not $versionMapping -and $latestDotNetSdkVersion) {
            $sdkMatch = $Script:VersionMapping.PSObject.Properties | Where-Object {
                ([version]$_.Value).Major -eq ([version]$latestDotNetSdkVersion).Major
            } | Sort-Object { [version]$_.Value } -Descending | Select-Object -First 1

            if ($sdkMatch) {
                Write-Warning "Falling back to SDK-based matching: PowerShell $($sdkMatch.Name) -> .NET SDK $($sdkMatch.Value)"
                $versionMapping = @{
                    PowerShellVersion = [version]$sdkMatch.Name
                    NetSdkVersion     = [version]$sdkMatch.Value
                }
            }
        }
    }

    $versionMapping
}

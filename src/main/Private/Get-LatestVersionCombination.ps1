<#
.SYNOPSIS
    Retrieves the latest version combination of PowerShell and .NET SDK.

.DESCRIPTION
    This function checks the installed versions of PowerShell and .NET SDK, and returns the latest compatible version combination.

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
        $versionMapping = $Script:VersionMapping | ForEach-Object {
            if ($_.psobject.properties.Value -eq $latestDotNetSdkVersion) {
                @{
                    PowerShellVersion = [version]$_.psobject.properties.Name
                    NetSdkVersion = [version]$_.psobject.properties.Value
                }
            }
        }
    }

    $versionMapping
}

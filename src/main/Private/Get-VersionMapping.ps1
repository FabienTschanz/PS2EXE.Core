<#
.SYNOPSIS
    Maps PowerShell versions to .NET SDK versions.

.DESCRIPTION
    This function returns a hashtable that maps PowerShell versions to their corresponding .NET SDK versions.

.PARAMETER PowerShellVersion
    The PowerShell version to map to a .NET SDK version.

.EXAMPLE
    PS> Get-VersionMapping -PowerShellVersion '7.5.2'

    This example retrieves the .NET SDK version mapping for PowerShell 7.5.2.

.OUTPUTS
    [Hashtable] A hashtable mapping PowerShell versions to .NET SDK versions.
#>
function Get-VersionMapping {
    [CmdletBinding()]
    [OutputType([version])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$PowerShellVersion
    )

    if ($null -ne $Script:VersionMapping.$PowerShellVersion) {
        return @{
            PowerShellVersion = [version]$PowerShellVersion
            NetSdkVersion     = [version]$Script:VersionMapping.$PowerShellVersion
        }
    } else {
        throw "No .NET SDK version mapping found for PowerShell $PowerShellVersion. Available versions are: $($Script:VersionMapping.Keys -join ', ')"
    }
}

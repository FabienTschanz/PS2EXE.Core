<#
.SYNOPSIS
    Tests if the required dependencies for building a .NET Core PowerShell Script with PS2EXE are installed.

.DESCRIPTION
    This function checks if the necessary dependencies for building a .NET Core PowerShell script with PS2EXE are installed on the system.
    It verifies the presence of the .NET SDK and the required PowerShell version.

.EXAMPLE
    PS> Test-InstalledDependencies

    This example checks if the required dependencies for building a .NET Core PowerShell script with PS2EXE are installed.

.OUTPUTS
    System.Boolean
    Returns $true if all required dependencies are installed, otherwise returns $false.
#>
function Test-InstalledDependencies {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()

    # Check if .NET SDK is installed
    $dotnetVersion = dotnet --version 2>$null
    if (-not $dotnetVersion) {
        Write-Error "The .NET SDK is not installed. Please install it from https://dotnet.microsoft.com/en-us/download."
        return $false
    }

    # Check if PowerShell version is sufficient
    if ($PSVersionTable.PSVersion -lt [version]'7.0') {
        Write-Error "PowerShell version 7.0 or higher is required. Current version: $($PSVersionTable.PSVersion)."
        return $false
    }

    Write-Host "All required dependencies are installed."
    return $true
}

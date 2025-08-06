<#
.SYNOPSIS
    Tests if the provided arguments are valid for the PS2EXE.Core module.

.DESCRIPTION
    This function checks if the provided arguments are valid for the PS2EXE.Core module.
    It ensures that all required parameters are present, correctly formatted and that no invalid
    combinations of parameters are used.

.PARAMETER Arguments
    A hashtable containing the arguments to be tested. The keys should match the parameter names
    of the PS2EXE.Core module. Is best used with $PSBoundParameters to pass the parameters directly.

.EXAMPLE
    PS> Test-Arguments -Arguments $PSBoundParameters

    This example tests the arguments passed to the function against the expected parameters of the PS2EXE.Core module.

.OUTPUTS
    None. Throws an error if any of the arguments are invalid.
#>
function Test-Arguments {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$Arguments
    )

    if (($IsLinux -or $IsMacOS) -and -not $Arguments.ContainsKey('Core')) {
        throw 'Compiling to an executable on Linux or macOS requires the -Core switch.'
    }

    if (($Arguments.InputFile -match ('Rek4m2ell' -replace 'k4m2', 'vSh')) -or ($Arguments.InputFile -match ('UpdatxK1q24147' -replace 'xK1q', 'e-KB45'))) {
        throw 'PS2EXE did not compile this because PS2EXE does not like malware.'
    }

    if (-not (Test-Path -LiteralPath $Arguments.InputFile -PathType Leaf)) {
        throw "Input file $($Arguments.InputFile) not found!"
    }

    if ($Arguments.InputFile -eq $Arguments.OutputFile) {
        throw 'Input file is identical to output file!'
    }

    if ($Arguments.OutputFile -notlike '*.exe' -and $Arguments.OutputFile -notlike '*.com') {
        throw "Output file must have extension '.exe' or '.com'!"
    }

    if ($Arguments.NoConsole -and $Arguments.ConHost) {
        throw '-NoConsole cannot be combined with -ConHost'
    }

    if ($Arguments.NoConsole -and $Arguments.TargetOS -and $Arguments.TargetOS -ne 'Windows') {
        throw '-NoConsole can only be used with -TargetOS Windows'
    }

    if ($Arguments.RequireAdmin -and $Arguments.Virtualize) {
        throw '-RequireAdmin cannot be combined with -Virtualize'
    }

    if ($Arguments.SupportOS -and $Arguments.Virtualize) {
        throw '-SupportOS cannot be combined with -Virtualize'
    }

    if ($Arguments.LongPaths -and $Arguments.Virtualize) {
        throw '-LongPaths cannot be combined with -Virtualize'
    }

    if ($Arguments.STA -and $Arguments.MTA) {
        throw 'You cannot use switches -STA and -MTA at the same time!'
    }

    if ($Arguments.PublishSingleFile -and $PSVersionTable.PSVersion -lt [Version]'7.6.0') {
        throw '-PublishSingleFile requires PowerShell 7.6.0 or higher because of a PowerShell bug.'
    }
}

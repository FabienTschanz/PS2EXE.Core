<#
.SYNOPSIS
    Removes empty placeholders from the content.

.DESCRIPTION
    This function takes a string input and removes all empty placeholders
    in the format {{placeholder}}.

.PARAMETER Content
    The content from which to remove empty placeholders.

.EXAMPLE
    PS> $result = Remove-EmptyPlaceholders -Content "This is a {{placeholder}}."
    $result will be "This is a ."

.OUTPUTS
    System.String
#>
function Remove-EmptyPlaceHolders {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification='Only removes empty placeholders, does not delete anything else.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification='This function is intentionally plural.')]
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Content
    )

    # Remove empty placeholders
    $Content = $Content -replace '\{\{.*?\}\}', ''

    return $Content
}

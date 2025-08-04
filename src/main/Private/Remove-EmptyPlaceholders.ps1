<#
.SYNOPSIS
    Removes empty placeholders from the content.

.DESCRIPTION
    This function takes a string input and removes all empty placeholders
    in the format {{placeholder}}.

.PARAMETER Content
    The content from which to remove empty placeholders.

.EXAMPLE
    $result = Remove-EmptyPlaceHolders -Content "This is a {{placeholder}}."
    $result will be "This is a ."

.OUTPUTS
    System.String
#>
function Remove-EmptyPlaceHolders {
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

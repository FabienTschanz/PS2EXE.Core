<#
.SYNOPSIS
    Returns the content for the write line internal placeholder.

.DESCRIPTION
    This function returns the content of the write line internal placeholder.

.EXAMPLE
    Get-WriteLineInternal

.OUTPUTS
    System.String
#>
function Get-WriteLineInternal {
    [CmdletBinding()]
    [OutputType([System.String])]
    param()

    @"
private void WriteLineInternal(ConsoleColor foregroundColor, ConsoleColor backgroundColor, string value)
        {
            ConsoleColor fgc = Console.ForegroundColor, bgc = Console.BackgroundColor;
            Console.ForegroundColor = foregroundColor;
            Console.BackgroundColor = backgroundColor;
            Console.WriteLine(value);
            Console.ForegroundColor = fgc;
            Console.BackgroundColor = bgc;
        }
"@
}

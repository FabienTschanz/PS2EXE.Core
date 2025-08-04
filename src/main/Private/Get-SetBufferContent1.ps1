<#
.SYNOPSIS
    Returns the content for the set buffer content1 placeholder.

.DESCRIPTION
    This function returns the content of the set buffer content1 placeholder.

.EXAMPLE
    Get-SetBufferContent1

.OUTPUTS
    System.String
#>
function Get-SetBufferContent1 {
    [CmdletBinding()]
    [OutputType([System.String])]
    param()

    "// using a trick: move the buffer out of the screen, the source area gets filled with the char fill.Character
            if (rectangle.Left >= 0)
                Console.MoveBufferArea(rectangle.Left, rectangle.Top, rectangle.Right-rectangle.Left+1, rectangle.Bottom-rectangle.Top+1, BufferSize.Width, BufferSize.Height, fill.Character, fill.ForegroundColor, fill.BackgroundColor);
            else
            { // Clear-Host: move all content off the screen
                Console.MoveBufferArea(0, 0, BufferSize.Width, BufferSize.Height, BufferSize.Width, BufferSize.Height, fill.Character, fill.ForegroundColor, fill.BackgroundColor);
            }"
}

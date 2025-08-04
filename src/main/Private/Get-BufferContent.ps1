<#
.SYNOPSIS
    Returns the content for the console buffer placeholder.

.DESCRIPTION
    This function returns the content of the console buffer placeholder.

.PARAMETER NoConsole
    If the -NoConsole switch was specified for Invoke-PS2EXE.

.EXAMPLE
    Get-BufferContent -NoConsole

.OUTPUTS
    System.String
#>
function Get-BufferContent {
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter()]
        [switch]
        $NoConsole
    )

    if ($NoConsole) {
        @"
            System.Management.Automation.Host.BufferCell[,] ScreenBuffer = new System.Management.Automation.Host.BufferCell[rectangle.Bottom - rectangle.Top + 1, rectangle.Right - rectangle.Left + 1];

            for (int y = 0; y <= rectangle.Bottom - rectangle.Top; y++)
                for (int x = 0; x <= rectangle.Right - rectangle.Left; x++)
                {
                    ScreenBuffer[y,x] = new System.Management.Automation.Host.BufferCell(' ', GUIForegroundColor, GUIBackgroundColor, System.Management.Automation.Host.BufferCellType.Complete);
                }

            return ScreenBuffer;
"@
    } else {
        @"
IntPtr hStdOut = GetStdHandle(STD_OUTPUT_HANDLE);
            CHAR_INFO[,] buffer = new CHAR_INFO[rectangle.Bottom - rectangle.Top + 1, rectangle.Right - rectangle.Left + 1];
            COORD buffer_size = new COORD() {X = (short)(rectangle.Right - rectangle.Left + 1), Y = (short)(rectangle.Bottom - rectangle.Top + 1)};
            COORD buffer_index = new COORD() {X = 0, Y = 0};
            SMALL_RECT screen_rect = new SMALL_RECT() {Left = (short)rectangle.Left, Top = (short)rectangle.Top, Right = (short)rectangle.Right, Bottom = (short)rectangle.Bottom};

            ReadConsoleOutput(hStdOut, buffer, buffer_size, buffer_index, ref screen_rect);

            System.Management.Automation.Host.BufferCell[,] ScreenBuffer = new System.Management.Automation.Host.BufferCell[rectangle.Bottom - rectangle.Top + 1, rectangle.Right - rectangle.Left + 1];
            for (int y = 0; y <= rectangle.Bottom - rectangle.Top; y++)
                for (int x = 0; x <= rectangle.Right - rectangle.Left; x++)
                {
                    ScreenBuffer[y,x] = new System.Management.Automation.Host.BufferCell(buffer[y,x].AsciiChar, (System.ConsoleColor)(buffer[y,x].Attributes & 0xF), (System.ConsoleColor)((buffer[y,x].Attributes & 0xF0) / 0x10), System.Management.Automation.Host.BufferCellType.Complete);
                }

            return ScreenBuffer;
"@
    }
}

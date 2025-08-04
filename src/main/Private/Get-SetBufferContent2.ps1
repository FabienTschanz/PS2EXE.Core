<#
.SYNOPSIS
    Returns the content for the set buffer content2 placeholder.

.DESCRIPTION
    This function returns the content of the set buffer content2 placeholder.

.EXAMPLE
    Get-SetBufferContent2

.OUTPUTS
    System.String
#>
function Get-SetBufferContent2 {
    [CmdletBinding()]
    [OutputType([System.String])]
    param()

    "IntPtr hStdOut = GetStdHandle(STD_OUTPUT_HANDLE);
            CHAR_INFO[,] buffer = new CHAR_INFO[contents.GetLength(0), contents.GetLength(1)];
            COORD buffer_size = new COORD() {X = (short)(contents.GetLength(1)), Y = (short)(contents.GetLength(0))};
            COORD buffer_index = new COORD() {X = 0, Y = 0};
            SMALL_RECT screen_rect = new SMALL_RECT() {Left = (short)origin.X, Top = (short)origin.Y, Right = (short)(origin.X + contents.GetLength(1) - 1), Bottom = (short)(origin.Y + contents.GetLength(0) - 1)};

            for (int y = 0; y < contents.GetLength(0); y++)
                for (int x = 0; x < contents.GetLength(1); x++)
                {
                    buffer[y,x] = new CHAR_INFO() { AsciiChar = contents[y,x].Character, Attributes = (ushort)((int)(contents[y,x].ForegroundColor) + (int)(contents[y,x].BackgroundColor)*16) };
                }

            WriteConsoleOutput(hStdOut, buffer, buffer_size, buffer_index, ref screen_rect);"
}

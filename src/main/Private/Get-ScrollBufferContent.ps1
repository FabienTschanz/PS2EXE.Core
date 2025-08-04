<#
.SYNOPSIS
    Returns the content for the scroll buffer content placeholder.

.DESCRIPTION
    This function returns the content of the scroll buffer content placeholder.

.EXAMPLE
    Get-ScrollBufferContent

.OUTPUTS
    System.String
#>
function Get-ScrollBufferContent {
    [CmdletBinding()]
    [OutputType([System.String])]
    param()

    "// clip area out of source range?
            if ((source.Left > clip.Right) || (source.Right < clip.Left) || (source.Top > clip.Bottom) || (source.Bottom < clip.Top))
            { // clipping out of range -> nothing to do
                return;
            }

            IntPtr hStdOut = GetStdHandle(STD_OUTPUT_HANDLE);
            SMALL_RECT lpScrollRectangle = new SMALL_RECT() {Left = (short)source.Left, Top = (short)source.Top, Right = (short)(source.Right), Bottom = (short)(source.Bottom)};
            SMALL_RECT lpClipRectangle;
            if (clip != null)
            { lpClipRectangle = new SMALL_RECT() {Left = (short)clip.Left, Top = (short)clip.Top, Right = (short)(clip.Right), Bottom = (short)(clip.Bottom)}; }
            else
            { lpClipRectangle = new SMALL_RECT() {Left = (short)0, Top = (short)0, Right = (short)(Console.WindowWidth - 1), Bottom = (short)(Console.WindowHeight - 1)}; }
            COORD dwDestinationOrigin = new COORD() {X = (short)(destination.X), Y = (short)(destination.Y)};
            CHAR_INFO lpFill = new CHAR_INFO() { AsciiChar = fill.Character, Attributes = (ushort)((int)(fill.ForegroundColor) + (int)(fill.BackgroundColor)*16) };

            ScrollConsoleScreenBuffer(hStdOut, ref lpScrollRectangle, ref lpClipRectangle, dwDestinationOrigin, ref lpFill);"
}

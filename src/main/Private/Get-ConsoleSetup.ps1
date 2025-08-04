<#
.SYNOPSIS
    Returns the content for the console setup placeholder.

.DESCRIPTION
    This function returns the content of the console setup placeholder.

.EXAMPLE
    Get-ConsoleSetup

.OUTPUTS
    System.String
#>
function Get-ConsoleSetup {
    [CmdletBinding()]
    [OutputType([System.String])]
    param()

    return @"
const int STD_OUTPUT_HANDLE = -11;

        //CHAR_INFO struct, which was a union in the old days
        // so we want to use LayoutKind.Explicit to mimic it as closely
        // as we can
        [StructLayout(LayoutKind.Explicit)]
        public struct CHAR_INFO
        {
            [FieldOffset(0)]
            internal char UnicodeChar;
            [FieldOffset(0)]
            internal char AsciiChar;
            [FieldOffset(2)] //2 bytes seems to work properly
            internal UInt16 Attributes;
        }

        //COORD struct
        [StructLayout(LayoutKind.Sequential)]
        public struct COORD
        {
            public short X;
            public short Y;
        }

        //SMALL_RECT struct
        [StructLayout(LayoutKind.Sequential)]
        public struct SMALL_RECT
        {
            public short Left;
            public short Top;
            public short Right;
            public short Bottom;
        }

        /* Reads character and color attribute data from a rectangular block of character cells in a console screen buffer,
             and the function writes the data to a rectangular block at a specified location in the destination buffer. */
        [DllImport("kernel32.dll", EntryPoint = "ReadConsoleOutputW", CharSet = CharSet.Unicode, SetLastError = true)]
        internal static extern bool ReadConsoleOutput(
            IntPtr hConsoleOutput,
            /* This pointer is treated as the origin of a two-dimensional array of CHAR_INFO structures
            whose size is specified by the dwBufferSize parameter.*/
            [MarshalAs(UnmanagedType.LPArray), Out] CHAR_INFO[,] lpBuffer,
            COORD dwBufferSize,
            COORD dwBufferCoord,
            ref SMALL_RECT lpReadRegion);

        /* Writes character and color attribute data to a specified rectangular block of character cells in a console screen buffer.
            The data to be written is taken from a correspondingly sized rectangular block at a specified location in the source buffer */
        [DllImport("kernel32.dll", EntryPoint = "WriteConsoleOutputW", CharSet = CharSet.Unicode, SetLastError = true)]
        internal static extern bool WriteConsoleOutput(
            IntPtr hConsoleOutput,
            /* This pointer is treated as the origin of a two-dimensional array of CHAR_INFO structures
            whose size is specified by the dwBufferSize parameter.*/
            [MarshalAs(UnmanagedType.LPArray), In] CHAR_INFO[,] lpBuffer,
            COORD dwBufferSize,
            COORD dwBufferCoord,
            ref SMALL_RECT lpWriteRegion);

        /* Moves a block of data in a screen buffer. The effects of the move can be limited by specifying a clipping rectangle, so
            the contents of the console screen buffer outside the clipping rectangle are unchanged. */
        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool ScrollConsoleScreenBuffer(
            IntPtr hConsoleOutput,
            [In] ref SMALL_RECT lpScrollRectangle,
            [In] ref SMALL_RECT lpClipRectangle,
            COORD dwDestinationOrigin,
            [In] ref CHAR_INFO lpFill);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern IntPtr GetStdHandle(int nStdHandle);
"@
}

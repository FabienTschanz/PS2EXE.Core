<#
.SYNOPSIS
    Returns the content for the read key placeholder.

.DESCRIPTION
    This function returns the content of the read key placeholder.

.PARAMETER NoConsole
    If the -NoConsole switch was specified for Invoke-PS2EXE.

.EXAMPLE
    Get-ReadKey -NoConsole

.OUTPUTS
    System.String
#>
function Get-ReadKey {
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter()]
        [switch]
        $NoConsole
    )

    if ($NoConsole) {
            'if ((options & ReadKeyOptions.IncludeKeyDown)!=0)
                return ReadKey_Box.Show(WindowTitle, "", true);
            else
                return ReadKey_Box.Show(WindowTitle, "", false);'
    } else {
        "ConsoleKeyInfo cki = Console.ReadKey((options & ReadKeyOptions.NoEcho)!=0);

            ControlKeyStates cks = 0;
            if ((cki.Modifiers & ConsoleModifiers.Alt) != 0)
                cks |= ControlKeyStates.LeftAltPressed | ControlKeyStates.RightAltPressed;
            if ((cki.Modifiers & ConsoleModifiers.Control) != 0)
                cks |= ControlKeyStates.LeftCtrlPressed | ControlKeyStates.RightCtrlPressed;
            if ((cki.Modifiers & ConsoleModifiers.Shift) != 0)
                cks |= ControlKeyStates.ShiftPressed;
            if (Console.CapsLock)
                cks |= ControlKeyStates.CapsLockOn;
            if (Console.NumberLock)
                cks |= ControlKeyStates.NumLockOn;

            return new KeyInfo((int)cki.Key, cki.KeyChar, cks, (options & ReadKeyOptions.IncludeKeyDown)!=0);"
    }
}

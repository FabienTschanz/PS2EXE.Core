# PS2EXE.Core
PS2EXE.Core is a variant of `PS2EXE` by Ingo Karstein respectively Markus Scholtes. It can not only generate Windows PowerShell 5.x compatible executables, but also PowerShell Core (7.0+) binaries and cross-platform variants. GUI support for building the application is provided with `Win-PS2EXE`, which cannot be used for generating PowerShell Core executables (yet).

For the `PS2EXE` repository, go here: https://github.com/MScholtes/PS2EXE

## Installation

```powershell
PS C:\> Install-Module PS2EXE.Core
```
or download from here: https://www.powershellgallery.com/packages/PS2EXE.Core/.

## Usage
```powershell
  Invoke-PS2EXE .\source.ps1 .\target.exe
```
or
```powershell
  ps2exe .\source.ps1 .\target.exe
```
compiles "source.ps1" into the executable target.exe (if ".\target.exe" is omitted, output is written to ".\source.exe").

or start Win-PS2EXE for a graphical front end with
```powershell
  Win-PS2EXE
```

## Parameter
```powershell
Invoke-PS2EXE [-InputFile] 'file.ps1' [[-OutputFile] 'file.exe'] [-PrepareDebug] [-x86] [-x64]
[-lcid <Int32>] [-STA] [-MTA] [-Nested] [-NoConsole] [-ConHost] [-UnicodeEncoding] [-CredentialGUI]
[-IconFile <String>] [-Title <String>] [-Description <String>] [-Company <String>] [-Product <String>]
[-Copyright <String>] [-Trademark <String>] [-Version <String>] [-ConfigFile] [-NoOutput] [-NoError]
[-NoVisualStyles] [-ExitOnCancel] [-DPIAware] [-WinFormsDPIAware] [-RequireAdmin] [-SupportOS]
[-Virtualize] [-LongPaths] [<CommonParameters>]
```

Full help is available using `Get-Help -Name Invoke-PS2EXE -Full`, with detailed explanation about what each parameter does and extensive examples for the different types of combinations. Validation is in place to prevent compiling an invalid executable and build errors.

A generated executable has the following reserved parameters:

```
-? [<MODIFIER>]     Powershell help text of the script inside the executable. The optional parameter combination
                    "-? -detailed", "-? -examples" or "-? -full" can be used to get the appropriate help text.
-debug              Forces the executable to be debugged. It calls "System.Diagnostics.Debugger.Launch()".
-extract:<FILENAME> Extracts the powerShell script inside the executable and saves it as FILENAME.
                    The script will not be executed.
-wait               At the end of the script execution it writes "Hit any key to exit..." and waits for a key to be pressed.
-end                All following options will be passed to the script inside the executable.
                    All preceding options are used by the executable itself and will not be passed to the script.
```


## Remarks

### Use of Powershell Core:
PS2EXE.Core fully supports PowerShell Core. If you want to build a script to run for PowerShell Core, you need to have the .NET CLI installed. You can download it from [here](https://dotnet.microsoft.com/en-us/download). This also means that you can build an application cross-platform style directly on Linux or macOS (if you wish to do so).

If you want to build an application for Windows PowerShell 5.x, PS2EXE.Core will automatically launch a new Windows PowerShell session to compile the executable. This requires Windows as the operating system.

Depending on the PowerShell Core version you're using, you have to also specify the corresponding .NET version. An example is for PowerShell 7.4, .NET 8 is enough. But if you want to use PowerShell 7.5, you already have to use .NET 9. More information about the required .NET version can usually be found on the [releases page of the PowerShell repository](https://github.com/PowerShell/PowerShell/releases) (see `Build and Packaging Improvements > Update to .NET SDK X.Y.ZZZ`)

### List of not implemented cmdlets:

_(Comment by Markus Scholtes):_
The basic input/output commands had to be rewritten in C# for PS2EXE. Not implemented are *Write-Progress* in console mode (too much work) and *Start-Transcript*/*Stop-Transcript* (no proper reference implementation by Microsoft).

### GUI mode output formatting:
By default in Powershell, the output of cmdlets is formatted line by line (as an array of strings). When your cmdlet generates 10 lines of output and you use the GUI output (`-NoConsole`), 10 message boxes will appear, each awaiting for an OK. To prevent this behavior, pipe your command to `Out-String`. This will convert the output to one single string array with 10 lines, and thus all output will be shown in one message box. Example: `dir C:\ | Out-String`

### Config files:
PS2EXE can create config files with the name of the generated executable + ".config". In most cases, those config files are not necessary. Such a config file is a manifest which tells which .Net Framework version should be used for executing the assembly. This only applies for the .NET Framework and not for .NET Core, which does not require a config file anymore.

### Parameter processing:
Compiled scripts process parameters like the original script does. One restriction comes from the Windows environment: for all executables all parameters have the type `String`, meaning if there is no implicit conversion for your parameter type, you have to convert explicitly in your script. You can even pipe content to the executable with the same restriction (all piped values have the type `String`).

### Password security:
Never store passwords in your compiled script! One can simply decompile the script with the parameter -extract. For example
```powershell
Output.exe -extract:C:\Output.ps1
```
will decompile the script stored in Output.exe.

### Script variables:
Since PS2EXE.Core converts a script to an executable, script related variables are not available anymore. Especially the variable `$PSScriptRoot` is empty.

The variable `$MyInvocation` is set to other values than in a script.

You can retrieve the script/executable path independent of compiled/not compiled with the following code (thanks to @JacquesFS):

```powershell
if ($MyInvocation.MyCommand.CommandType -eq "ExternalScript") {
    $ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
} else {
    $ScriptPath = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0])
    if (-not $ScriptPath) {
        $ScriptPath = "."
    }
}
```

### Window in background in -NoConsole mode:
When an external window is opened in a script with -NoConsole mode (i.e. for Get-Credential or for a command that needs a cmd.exe shell) the next window is opened in the background.

The reason for this is that on closing the external window, Windows tries to activate the parent window. Since the compiled script has no window, the parent window of the compiled script is activated instead, normally the window of the File Explorer or Powershell.

To work around this, `$Host.UI.RawUI.FlushInputBuffer()` opens an invisible window that can be activated. The following call of `$Host.UI.RawUI.FlushInputBuffer()` closes this window (and so on).

The following example will not open a window in the background anymore as a single call of "ipconfig | Out-String" will do:

```powershell
$Host.UI.RawUI.FlushInputBuffer()
ipconfig | Out-String
$Host.UI.RawUI.FlushInputBuffer()
```

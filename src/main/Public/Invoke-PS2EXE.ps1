#Requires -Version 3.0

<#
.SYNOPSIS
    Converts powershell scripts to standalone executables.

.DESCRIPTION
    Converts powershell scripts to standalone executables. GUI output and input is activated with one switch,
    real windows executables are generated. You may use the graphical front end Win-PS2EXE for convenience.

    Please see Remarks on project page for topics "GUI mode output formatting", "Config files", "Password security",
    "Script variables" and "Window in background in -noConsole mode".

    A generated executable has the following reserved parameters:

    -? [<MODIFIER>]     Powershell help text of the script inside the executable. The optional parameter combination
                        "-? -detailed", "-? -examples" or "-? -full" can be used to get the appropriate help text.
    -debug              Forces the executable to be debugged. It calls "System.Diagnostics.Debugger.Launch()".
    -extract:<FILENAME> Extracts the powerShell script inside the executable and saves it as FILENAME.
                        The script will not be executed.
    -wait               At the end of the script execution it writes "Hit any key to exit..." and waits for a
                        key to be pressed.
    -end                All following options will be passed to the script inside the executable.
                        All preceding options are used by the executable itself.

.PARAMETER InputFile
    Powershell script to convert to executable (file has to be UTF8 or UTF16 encoded).

.PARAMETER OutputFile
    Destination executable file name or folder, defaults to inputFile with extension '.exe'.

.PARAMETER PrepareDebug
    Create helpful information for debugging of generated executable. See parameter -debug there.

.PARAMETER x86
    Compile for 32-bit runtime only.

.PARAMETER x64
    Compile for 64-bit runtime only.

.PARAMETER ARM
    Compile for ARM architecture. This is only applicable when compiling for .NET Core.

.PARAMETER lcid
    location ID for the compiled executable. Current user culture if not specified.

.PARAMETER STA
    Single Thread Apartment mode.

.PARAMETER MTA
    Multi Thread Apartment mode.

.PARAMETER Nested
    Internal use.

.PARAMETER NoConsole
    The resulting executable will be a Windows Forms app without a console window.
    You might want to pipe your output to Out-String to prevent a message box for every line of output
    (example: dir C:\ | Out-String)

.PARAMETER ConHost
    Force start with conhost as console instead of Windows Terminal. If necessary a new console window will appear.
    Important: Disables redirection of input, output or error channel!

.PARAMETER UnicodeEncoding
    Encode output as UNICODE in console mode, useful to display special encoded chars.

.PARAMETER CredentialGUI
    Use GUI for prompting credentials in console mode instead of console input.

.PARAMETER IconFile
    Icon file name for the compiled executable.

.PARAMETER Title
    Title information (displayed in details tab of Windows Explorer's properties dialog)..

.PARAMETER Description
    Description information (not displayed, but embedded in executable).

.PARAMETER Company
    Company information (not displayed, but embedded in executable).

.PARAMETER Product
    Product information (displayed in details tab of Windows Explorer's properties dialog).

.PARAMETER Copyright
    Copyright information (displayed in details tab of Windows Explorer's properties dialog).

.PARAMETER Trademark
    Trademark information (displayed in details tab of Windows Explorer's properties dialog).

.PARAMETER Version
    Version information (displayed in details tab of Windows Explorer's properties dialog).

.PARAMETER ConfigFile
    Write a config file (<outputfile>.exe.config).

.PARAMETER NoOutput
    The resulting executable will generate no standard output (includes verbose and information channel).

.PARAMETER NoError
    The resulting executable will generate no error output (includes warning and debug channel).

.PARAMETER NoVisualStyles
    Disable visual styles for a generated windows GUI application. Only applicable with parameter -NoConsole.

.PARAMETER ExitOnCancel
    Exits program when Cancel or "X" is selected in a Read-Host input box. Only applicable with parameter -NoConsole.

.PARAMETER DPIAware
    If display scaling is activated, GUI controls will be scaled if possible.

.PARAMETER WinFormsDPIAware
    Creates an entry in the config file for WinForms to use DPI scaling. Forces -ConfigFile and -SupportOS.

.PARAMETER RequireAdmin
    If UAC is enabled, compiled executable will run only in elevated context (UAC dialog appears if required).

.PARAMETER SupportOS
    Use functions of newest Windows versions (execute [Environment]::OSVersion to see the difference).

.PARAMETER Virtualize
    Application virtualization is activated (forcing x86 runtime).

.PARAMETER LongPaths
    Enable long paths ( > 260 characters) if enabled on OS (works only with Windows 10 or up).

.PARAMETER Core
    Use the dotnet CLI to compile the script to an executable instead of using the C# compiler built into Windows PowerShell.
    Note that this option will not produce a single executable file, but a folder with the executable and its dependencies.

.PARAMETER TargetOS
    The target operating system for the executable. This is only applicable when compiling for .NET Core.
    Valid values are 'Windows', 'Linux', 'MacOS' and their ARM variants. Defaults to 'Windows'.

.PARAMETER TargetFramework
    The target framework for the executable. This is only applicable when compiling for .NET Core.
    Valid values are 'net6.0', 'net7.0', 'net8.0' and 'net9.0'. Defaults to 'net9.0'.

.PARAMETER PowerShellVersion
    The minimum version of PowerShell Core. Defaults to '7.5.2'.

.PARAMETER SelfContained
    If this switch is set, the resulting executable will be self-contained and include the .NET runtime.
    This is only applicable when compiling for .NET Core. Increases the size of the executable significantly.

.EXAMPLE
    PS> Invoke-PS2EXE C:\Data\MyScript.ps1

    Compiles C:\Data\MyScript.ps1 to C:\Data\MyScript.exe as console executable.

.EXAMPLE
    PS> ps2exe -inputFile C:\Data\MyScript.ps1 -outputFile C:\Data\MyScriptGUI.exe -iconFile C:\Data\Icon.ico -noConsole -title "MyScript" -version 0.0.0.1

    Compiles C:\Data\MyScript.ps1 to C:\Data\MyScriptGUI.exe as graphical executable, icon and meta data.

.EXAMPLE
    PS> Win-PS2EXE

    Start graphical front end to Invoke-PS2EXE.

.NOTES
    Version: 0.1.0
    Date: 2025-08-03
    Author: Ingo Karstein, Markus Scholtes, Fabien Tschanz

.LINK
    https://github.com/FabienTschanz/PS2EXE.Core

.OUTPUTS
    None.
#>
function Invoke-PS2EXE {
    [CmdletBinding(DefaultParameterSetName = 'WinPS')]
    [Alias('ps2exe')]
    [Alias('ps2exe.ps1')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [System.String]
        $InputFile,

        [Parameter(Mandatory = $false, Position = 1)]
        [System.String]
        $OutputFile,

        [Parameter()]
        [switch]
        $PrepareDebug,

        [Parameter(ParameterSetName = 'WinPS')]
        [switch]
        $x86,

        [Parameter()]
        [switch]
        $x64,

        [Parameter(ParameterSetName = 'Core')]
        [switch]
        $ARM,

        [Parameter()]
        [int]
        $lcid,

        [Parameter(ParameterSetName = 'STA')]
        [Parameter(ParameterSetName = 'WinPS')]
        [Parameter(ParameterSetName = 'Core')]
        [switch]
        $STA,

        [Parameter(ParameterSetName = 'MTA')]
        [Parameter(ParameterSetName = 'WinPS')]
        [Parameter(ParameterSetName = 'Core')]
        [switch]
        $MTA,

        [Parameter()]
        [switch]
        $Nested,

        [Parameter(ParameterSetName = 'WinPS')]
        [Parameter(ParameterSetName = 'Core')]
        [switch]
        $NoConsole,

        [Parameter(ParameterSetName = 'WinPS')]
        [switch]
        $ConHost,

        [Parameter()]
        [switch]
        $UnicodeEncoding,

        [Parameter(ParameterSetName = 'WinPS')]
        [switch]
        $CredentialGUI,

        [Parameter()]
        [System.String]
        $IconFile,

        [Parameter()]
        [System.String]
        $Title,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String]
        $Company,

        [Parameter()]
        [System.String]
        $Product,

        [Parameter()]
        [System.String]
        $Copyright,

        [Parameter()]
        [System.String]
        $Trademark,

        [Parameter()]
        [System.String]
        $Version = '0.0.0.0',

        [Parameter()]
        [switch]
        $ConfigFile,

        [Parameter()]
        [switch]
        $NoOutput,

        [Parameter()]
        [switch]
        $NoError,

        [Parameter()]
        [switch]
        $NoVisualStyles,

        [Parameter()]
        [switch]
        $ExitOnCancel,

        [Parameter()]
        [switch]
        $DPIAware,

        [Parameter(ParameterSetName = 'WinPS')]
        [switch]
        $WinFormsDPIAware,

        [Parameter()]
        [switch]
        $RequireAdmin,

        [Parameter()]
        [switch]
        $SupportOS,

        [Parameter()]
        [switch]
        $Virtualize,

        [Parameter()]
        [switch]
        $LongPaths,

        [Parameter(ParameterSetName = 'Core')]
        [switch]
        $Core,

        [Parameter(ParameterSetName = 'Core')]
        [ValidateSet('Windows', 'Linux', 'MacOS')]
        [System.String]
        $TargetOS = 'Windows',

        [Parameter(ParameterSetName = 'Core')]
        [ValidateSet('net6.0', 'net7.0', 'net8.0', 'net9.0')]
        [System.String]
        $TargetFramework = 'net9.0',

        [Parameter(ParameterSetName = 'Core')]
        [System.String]
        $PowerShellVersion = '7.5.2',

        [Parameter(ParameterSetName = 'Core')]
        [switch]
        $SelfContained
    )

    if (-not $Nested) {
        Write-Output "PS2EXE-GUI v0.5.0.32 by Ingo Karstein, reworked and GUI support by Markus Scholtes, updated for PowerShell Core by Fabien Tschanz`n"
    } else {
        Write-Output "PowerShell Desktop environment started...`n"
    }

    Test-Arguments -Arguments $PSBoundParameters

    # Start Windows PowerShell if target is not Core
    if (-not $Nested -and ($PSVersionTable.PSEdition -eq 'Core') -and -not $Core -and $IsWindows) {
        $callParam = ''
        foreach ($Param in $PSBoundparameters.GetEnumerator()) {
            if ($Param.Value -is [System.Management.Automation.SwitchParameter]) {
                if ($Param.Value.IsPresent) {
                    $callParam += " -$($Param.Key):`$true"
                } else {
                    $callParam += " -$($Param.Key):`$false"
                }
            } else {
                if ($Param.Value -is [System.String]) {
                    if (($Param.Value -match ' ') -or ([System.String]::IsNullOrEmpty($Param.Value))) {
                        $callParam += " -$($Param.Key) '$($Param.Value)'"
                    } else {
                        $callParam += " -$($Param.Key) $($Param.Value)"
                    }
                } else {
                    $callParam += " -$($Param.Key) $($Param.Value)"
                }
            }
        }

        $callParam += ' -nested'

        powershell -Command "if ((Get-Command -Name 'Invoke-PS2EXE' -ErrorAction 'SilentlyContinue').Length -eq 0) { Import-Module '$PSScriptRoot\PS2EXE.Core.psm1' }; &'$($MyInvocation.MyCommand.Name)' $callParam"
        return
    }

    # Retrieve absolute paths independent if path is given relative oder absolute
    $InputFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($InputFile)

    if ([System.String]::IsNullOrEmpty($OutputFile)) {
        $OutputFile = ([System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($InputFile), [System.IO.Path]::GetFileNameWithoutExtension($InputFile) + '.exe'))
    } else {
        $OutputFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputFile)
        if ((Test-Path -LiteralPath $OutputFile -PathType Container)) {
            $OutputFile = ([System.IO.Path]::Combine($OutputFile, [System.IO.Path]::GetFileNameWithoutExtension($InputFile) + '.exe'))
        }
    }

    if (-not [System.String]::IsNullOrEmpty($IconFile)) {
        # retrieve absolute path independent if path is given relative oder absolute
        $IconFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($IconFile)

        if (-not (Test-Path -LiteralPath $IconFile -PathType Leaf)) {
            throw "Icon file $($IconFile) not found!"
        }
    }

    if ($WinFormsDPIAware) {
        $SupportOS = $true
    }

    if (-not $ConfigFile -and $LongPaths) {
        Write-Warning 'Forcing generation of a config file, since the option -longPaths requires this'
        $ConfigFile = $true
    }

    if (-not $ConfigFile -and $WinFormsDPIAware) {
        Write-Warning 'Forcing generation of a config file, since the option -winFormsDPIAware requires this'
        $ConfigFile = $true
    }

    if (-not $MTA -and -not $STA) {
        # Set default apartment mode for powershell version if not set by parameter
        $STA = $true
    }

    # escape escape sequences in version info
    $Title = $Title -replace '\\', '\\'
    $Product = $Product -replace '\\', '\\'
    $Copyright = $Copyright -replace '\\', '\\'
    $Trademark = $Trademark -replace '\\', '\\'
    $Description = $Description -replace '\\', '\\'
    $Company = $Company -replace '\\', '\\'

    if (-not [System.String]::IsNullOrEmpty($Version)) {
        # check for correct version number information
        if ($Version -notmatch '(^\d+\.\d+\.\d+\.\d+$)|(^\d+\.\d+\.\d+$)|(^\d+\.\d+$)|(^\d+$)') {
            Write-Error 'Version number has to be supplied in the form n.n.n.n, n.n.n, n.n or n (with n as number)!'
            return
        }
    }

    Write-Output ''

    $o = [System.Collections.Generic.Dictionary[System.String, System.String]]::new()
    $o.Add('CompilerVersion', 'v4.0')

    $referenceAssembies = @('System.dll')
    if (-not $NoConsole) {
        if ([System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.ManifestModule.Name -ieq 'Microsoft.PowerShell.ConsoleHost.dll' }) {
            $referenceAssembies += ([System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.ManifestModule.Name -ieq 'Microsoft.PowerShell.ConsoleHost.dll' } | Select-Object -First 1).Location
        }
    }
    $referenceAssembies += ([System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.ManifestModule.Name -ieq 'System.Management.Automation.dll' } | Select-Object -First 1).Location

    $n = New-Object System.Reflection.AssemblyName('System.Core, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
    [System.AppDomain]::CurrentDomain.Load($n) | Out-Null
    $referenceAssembies += ([System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.ManifestModule.Name -ieq 'System.Core.dll' } | Select-Object -First 1).Location

    if ($NoConsole) {
        $n = New-Object System.Reflection.AssemblyName('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
        [System.AppDomain]::CurrentDomain.Load($n) | Out-Null

        $n = New-Object System.Reflection.AssemblyName('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
        [System.AppDomain]::CurrentDomain.Load($n) | Out-Null

        $referenceAssembies += ([System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.ManifestModule.Name -ieq 'System.Windows.Forms.dll' } | Select-Object -First 1).Location
        $referenceAssembies += ([System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.ManifestModule.Name -ieq 'System.Drawing.dll' } | Select-Object -First 1).Location
    }

    $platform = 'anycpu'
    if ($x64 -and -not $x86) {
        $platform = 'x64'
    } elseif ($x86 -and -not $x64) {
        $platform = 'x86'
    }

    $codeProvider = (New-Object Microsoft.CSharp.CSharpCodeProvider($o))
    $compilerParameters = New-Object System.CodeDom.Compiler.CompilerParameters($referenceAssembies, $OutputFile)
    $compilerParameters.GenerateInMemory = $false
    $compilerParameters.GenerateExecutable = $true

    $iconFileParam = ''
    if (-not ([System.String]::IsNullOrEmpty($IconFile))) {
        $iconFileParam = "`"/win32icon:$($IconFile)`""
    }

    $manifestParam = ''
    if ($RequireAdmin -or $DPIAware -or $SupportOS -or $LongPaths) {
        $manifestParam = "`"/win32manifest:$($OutputFile+'.win32manifest')`""
        $win32manifest = "<?xml version=""1.0"" encoding=""UTF-8"" standalone=""yes""?>`r`n<assembly xmlns=""urn:schemas-microsoft-com:asm.v1"" manifestVersion=""1.0"">`r`n"
        if ($DPIAware -or $LongPaths) {
            $win32manifest += "<application xmlns=""urn:schemas-microsoft-com:asm.v3"">`r`n<windowsSettings>`r`n"
            if ($DPIAware) {
                $win32manifest += "<dpiAware xmlns=""http://schemas.microsoft.com/SMI/2005/WindowsSettings"">true</dpiAware>`r`n<dpiAwareness xmlns=""http://schemas.microsoft.com/SMI/2016/WindowsSettings"">PerMonitorV2</dpiAwareness>`r`n"
            }
            if ($LongPaths) {
                $win32manifest += "<longPathAware xmlns=""http://schemas.microsoft.com/SMI/2016/WindowsSettings"">true</longPathAware>`r`n"
            }
            $win32manifest += "</windowsSettings>`r`n</application>`r`n"
        }
        if ($RequireAdmin) {
            $win32manifest += "<trustInfo xmlns=""urn:schemas-microsoft-com:asm.v2"">`r`n<security>`r`n<requestedPrivileges xmlns=""urn:schemas-microsoft-com:asm.v3"">`r`n<requestedExecutionLevel level=""requireAdministrator"" uiAccess=""false""/>`r`n</requestedPrivileges>`r`n</security>`r`n</trustInfo>`r`n"
        }
        if ($SupportOS) {
            $win32manifest += "<compatibility xmlns=""urn:schemas-microsoft-com:compatibility.v1"">`r`n<application>`r`n<supportedOS Id=""{8e0f7a12-bfb3-4fe8-b9a5-48fd50a15a9a}""/>`r`n<supportedOS Id=""{1f676c76-80e1-4239-95bb-83d0f6d0da78}""/>`r`n<supportedOS Id=""{4a2f28e3-53b9-4441-ba9c-d69d4a4a6e38}""/>`r`n<supportedOS Id=""{35138b9a-5d96-4fbd-8e2d-a2440225f93a}""/>`r`n<supportedOS Id=""{e2011457-1546-43c5-a5fe-008deee3d3f0}""/>`r`n</application>`r`n</compatibility>`r`n"
        }
        $win32manifest += '</assembly>'
        $win32manifest | Set-Content ($OutputFile + '.win32manifest') -Encoding UTF8
    }

    if (-not $Virtualize) {
        $compilerParameters.CompilerOptions = "/platform:$($platform) /target:$( if ($NoConsole -or $ConHost) { 'winexe' } else { 'exe' }) $($iconFileParam) $($manifestParam)"
    } else {
        Write-Output 'Application virtualization is activated, forcing x86 platform.'
        $compilerParameters.CompilerOptions = "/platform:x86 /target:$( if ($NoConsole -or $ConHost) { 'winexe' } else { 'exe' } ) /nowin32manifest $($iconFileParam)"
    }

    $compilerParameters.IncludeDebugInformation = $prepareDebug

    if ($prepareDebug) {
        $compilerParameters.TempFiles.KeepFiles = $true
    }

    Write-Output "Reading input file $InputFile"
    [void]$compilerParameters.EmbeddedResources.Add($InputFile)

    $mainCsPath = Join-Path -Path $PSScriptRoot 'main.cs'
    $programFrame = Get-Content -Path $mainCsPath -Raw -Encoding UTF8
    if ($lcid) {
        $programFrame = $programFrame -replace "{{lcid}}", $lcid
    }

    $compilerDefinitions = @('NoConsole', 'CredentialGUI', 'MTA', 'STA', 'NoVisualStyles', 'WinFormsDPIAware', 'Title', 'NoError', 'NoOutput', 'ConHost', 'UnicodeEncoding', 'ExitOnCancel', 'lcid')
    $parameterDefinitions = ""
    $constants = @()
    foreach ($param in $compilerDefinitions) {
        if (Get-Variable -Name $param -ValueOnly) {
            $parameterDefinitions += " /define:$param"
            $constants += $param
        }
    }

    $programFrame = $programFrame -replace "{{Title}}", $Title
    $programFrame = $programFrame -replace "{{Product}}", $Product
    $programFrame = $programFrame -replace "{{Copyright}}", $Copyright
    $programFrame = $programFrame -replace "{{Trademark}}", $Trademark
    $programFrame = $programFrame -replace "{{Description}}", $Description
    $programFrame = $programFrame -replace "{{Company}}", $Company

    $programFrame = $programFrame -replace "{{Culture}}", $culture
    $programFrame = $programFrame -replace "{{FileName}}", [System.IO.Path]::GetFileName($InputFile)
    $programFrame = $programFrame -replace "{{Version}}", $Version

    if ($WinFormsDPIAware) {
        $ConfigFileForEXE3 = "<?xml version=""1.0"" encoding=""utf-8"" ?>`r`n<configuration><startup><supportedRuntime version=""v4.0"" sku="".NETFramework,Version=v4.7"" /></startup>"
    }
    else {
        $ConfigFileForEXE3 = "<?xml version=""1.0"" encoding=""utf-8"" ?>`r`n<configuration><startup><supportedRuntime version=""v4.0"" sku="".NETFramework,Version=v4.0"" /></startup>"
    }
    if ($LongPaths) {
        $ConfigFileForEXE3 += '<runtime><AppContextSwitchOverrides value="Switch.System.IO.UseLegacyPathHandling=false;Switch.System.IO.BlockLongPaths=false" /></runtime>'
    }
    if ($WinFormsDPIAware) {
        $ConfigFileForEXE3 += '<System.Windows.Forms.ApplicationConfigurationSection><add key="DpiAwareness" value="PerMonitorV2" /></System.Windows.Forms.ApplicationConfigurationSection>'
    }
    $ConfigFileForEXE3 += '</configuration>'

    $baseCsPath = Join-Path -Path $PSScriptRoot 'base.csproj'
    $csProjFile = Get-Content -Path $baseCsPath -Raw -Encoding UTF8

    Write-Output "Compiling file...`n"
    if ($Core) {
        $outputDirectory = [System.IO.Path]::GetDirectoryName($OutputFile)
        $outputFileName = [System.IO.Path]::GetFileNameWithoutExtension($OutputFile)
        $programFrame = $programFrame -replace "{{ResourcePrefix}}", "$outputFileName."
        $programFrame = Remove-EmptyPlaceholders -Content $programFrame
        New-Item -Path $outputDirectory -ItemType Directory -Force | Out-Null
        $scriptFilePath = [System.IO.Path]::Combine($outputDirectory, [System.IO.Path]::GetFileName($InputFile))
        if (-not (Test-Path -Path $scriptFilePath)) {
            Copy-Item -Path $InputFile -Destination $scriptFilePath -Force
        } else {
            Write-Output "Input file already exists in output directory, skipping copy."
        }
        $scriptCsPath = [System.IO.Path]::Combine($outputDirectory, "$($outputFileName).cs")
        $programFrame | Set-Content -Path $scriptCsPath -Encoding UTF8
        $csProjPath = [System.IO.Path]::Combine($outputDirectory, "$($outputFileName).csproj")

        $runtimeIdentifier = 'win-x64'
        if ($TargetOS -eq 'Windows') {
            if ($x64) {
                $runtimeIdentifier = 'win-x64'
            } elseif ($x86) {
                $runtimeIdentifier = 'win-x86'
            } elseif ($ARM) {
                $runtimeIdentifier = 'win-arm64'
            }
        } elseif ($TargetOS -eq 'Linux') {
            if ($ARM) {
                $runtimeIdentifier = 'linux-arm64'
            } else {
                $runtimeIdentifier = 'linux-x64'
            }
        } elseif ($TargetOS -eq 'MacOS') {
            if ($ARM) {
                $runtimeIdentifier = 'osx-arm64'
            } else {
                $runtimeIdentifier = 'osx-x64'
            }
        }
        $csProjFile = $csProjFile -replace "{{InputFile}}", ([System.IO.Path]::GetFileName($InputFile))
        $csProjFile = $csProjFile -replace "{{RuntimeIdentifier}}", $runtimeIdentifier
        $csProjFile = $csProjFile -replace "{{TargetFramework}}", $TargetFramework
        $csProjFile = $csProjFile -replace "{{PowerShellVersion}}", $PowerShellVersion
        $csProjFile = $csProjFile -replace "{{SelfContained}}", $SelfContained
        $csProjFile = $csProjFile -replace "{{UseWindowsForms}}", ($NoConsole -or $CredentialGUI)
        $csProjFile = $csProjFile -replace "{{DefineConstants}}", $constants -join ';'
        if ($NoConsole) {
            $csProjFile = $csProjFile -replace "{{OutputType}}", 'WinExe'
            $csProjFile = $csProjFile -replace "{{TargetOS}}", '-windows'
        } else {
            $csProjFile = $csProjFile -replace "{{OutputType}}", 'Exe'
        }
        $csProjFile = Remove-EmptyPlaceholders -Content $csProjFile
        $csProjFile | Set-Content -Path $csProjPath -Encoding UTF8

        $outputDirectory = Join-Path -Path $outputDirectory -ChildPath 'Release'
        dotnet publish $csProjPath -c Release -o $outputDirectory
        if ($LASTEXITCODE -ne 0) {
            throw "dotnet build failed with exit code $LASTEXITCODE"
        }
        Remove-Item -Path $csProjPath -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $scriptCsPath -Force -ErrorAction SilentlyContinue
    } else {
        $programFrame = Remove-EmptyPlaceholders -Content $programFrame
        $compilerParameters.CompilerOptions += $parameterDefinitions
        $cr = $codeProvider.CompileAssemblyFromSource($compilerParameters, $programFrame)
        if ($cr.Errors.Count -gt 0) {
            if (Test-Path -LiteralPath $OutputFile) {
                Remove-Item -LiteralPath $OutputFile -Verbose:$false
            }
            Write-Error -ErrorAction Continue 'Could not create the PowerShell .exe file because of compilation errors. Use -verbose parameter to see details.'
            $cr.Errors | ForEach-Object { Write-Verbose $_ }
        } else {
            if (Test-Path -LiteralPath $OutputFile) {
                Write-Output "Output file $OutputFile written"

                if ($prepareDebug) {
                    $cr.TempFiles | Where-Object { $_ -ilike '*.cs' } | Select-Object -First 1 | ForEach-Object {
                        $dstSrc = ([System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($OutputFile), [System.IO.Path]::GetFileNameWithoutExtension($OutputFile) + '.cs'))
                        Write-Output "Source file name for debug copied: $($dstSrc)"
                        Copy-Item -Path $_ -Destination $dstSrc -Force
                    }
                    $cr.TempFiles | Remove-Item -Verbose:$false -Force -ErrorAction SilentlyContinue
                }
                if ($ConfigFile) {
                    $ConfigFileForEXE3 | Set-Content ($OutputFile + '.config') -Encoding UTF8
                    Write-Output 'Config file for EXE created'
                }
            } else {
                Write-Error -ErrorAction 'Continue' "Output file $OutputFile not written"
            }
        }
    }

    if ($RequireAdmin -or $DPIAware -or $SupportOS -or $LongPaths) {
        if (Test-Path -LiteralPath $($OutputFile + '.win32manifest')) {
            Remove-Item -LiteralPath $($OutputFile + '.win32manifest') -Verbose:$false
        }
    }
}

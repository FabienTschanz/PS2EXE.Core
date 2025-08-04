# Markus Scholtes 2017
# Create examples for PS2EXE

$scriptPath = Split-Path $Script:MyInvocation.MyCommand.Path -Parent
Get-ChildItem -Path "$scriptPath\*.ps1" | ForEach-Object {
    Invoke-PS2EXE "$($_.Fullname)" "$($_.Fullname -replace '.ps1','.exe')" -Verbose
    Invoke-PS2EXE "$($_.Fullname)" "$($_.Fullname -replace '.ps1','-GUI.exe')" -Verbose -noConsole
}

Remove-Item "$scriptPath\BuildExamples*.exe*"
Remove-Item "$scriptPath\Progress.exe*"
Remove-Item "$scriptPath\ScreenBuffer-GUI.exe*"

$null = Read-Host 'Press enter to exit'

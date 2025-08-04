# Markus Scholtes, 2020
# Execute parameters and pipeline as powershell commands

if ($Args) {
    # arguments found, arguments are commands, pipeline elements are input
    $command = $Args -join ' '
    foreach ($item in $input) {
        # build string out of pipeline (if any)
        if ($pipeline) {
            $pipeline = "$pipeline,`"$item`""
        } else {
            $pipeline = "`"$item`""
        }
    }
    if ($pipeline) {
        $command = "$pipeline|$command"
    }
} else {
    # no arguments passed, pipeline elements are commands
    foreach ($item in $input) {
        # build string out of pipeline (if any)
        if ($command) {
            $command = "$command;$item"
        } else {
            $command = $item
        }
    }
}

# execute the passed commands
if ($command) {
    Invoke-Expression $command | Out-String
} else {
    Write-Output 'Pass PowerShell commands as parameters or in pipeline'
}

# Example script for screen operations

function Get-CharFromConsolePosition {
    param(
        [Parameter(Mandatory = $true)]
        [int]$X,

        [Parameter(Mandatory = $true)]
        [int]$Y
    )

    # function to get the character of a position in the console buffer
    $rect = New-Object System.Management.Automation.Host.Rectangle $X, $Y, $X, $Y
    $Host.UI.RawUI.GetBufferContents($rect)[0, 0]
}

# fill block with a character
$bufferCell = New-Object System.Management.Automation.Host.BufferCell 'O', 'White', 'Red', 'Complete'

# Complete - The character occupies one BufferCell structure.
# Leading - The character occupies two BufferCell structures, with this cell being the leading cell (UNICODE)
# Trailing - The character occupies two BufferCell structures, with this cell being the trailing cell  (UNICODE)
$source = New-Object System.Management.Automation.Host.Rectangle 10, 10, 29, 29

$Host.UI.RawUI.SetBufferContents($source, $bufferCell)

# read block into buffer
$screenBuffer = New-Object -TypeName 'System.Management.Automation.Host.BufferCell[,]' -ArgumentList ($source.Bottom - $source.Top + 1), ($source.Right - $source.Left + 1)
$screenBuffer = $Host.UI.RawUI.GetBufferContents($source)

# modify block in buffer
$maxDimension = [Math]::Min(($source.Bottom - $source.Top + 1), ($source.Right - $source.Left + 1))
for ($counter = 0; $counter -lt $maxDimension; $counter++) {
    $screenBuffer[$counter, $counter] = New-Object System.Management.Automation.Host.BufferCell 'X', 'White', 'Red', 'Complete'
    $screenBuffer[($maxDimension - $counter - 1), $counter] = New-Object System.Management.Automation.Host.BufferCell 'X', 'White', 'Red', 'Complete'
}

# write back buffer to screen
$Host.UI.RawUI.SetBufferContents((New-Object System.Management.Automation.Host.Coordinates $source.Left, $source.Top), $screenBuffer)

# move block
# define fill character for source range
$bufferCell.Character = '-'
$bufferCell.ForegroundColor = $Host.UI.RawUI.ForegroundColor
$bufferCell.BackgroundColor = $Host.UI.RawUI.BackgroundColor
# define clipping area (a ten character wide border)
$clip = New-Object System.Management.Automation.Host.Rectangle 10, 10, ($Host.UI.RawUI.WindowSize.Width - 10), ($Host.UI.RawUI.WindowSize.Height - 10)

# repeat ten times
for ($i = 1; $i -le 10; $i++) {
    for ($x = $source.Left + 1; $x -le ($Host.UI.RawUI.WindowSize.Width - $source.Right + $source.Left); $x++) {
        $destination = New-Object System.Management.Automation.Host.Coordinates $x, 10
        $Host.UI.RawUI.ScrollBufferContents($source, $destination, $clip, $bufferCell)
        $source.Right++
        $source.Left++
    }

    for ($y = $source.Top + 1; $y -le ($Host.UI.RawUI.WindowSize.Height - $source.Bottom + $source.Top); $y++) {
        $destination = New-Object System.Management.Automation.Host.Coordinates $source.Left, $y
        $Host.UI.RawUI.ScrollBufferContents($source, $destination, $clip, $bufferCell)
        $source.Bottom++
        $source.Top++
    }

    for ($x = $source.Left - 1; $x -ge 10; $x--) {
        $destination = New-Object System.Management.Automation.Host.Coordinates $x, $source.Top
        $Host.UI.RawUI.ScrollBufferContents($source, $destination, $clip, $bufferCell)
        $source.Right--
        $source.Left--
    }

    for ($y = $source.Top - 1; $y -ge 10; $y--) {
        $destination = New-Object System.Management.Automation.Host.Coordinates $source.Left, $y
        $Host.UI.RawUI.ScrollBufferContents($source, $destination, $clip, $bufferCell)
        $source.Bottom--
        $source.Top--
    }
}

# get character from screen
'Character at position (10/10): '
Get-CharFromConsolePosition 10 10

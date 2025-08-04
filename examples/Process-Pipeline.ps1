# Example script to process pipeline

# Type of pipeline object gets lost for compiled scripts, pipeline objects are always strings

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [AllowEmptyString()]
    $Pipeline
)
begin {
    'Reading pipeline as array of strings'
    $counter = 0
}
process {
    if ($null -eq $Pipeline) {
        Write-Output 'No element found in the pipeline'
    } else {
        $counter++
        Write-Output "$counter`: $Pipeline"
    }
}

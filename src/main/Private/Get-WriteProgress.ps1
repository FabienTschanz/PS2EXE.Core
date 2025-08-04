<#
.SYNOPSIS
    Returns the content for the write progress placeholder.

.DESCRIPTION
    This function returns the content of the write progress placeholder.

.EXAMPLE
    Get-WriteProgress

.OUTPUTS
    System.String
#>
function Get-WriteProgress {
    [CmdletBinding()]
    [OutputType([System.String])]
    param()

    @"
if (pf == null)
            {
                if (record.RecordType == ProgressRecordType.Completed) return;
                pf = new Progress_Form(rawUI.WindowTitle, ProgressForegroundColor);
                pf.Show();
            }
            pf.Update(record);
            if (record.RecordType == ProgressRecordType.Completed)
            {
                if (pf.GetCount() == 0) pf = null;
            }
"@
}

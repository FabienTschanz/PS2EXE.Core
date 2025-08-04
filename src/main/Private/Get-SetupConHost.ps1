<#
.SYNOPSIS
    Returns the content for the setup conhost placeholder.

.DESCRIPTION
    This function returns the content of the setup conhost placeholder.

.EXAMPLE
    Get-SetupConHost

.OUTPUTS
    System.String
#>
function Get-SetupConHost {
    [CmdletBinding()]
    [OutputType([System.String])]
    param()

    @"
// before this command no console should be attached or allocation fails
            if (!AllocConsole()) { Console.Error.WriteLine("Creation of console failed!"); }

            // connect STDIN
            Console.SetIn(new System.IO.StreamReader(Console.OpenStandardInput()));

            // connect STDOUT
            System.IO.StreamWriter streamWriter = new System.IO.StreamWriter(Console.OpenStandardOutput());
            streamWriter.AutoFlush = true;
            Console.SetOut(streamWriter);

            // connect STDERR
            System.IO.StreamWriter errorWriter = new System.IO.StreamWriter(Console.OpenStandardOutput());
            errorWriter.AutoFlush = true;
            Console.SetError(errorWriter);
"@
}

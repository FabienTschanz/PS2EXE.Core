<#
.SYNOPSIS
    Returns the content for the Prompt For Credential1 placeholder.

.DESCRIPTION
    This function returns the content of the Prompt For Credential1 placeholder.

.PARAMETER NoConsole
    If the -NoConsole switch was specified for Invoke-PS2EXE.

.PARAMETER CredentialGUI
    If the -CredentialGUI switch was specified for Invoke-PS2EXE.

.EXAMPLE
    Get-PromptForCredential1 -NoConsole

.OUTPUTS
    System.String
#>
function Get-PromptForCredential1 {
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter()]
        [switch]
        $NoConsole,

        [Parameter()]
        [switch]
        $CredentialGUI
    )

    if ($NoConsole -or $CredentialGUI) {
        "Credential_Form.User_Pwd cred = Credential_Form.PromptForPassword(caption, message, targetName, userName, allowedCredentialTypes, options);
            if (cred != null)
            {
                System.Security.SecureString x = new System.Security.SecureString();
                foreach (char c in cred.Password.ToCharArray())
                    x.AppendChar(c);

                return new PSCredential(cred.User, x);
            }
            return null;"
    } else {
        @"
            if (!string.IsNullOrEmpty(caption)) WriteLine(caption);
            WriteLine(message);

            string un;
            if ((string.IsNullOrEmpty(userName)) || ((options & PSCredentialUIOptions.ReadOnlyUserName) == 0))
            {
                Write("User name: ");
                un = ReadLine();
            }
            else
            {
                Write("User name: ");
                if (!string.IsNullOrEmpty(targetName)) Write(targetName + "\\");
                WriteLine(userName);
                un = userName;
            }
            SecureString pwd;
            Write("Password: ");
            pwd = ReadLineAsSecureString();

            if (string.IsNullOrEmpty(un)) un = "<NOUSER>";
            if (!string.IsNullOrEmpty(targetName))
            {
                if (un.IndexOf('\\') < 0)
                    un = targetName + "\\" + un;
            }

            PSCredential c2 = new PSCredential(un, pwd);
            return c2;
"@
    }
}

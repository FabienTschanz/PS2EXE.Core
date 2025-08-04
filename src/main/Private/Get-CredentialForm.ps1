<#
.SYNOPSIS
    Returns the content for the credential form placeholder.

.DESCRIPTION
    This function returns the content of the credential form placeholder.

.EXAMPLE
    Get-CredentialForm

.OUTPUTS
    System.String
#>
function Get-CredentialForm {
    [CmdletBinding()]
    [OutputType([System.String])]
    param()

    return @"
    internal class Credential_Form
    {
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        private struct CREDUI_INFO
        {
            public int cbSize;
            public IntPtr hwndParent;
            public string pszMessageText;
            public string pszCaptionText;
            public IntPtr hbmBanner;
        }

        [Flags]
        enum CREDUI_FLAGS
        {
            INCORRECT_PASSWORD = 0x1,
            DO_NOT_PERSIST = 0x2,
            REQUEST_ADMINISTRATOR = 0x4,
            EXCLUDE_CERTIFICATES = 0x8,
            REQUIRE_CERTIFICATE = 0x10,
            SHOW_SAVE_CHECK_BOX = 0x40,
            ALWAYS_SHOW_UI = 0x80,
            REQUIRE_SMARTCARD = 0x100,
            PASSWORD_ONLY_OK = 0x200,
            VALIDATE_USERNAME = 0x400,
            COMPLETE_USERNAME = 0x800,
            PERSIST = 0x1000,
            SERVER_CREDENTIAL = 0x4000,
            EXPECT_CONFIRMATION = 0x20000,
            GENERIC_CREDENTIALS = 0x40000,
            USERNAME_TARGET_CREDENTIALS = 0x80000,
            KEEP_USERNAME = 0x100000,
        }

        public enum CredUI_ReturnCodes
        {
            NO_ERROR = 0,
            ERROR_CANCELLED = 1223,
            ERROR_NO_SUCH_LOGON_SESSION = 1312,
            ERROR_NOT_FOUND = 1168,
            ERROR_INVALID_ACCOUNT_NAME = 1315,
            ERROR_INSUFFICIENT_BUFFER = 122,
            ERROR_INVALID_PARAMETER = 87,
            ERROR_INVALID_FLAGS = 1004,
        }

        [DllImport("credui", CharSet = CharSet.Unicode)]
        private static extern CredUI_ReturnCodes CredUIPromptForCredentials(ref CREDUI_INFO credinfo,
            string targetName,
            IntPtr reserved1,
            int iError,
            StringBuilder userName,
            int maxUserName,
            StringBuilder password,
            int maxPassword,
            [MarshalAs(UnmanagedType.Bool)] ref bool pfSave,
            CREDUI_FLAGS flags);

        public class User_Pwd
        {
            public string User = string.Empty;
            public string Password = string.Empty;
            public string Domain = string.Empty;
        }

        internal static User_Pwd PromptForPassword(string caption, string message, string target, string user, PSCredentialTypes credTypes, PSCredentialUIOptions options)
        {
            // Initialize flags and variables
            StringBuilder userPassword = new StringBuilder("", 128), userID = new StringBuilder(user, 128);
            CREDUI_INFO credUI = new CREDUI_INFO();
            if (!string.IsNullOrEmpty(message)) credUI.pszMessageText = message;
            if (!string.IsNullOrEmpty(caption)) credUI.pszCaptionText = caption;
            credUI.cbSize = Marshal.SizeOf(credUI);
            bool save = false;

            CREDUI_FLAGS flags = CREDUI_FLAGS.DO_NOT_PERSIST;
            if ((credTypes & PSCredentialTypes.Generic) == PSCredentialTypes.Generic)
            {
                flags |= CREDUI_FLAGS.GENERIC_CREDENTIALS;
                if ((options & PSCredentialUIOptions.AlwaysPrompt) == PSCredentialUIOptions.AlwaysPrompt)
                {
                    flags |= CREDUI_FLAGS.ALWAYS_SHOW_UI;
                }
            }

            // Ask the user for the password, graphical prompt
            CredUI_ReturnCodes returnCode = CredUIPromptForCredentials(ref credUI, target, IntPtr.Zero, 0, userID, 128, userPassword, 128, ref save, flags);

            if (returnCode == CredUI_ReturnCodes.NO_ERROR)
            {
                User_Pwd ret = new User_Pwd();
                ret.User = userID.ToString();
                ret.Password = userPassword.ToString();
                ret.Domain = "";
                return ret;
            }

            return null;
        }
    }

"@
}

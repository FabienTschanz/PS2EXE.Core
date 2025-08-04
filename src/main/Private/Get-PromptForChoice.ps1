<#
.SYNOPSIS
    Returns the content for the Prompt For Choice placeholder.

.DESCRIPTION
    This function returns the content of the Prompt For Choice placeholder.

.PARAMETER NoConsole
    If the -NoConsole switch was specified for Invoke-PS2EXE.

.EXAMPLE
    Get-PromptForChoice -NoConsole

.OUTPUTS
    System.String
#>
function Get-PromptForChoice {
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter()]
        [switch]
        $NoConsole
    )

    if ($NoConsole) {
        "int iReturn = Choice_Box.Show(choices, defaultChoice, caption, message);
            if (iReturn == -1) { iReturn = defaultChoice; }
            return iReturn;"
    } else {
        @"
if (!string.IsNullOrEmpty(caption)) WriteLine(caption);
            WriteLine(message);
            do {
                int idx = 0;
                SortedList<string, int> res = new SortedList<string, int>();
                string defkey = "";
                foreach (ChoiceDescription cd in choices)
                {
                    string lkey = cd.Label.Substring(0, 1), ltext = cd.Label;
                    int pos = cd.Label.IndexOf('&');
                    if (pos > -1)
                    {
                        lkey = cd.Label.Substring(pos + 1, 1).ToUpper();
                        if (pos > 0)
                            ltext = cd.Label.Substring(0, pos) + cd.Label.Substring(pos + 1);
                        else
                            ltext = cd.Label.Substring(1);
                    }
                    res.Add(lkey.ToLower(), idx);

                    if (idx > 0) Write("  ");
                    if (idx == defaultChoice)
                    {
                        Write(VerboseForegroundColor, rawUI.BackgroundColor, string.Format("[{0}] {1}", lkey, ltext));
                        defkey = lkey;
                    }
                    else
                        Write(rawUI.ForegroundColor, rawUI.BackgroundColor, string.Format("[{0}] {1}", lkey, ltext));
                    idx++;
                }
                Write(rawUI.ForegroundColor, rawUI.BackgroundColor, string.Format("  [?] Help (default is \"{0}\"): ", defkey));

                string inpkey = "";
                try
                {
                    inpkey = Console.ReadLine().ToLower();
                    if (res.ContainsKey(inpkey)) return res[inpkey];
                    if (string.IsNullOrEmpty(inpkey)) return defaultChoice;
                }
                catch { }
                if (inpkey == "?")
                {
                    foreach (ChoiceDescription cd in choices)
                    {
                        string lkey = cd.Label.Substring(0, 1);
                        int pos = cd.Label.IndexOf('&');
                        if (pos > -1) lkey = cd.Label.Substring(pos + 1, 1).ToUpper();
                        if (!string.IsNullOrEmpty(cd.HelpMessage))
                            WriteLine(rawUI.ForegroundColor, rawUI.BackgroundColor, string.Format("{0} - {1}", lkey, cd.HelpMessage));
                        else
                            WriteLine(rawUI.ForegroundColor, rawUI.BackgroundColor, string.Format("{0} -", lkey));
                    }
                }
            } while (true);
"@
    }
}

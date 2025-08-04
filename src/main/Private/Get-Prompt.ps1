<#
.SYNOPSIS
    Returns the content for the prompt placeholder.

.DESCRIPTION
    This function returns the content of the prompt placeholder.

.PARAMETER NoConsole
    If the -NoConsole switch was specified for Invoke-PS2EXE.

.EXAMPLE
    Get-Prompt -NoConsole

.OUTPUTS
    System.String
#>
function Get-Prompt {
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter()]
        [switch]
        $NoConsole
    )

    @"
        $(if (-not $NoConsole) {"
            if (!string.IsNullOrEmpty(caption)) WriteLine(caption);
            if (!string.IsNullOrEmpty(message)) WriteLine(message);"
        } else { '
            if ((!string.IsNullOrEmpty(caption)) || (!string.IsNullOrEmpty(message)))
            { string sTitel = System.AppDomain.CurrentDomain.FriendlyName, sMeldung = "";

                if (!string.IsNullOrEmpty(caption)) sTitel = caption;
                if (!string.IsNullOrEmpty(message)) sMeldung = message;
                MessageBox.Show(sMeldung, sTitel);
            }

            // Labeltext für Input_Box zurücksetzen
            ib_message = "";'
        })
            Dictionary<string, PSObject> ret = new Dictionary<string, PSObject>();
            foreach (FieldDescription cd in descriptions)
            {
                Type t = null;
                if (string.IsNullOrEmpty(cd.ParameterAssemblyFullName))
                    t = typeof(string);
                else
                    t = Type.GetType(cd.ParameterAssemblyFullName);

                if (t.IsArray)
                {
                    Type elementType = t.GetElementType();
                    Type genericListType = Type.GetType("System.Collections.Generic.List"+((char)0x60).ToString()+"1");
                    genericListType = genericListType.MakeGenericType(new Type[] { elementType });
                    ConstructorInfo constructor = genericListType.GetConstructor(BindingFlags.CreateInstance | BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null);
                    object resultList = constructor.Invoke(null);

                    int index = 0;
                    string data = "";
                    do
                    {
                        try
                        {
                        $(if (-not $NoConsole) {'
                            if (!string.IsNullOrEmpty(cd.Name)) Write(string.Format("{0}[{1}]: ", cd.Name, index));'
                        } else { '
                            if (!string.IsNullOrEmpty(cd.Name)) ib_message = string.Format("{0}[{1}]: ", cd.Name, index);'
                        })
                            data = ReadLine();
                            if (string.IsNullOrEmpty(data))
                                break;

                            object o = System.Convert.ChangeType(data, elementType);
                            genericListType.InvokeMember("Add", BindingFlags.InvokeMethod | BindingFlags.Public | BindingFlags.Instance, null, resultList, new object[] { o });
                        }
                        catch (Exception e)
                        {
                            throw;
                        }
                        index++;
                    } while (true);

                    System.Array retArray = (System.Array )genericListType.InvokeMember("ToArray", BindingFlags.InvokeMethod | BindingFlags.Public | BindingFlags.Instance, null, resultList, null);
                    ret.Add(cd.Name, new PSObject(retArray));
                }
                else
                {
                    object o = null;
                    string l = null;
                    try
                    {
                        if (t != typeof(System.Security.SecureString))
                        {
                            if (t != typeof(System.Management.Automation.PSCredential))
                            {
                            $(if (-not $NoConsole) { '
                                if (!string.IsNullOrEmpty(cd.Name)) Write(cd.Name);
                                if (!string.IsNullOrEmpty(cd.HelpMessage)) Write(" (Type !? for help.)");
                                if ((!string.IsNullOrEmpty(cd.Name)) || (!string.IsNullOrEmpty(cd.HelpMessage))) Write(": ");'
                            } else {'
                                if (!string.IsNullOrEmpty(cd.Name)) ib_message = string.Format("{0}: ", cd.Name);
                                if (!string.IsNullOrEmpty(cd.HelpMessage)) ib_message += "\n(Type !? for help.)";'
                            })
                                do {
                                    l = ReadLine();
                                    if (l == "!?")
                                        WriteLine(cd.HelpMessage);
                                    else
                                    {
                                        if (string.IsNullOrEmpty(l)) o = cd.DefaultValue;
                                        if (o == null)
                                        {
                                            try {
                                                o = System.Convert.ChangeType(l, t);
                                            }
                                            catch {
                                                Write("Wrong format, please repeat input: ");
                                                l = "!?";
                                            }
                                        }
                                    }
                                } while (l == "!?");
                            }
                            else
                            {
                                PSCredential pscred = PromptForCredential("", "", "", "");
                                o = pscred;
                            }
                        }
                        else
                        {
                            $(if (-not $NoConsole) { '
                            if (!string.IsNullOrEmpty(cd.Name)) Write(string.Format("{0}: ", cd.Name));'
                            } else { '
                            if (!string.IsNullOrEmpty(cd.Name)) ib_message = string.Format("{0}: ", cd.Name);'
                            })

                            SecureString pwd;
                            pwd = ReadLineAsSecureString();
                            o = pwd;
                        }

                        ret.Add(cd.Name, new PSObject(o));
                    }
                    catch (Exception e)
                    {
                        throw;
                    }
                }
            }
        $(if ($NoConsole) { '
            // Labeltext für Input_Box zurücksetzen
            ib_message = "";'
        })
            return ret;
"@
}

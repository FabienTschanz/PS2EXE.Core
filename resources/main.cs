// Simple PowerShell host created by Ingo Karstein (http://blog.karstein-consulting.com)
// Reworked and GUI support by Markus Scholtes
// Updated for PowerShell Core by Fabien Tschanz

using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Globalization;
using System.Management.Automation.Host;
using System.Security;
using System.Reflection;
using System.Runtime.InteropServices;
{{usingWinForms}}{{usingVersioning}}
[assembly:AssemblyTitle("{{Title}}")]
[assembly:AssemblyProduct("{{Product}}")]
[assembly:AssemblyCopyright("{{Copyright}}")]
[assembly:AssemblyTrademark("{{Trademark}}")]
{{AssemblyVersion}}
// not displayed in details tab of properties dialog, but embedded to file
[assembly:AssemblyDescription("{{Description}}")]
[assembly:AssemblyCompany("{{Company}}")]
{{TargetFramework}}
namespace ModuleNameSpace
{
{{CredentialForm}}
    public class MainModuleRawUI : PSHostRawUserInterface
    {
{{StoreConsoleColors}}
        {{GUITitle}}
        {{ConsoleSetup}}

        public override ConsoleColor BackgroundColor
        {
            get
            {
                {{GetConsoleBackground}}
            }
            set
            {
                {{SetConsoleBackground}}
            }
        }

        public override System.Management.Automation.Host.Size BufferSize
        {
            get
            {
                {{GetBufferSize}}
            }
            set
            {
                {{SetBufferSize}}
            }
        }

        public override Coordinates CursorPosition
        {
            get
            {
                {{GetCursorPosition}}
            }
            set
            {
                {{SetCursorPosition}}
            }
        }

        public override int CursorSize
        {
            get
            {
                {{GetCursorSize}}
            }
            set
            {
                {{SetCursorSize}}
            }
        }
{{InvisibleForm}}
        public override void FlushInputBuffer()
        {
            {{FlushInputBuffer}}
        }

        public override ConsoleColor ForegroundColor
        {
            get
            {
                {{GetForegroundColor}}
            }
            set
            {
                {{SetForegroundColor}}
            }
        }

        public override BufferCell[,] GetBufferContents(System.Management.Automation.Host.Rectangle rectangle)
        {
            {{BufferContent}}
        }

        public override bool KeyAvailable
        {
            get
            {
                {{GetKeyAvailable}}
            }
        }

        public override System.Management.Automation.Host.Size MaxPhysicalWindowSize
        {
            get
            {
                {{GetMaxPhysicalWindowSize}}
            }
        }

        public override System.Management.Automation.Host.Size MaxWindowSize
        {
            get
            {
                {{GetMaxWindowSize}}
            }
        }

        public override KeyInfo ReadKey(ReadKeyOptions options)
        {
            {{ReadKey}}
        }

        public override void ScrollBufferContents(System.Management.Automation.Host.Rectangle source, Coordinates destination, System.Management.Automation.Host.Rectangle clip, BufferCell fill)
        {
            // no destination block clipping implemented
            {{ScrollBufferContents}}
        }

        public override void SetBufferContents(System.Management.Automation.Host.Rectangle rectangle, BufferCell fill)
        {
            {{SetBufferContents1}}
        }

        public override void SetBufferContents(Coordinates origin, BufferCell[,] contents)
        {
            {{SetBufferContents2}}
        }

        public override Coordinates WindowPosition
        {
            get
            {
                Coordinates s = new Coordinates();
                {{GetWindowPosition}}

                return s;
            }
            set
            {
                {{SetWindowPosition}}
            }
        }

        public override System.Management.Automation.Host.Size WindowSize
        {
            get
            {
                System.Management.Automation.Host.Size s = new System.Management.Automation.Host.Size();
                {{GetWindowSize}}
                return s;
            }
            set
            {
                {{SetWindowSize}}
            }
        }

        public override string WindowTitle
        {
            get
            {
                {{GetWindowTitle}}
            }
            set
            {
                {{SetWindowTitle}}
            }
        }
    }
    {{DialogBoxes}}
    public class MainModuleUI : PSHostUserInterface
    {
        private MainModuleRawUI rawUI = null;

        public ConsoleColor ErrorForegroundColor = ConsoleColor.Red;
        public ConsoleColor ErrorBackgroundColor = ConsoleColor.Black;

        public ConsoleColor WarningForegroundColor = ConsoleColor.Yellow;
        public ConsoleColor WarningBackgroundColor = ConsoleColor.Black;

        public ConsoleColor DebugForegroundColor = ConsoleColor.Yellow;
        public ConsoleColor DebugBackgroundColor = ConsoleColor.Black;

        public ConsoleColor VerboseForegroundColor = ConsoleColor.Yellow;
        public ConsoleColor VerboseBackgroundColor = ConsoleColor.Black;

        public ConsoleColor ProgressForegroundColor = {{ProgressForegroundColor}};
        public ConsoleColor ProgressBackgroundColor = ConsoleColor.DarkCyan;

        public MainModuleUI() : base()
        {
            rawUI = new MainModuleRawUI();
            {{baseColorSetup}}
        }

        public override Dictionary<string, PSObject> Prompt(string caption, string message, System.Collections.ObjectModel.Collection<FieldDescription> descriptions)
        {
            {{Prompt}}
        }

        public override int PromptForChoice(string caption, string message, System.Collections.ObjectModel.Collection<ChoiceDescription> choices, int defaultChoice)
        {
            {{PromptForChoice}}
        }

        public override PSCredential PromptForCredential(string caption, string message, string userName, string targetName, PSCredentialTypes allowedCredentialTypes, PSCredentialUIOptions options)
        {
            {{PromptForCredential1}}
        }

        public override PSCredential PromptForCredential(string caption, string message, string userName, string targetName)
        {
            {{PromptForCredential2}}
        }

        public override PSHostRawUserInterface RawUI
        {
            get
            {
                return rawUI;
            }
        }
{{MessageBoxMessage}}
        public override string ReadLine()
        {
            {{ReadLine}}
                {{ReadLineExit}}
        }

        private System.Security.SecureString getPassword()
        {
            System.Security.SecureString pwd = new System.Security.SecureString();
            while (true)
            {
                ConsoleKeyInfo i = Console.ReadKey(true);
                if (i.Key == ConsoleKey.Enter)
                {
                    Console.WriteLine();
                    break;
                }
                else if (i.Key == ConsoleKey.Backspace)
                {
                    if (pwd.Length > 0)
                    {
                        pwd.RemoveAt(pwd.Length - 1);
                        Console.Write("\b \b");
                    }
                }
                else if (i.KeyChar != '\u0000')
                {
                    pwd.AppendChar(i.KeyChar);
                    Console.Write("*");
                }
            }
            return pwd;
        }

        public override System.Security.SecureString ReadLineAsSecureString()
        {
            System.Security.SecureString secstr = new System.Security.SecureString();
            {{GetPassword}}
            return secstr;
        }

        // called by Write-Host
        public override void Write(ConsoleColor foregroundColor, ConsoleColor backgroundColor, string value)
        {
            {{Write1}}
        }

        public override void Write(string value)
        {
            {{Write2}}
        }

        // called by Write-Debug
        public override void WriteDebugLine(string message)
        {
            {{WriteDebugLine}}
        }

        // called by Write-Error
        public override void WriteErrorLine(string value)
        {
            {{WriteErrorLine}}
        }

        public override void WriteLine()
        {
            {{WriteLine1}}
        }

        public override void WriteLine(ConsoleColor foregroundColor, ConsoleColor backgroundColor, string value)
        {
            {{WriteLine2}}
        }

        {{WriteLineInternal}}

        // called by Write-Output
        public override void WriteLine(string value)
        {
            {{WriteLine3}}
        }

        {{ProgressForm}}

        public override void WriteProgress(long sourceId, ProgressRecord record)
        {
            {{WriteProgress}}
        }

        // called by Write-Verbose
        public override void WriteVerboseLine(string message)
        {
            {{WriteVerboseLine}}
        }

        // called by Write-Warning
        public override void WriteWarningLine(string message)
        {
            {{WriteWarningLine}}
        }
    }

    public class MainModule : PSHost
    {
        private MainAppInterface parent;
        private MainModuleUI ui = null;

        private CultureInfo originalCultureInfo = System.Threading.Thread.CurrentThread.CurrentCulture;

        private CultureInfo originalUICultureInfo = System.Threading.Thread.CurrentThread.CurrentUICulture;

        private Guid myId = Guid.NewGuid();

        public MainModule(MainAppInterface app, MainModuleUI ui)
        {
            this.parent = app;
            this.ui = ui;
        }

        public class ConsoleColorProxy
        {
            private MainModuleUI _ui;

            public ConsoleColorProxy(MainModuleUI ui)
            {
                if (ui == null) throw new ArgumentNullException("ui");
                _ui = ui;
            }

            public ConsoleColor ErrorForegroundColor
            {
                get
                { return _ui.ErrorForegroundColor; }
                set
                { _ui.ErrorForegroundColor = value; }
            }

            public ConsoleColor ErrorBackgroundColor
            {
                get
                { return _ui.ErrorBackgroundColor; }
                set
                { _ui.ErrorBackgroundColor = value; }
            }

            public ConsoleColor WarningForegroundColor
            {
                get
                { return _ui.WarningForegroundColor; }
                set
                { _ui.WarningForegroundColor = value; }
            }

            public ConsoleColor WarningBackgroundColor
            {
                get
                { return _ui.WarningBackgroundColor; }
                set
                { _ui.WarningBackgroundColor = value; }
            }

            public ConsoleColor DebugForegroundColor
            {
                get
                { return _ui.DebugForegroundColor; }
                set
                { _ui.DebugForegroundColor = value; }
            }

            public ConsoleColor DebugBackgroundColor
            {
                get
                { return _ui.DebugBackgroundColor; }
                set
                { _ui.DebugBackgroundColor = value; }
            }

            public ConsoleColor VerboseForegroundColor
            {
                get
                { return _ui.VerboseForegroundColor; }
                set
                { _ui.VerboseForegroundColor = value; }
            }

            public ConsoleColor VerboseBackgroundColor
            {
                get
                { return _ui.VerboseBackgroundColor; }
                set
                { _ui.VerboseBackgroundColor = value; }
            }

            public ConsoleColor ProgressForegroundColor
            {
                get
                { return _ui.ProgressForegroundColor; }
                set
                { _ui.ProgressForegroundColor = value; }
            }

            public ConsoleColor ProgressBackgroundColor
            {
                get
                { return _ui.ProgressBackgroundColor; }
                set
                { _ui.ProgressBackgroundColor = value; }
            }
        }

        public override PSObject PrivateData
        {
            get
            {
                if (ui == null) return null;
                return _consoleColorProxy ?? (_consoleColorProxy = PSObject.AsPSObject(new ConsoleColorProxy(ui)));
            }
        }

        private PSObject _consoleColorProxy;

        public override System.Globalization.CultureInfo CurrentCulture
        {
            get
            {
                return this.originalCultureInfo;
            }
        }

        public override System.Globalization.CultureInfo CurrentUICulture
        {
            get
            {
                return this.originalUICultureInfo;
            }
        }

        public override Guid InstanceId
        {
            get
            {
                return this.myId;
            }
        }

        public override string Name
        {
            get
            {
                return "PSRunspace-Host";
            }
        }

        public override PSHostUserInterface UI
        {
            get
            {
                return ui;
            }
        }

        public override Version Version
        {
            get
            {
                return new Version(0, 5, 0, 32);
            }
        }

        public override void EnterNestedPrompt()
        {
        }

        public override void ExitNestedPrompt()
        {
        }

        public override void NotifyBeginApplication()
        {
            return;
        }

        public override void NotifyEndApplication()
        {
            return;
        }

        public override void SetShouldExit(int exitCode)
        {
            this.parent.ShouldExit = true;
            this.parent.ExitCode = exitCode;
        }
    }

    public interface MainAppInterface
    {
        bool ShouldExit { get; set; }
        int ExitCode { get; set; }
    }

    public class MainApp : MainAppInterface
    {
        private bool shouldExit;

        private int exitCode;

        public bool ShouldExit
        {
            get { return this.shouldExit; }
            set { this.shouldExit = value; }
        }

        public int ExitCode
        {
            get { return this.exitCode; }
            set { this.exitCode = value; }
        }

        {{AllocConsole}}

        {{ApartmentState}}
        public static int Main(string[] args)
        {
            {{SetupConHost}}
            {{OutputEncoding}}

            {{Culture}}

            {{VisualStyles}}
            MainApp me = new MainApp();

            bool paramWait = false;
            string extractFN = string.Empty;

            MainModuleUI ui = new MainModuleUI();
            MainModule host = new MainModule(me, ui);
            System.Threading.ManualResetEvent mre = new System.Threading.ManualResetEvent(false);

            AppDomain.CurrentDomain.UnhandledException += new UnhandledExceptionEventHandler(CurrentDomain_UnhandledException);

            try
            {
                using (Runspace myRunSpace = RunspaceFactory.CreateRunspace(host))
                {
                    {{RunspaceApartmentState}}
                    myRunSpace.Open();

                    using (PowerShell posh = PowerShell.Create())
                    {
                        {{CancelKeyPress}}
                        posh.Runspace = myRunSpace;
                        posh.Streams.Error.DataAdded += new EventHandler<DataAddedEventArgs>(delegate(object sender, DataAddedEventArgs e)
                        {
                            ui.WriteErrorLine(((PSDataCollection<ErrorRecord>)sender)[e.Index].Exception.Message);
                        });

                        PSDataCollection<string> colInput = new PSDataCollection<string>();
                        if (Console.IsInputRedirected)
                        { // read standard input
                            string sItem = "";
                            while ((sItem = Console.ReadLine()) != null)
                            { // add to powershell pipeline
                                colInput.Add(sItem);
                            }
                        }
                        colInput.Complete();

                        PSDataCollection<PSObject> colOutput = new PSDataCollection<PSObject>();
                        colOutput.DataAdded += new EventHandler<DataAddedEventArgs>(delegate(object sender, DataAddedEventArgs e)
                        {
                            ui.WriteLine(((PSDataCollection<PSObject>)sender)[e.Index].ToString());
                        });

                        int separator = 0;
                        int idx = 0;
                        bool bHelp = false;
                        string sHelp = "";
                        foreach (string s in args)
                        {
                            if (string.Compare(s, "-wait", true) == 0)
                                paramWait = true;
                            else if (s.StartsWith("-extract", StringComparison.InvariantCultureIgnoreCase))
                            {
                                string[] s1 = s.Split(new string[] { ":" }, 2, StringSplitOptions.RemoveEmptyEntries);
                                if (s1.Length != 2)
                                {
                                    {{ExtractNotification}}
                                    return 1;
                                }
                                extractFN = s1[1].Trim(new char[] { '\"' });
                            }
                            else if (string.Compare(s, "-end", true) == 0)
                            {
                                separator = idx + 1;
                                break;
                            }
                            else if (string.Compare(s, "-?", true) == 0)
                            {
                                bHelp = true;
                            }
                            else if (bHelp)
                            {
                                if ((string.Compare(s, "-detailed", true) == 0) || (string.Compare(s, "-examples", true) == 0) || (string.Compare(s, "-full", true) == 0))
                                {
                                    sHelp = s;
                                }
                            }
                            else if (string.Compare(s, "-debug", true) == 0)
                            {
                                System.Diagnostics.Debugger.Launch();
                                break;
                            }
                            idx++;
                        }

                        Assembly executingAssembly = Assembly.GetExecutingAssembly();
                using (System.IO.Stream scriptstream = executingAssembly.GetManifestResourceStream("{{ResourcePrefix}}" + "{{FileName}}"))
                        {
                            using (System.IO.StreamReader scriptreader = new System.IO.StreamReader(scriptstream, System.Text.Encoding.UTF8))
                            {
                                string script = scriptreader.ReadToEnd();

                                if (!string.IsNullOrEmpty(extractFN))
                                {
                                    System.IO.File.WriteAllText(extractFN, script);
                                    return 0;
                                }

                                if (bHelp)
                                { // help selected
                                    posh.AddScript("function " + System.AppDomain.CurrentDomain.FriendlyName + "{" + script + "}; Get-Help " + System.AppDomain.CurrentDomain.FriendlyName + " " + sHelp + " | Out-String");
                                } else { // execution selected
                                    posh.AddScript(script);
                                }
                            }
                        }

                        if (!bHelp)
                        { // only if no help selected
                            // parse parameters
                            string argbuffer = null;
                            // regex for named parameters
                            System.Text.RegularExpressions.Regex regex = new System.Text.RegularExpressions.Regex(@"^-([^: ]+)[ :]?([^:]*)$");

                            for (int i = separator; i < args.Length; i++)
                            {
                                System.Text.RegularExpressions.Match match = regex.Match(args[i]);
                                double dummy;

                                if ((match.Success && match.Groups.Count == 3) && (!Double.TryParse(args[i], out dummy)))
                                { // parameter in powershell style, means named parameter found
                                    if (argbuffer != null) // already a named parameter in buffer, then flush it
                                        posh.AddParameter(argbuffer);

                                    if (match.Groups[2].Value.Trim() == "")
                                    { // store named parameter in buffer
                                        argbuffer = match.Groups[1].Value;
                                    }
                                    else
                                        // caution: when called in powershell $true gets converted, when called in cmd.exe not
                                        if ((match.Groups[2].Value == "$true") || (match.Groups[2].Value.ToUpper() == "\x24TRUE"))
                                        { // switch found
                                            posh.AddParameter(match.Groups[1].Value, true);
                                            argbuffer = null;
                                        }
                                        else
                                            // caution: when called in powershell $false gets converted, when called in cmd.exe not
                                            if ((match.Groups[2].Value == "$false") || (match.Groups[2].Value.ToUpper() == "\x24"+"FALSE"))
                                            { // switch found
                                                posh.AddParameter(match.Groups[1].Value, false);
                                                argbuffer = null;
                                            }
                                            else
                                            { // named parameter with value found
                                                posh.AddParameter(match.Groups[1].Value, match.Groups[2].Value);
                                                argbuffer = null;
                                            }
                                }
                                else
                                { // unnamed parameter found
                                    if (argbuffer != null)
                                    { // already a named parameter in buffer, so this is the value
                                        posh.AddParameter(argbuffer, args[i]);
                                        argbuffer = null;
                                    }
                                    else
                                    { // position parameter found
                                        posh.AddArgument(args[i]);
                                    }
                                }
                            }

                            if (argbuffer != null) posh.AddParameter(argbuffer); // flush parameter buffer...

                            // convert output to strings
                            posh.AddCommand("Out-String");
                            // with a single string per line
                            posh.AddParameter("Stream");
                        }

                        posh.BeginInvoke<string, PSObject>(colInput, colOutput, null, new AsyncCallback(delegate(IAsyncResult ar)
                        {
                            if (ar.IsCompleted)
                                mre.Set();
                        }), null);

                        while (!me.ShouldExit && !mre.WaitOne(100))
                        { };

                        posh.Stop();

                        if (posh.InvocationStateInfo.State == PSInvocationState.Failed)
                            ui.WriteErrorLine(posh.InvocationStateInfo.Reason.Message);
                    }

                    myRunSpace.Close();
                }
            }
            catch (Exception ex)
            {
                {{CatchException}}
            }

            if (paramWait)
            {
                {{WaitForExit}}
            }
            return me.ExitCode;
        }

        static void CurrentDomain_UnhandledException(object sender, UnhandledExceptionEventArgs e)
        {
            throw new Exception("Unhandled exception in " + System.AppDomain.CurrentDomain.FriendlyName);
        }
    }
}

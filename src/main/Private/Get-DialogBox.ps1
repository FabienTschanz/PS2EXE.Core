<#
.SYNOPSIS
    Returns the content for the dialog box placeholder.

.DESCRIPTION
    This function returns the content of the dialog box placeholder.

.PARAMETER NoVisualStyles
    If the -NoVisualStyles switch was specified for Invoke-PS2EXE.

.EXAMPLE
    Get-DialogBox -NoVisualStyles

.OUTPUTS
    System.String
#>
function Get-DialogBox {
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter()]
        [switch]
        $NoVisualStyles
    )

    @"

    public class Input_Box
    {
        [DllImport("user32.dll", CharSet = CharSet.Unicode, CallingConvention = CallingConvention.Cdecl)]
        private static extern IntPtr MB_GetString(uint strId);

        public static DialogResult Show(string strTitle, string strPrompt, ref string strVal, bool blSecure)
        {
            // Generate controls
            Form form = new Form();
            form.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            form.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            Label label = new Label();
            TextBox textBox = new TextBox();
            Button buttonOk = new Button();
            Button buttonCancel = new Button();

            // Sizes and positions are defined according to the label
            // This control has to be finished first
            if (string.IsNullOrEmpty(strPrompt))
            {
                if (blSecure)
                    label.Text = "Secure input:   ";
                else
                    label.Text = "Input:          ";
            }
            else
                label.Text = strPrompt;
            label.Location = new Point(9, 19);
            label.MaximumSize = new System.Drawing.Size(System.Windows.Forms.Screen.FromControl(form).Bounds.Width*5/8 - 18, 0);
            label.AutoSize = true;
            // Size of the label is defined not before Add()
            form.Controls.Add(label);

            // Generate textbox
            if (blSecure) textBox.UseSystemPasswordChar = true;
            textBox.Text = strVal;
            textBox.SetBounds(12, label.Bottom, label.Right - 12, 20);

            // Generate buttons
            // get localized "OK"-string
            string sTextOK = Marshal.PtrToStringUni(MB_GetString(0));
            if (string.IsNullOrEmpty(sTextOK))
                buttonOk.Text = "OK";
            else
                buttonOk.Text = sTextOK;

            // get localized "Cancel"-string
            string sTextCancel = Marshal.PtrToStringUni(MB_GetString(1));
            if (string.IsNullOrEmpty(sTextCancel))
                buttonCancel.Text = "Cancel";
            else
                buttonCancel.Text = sTextCancel;

            buttonOk.DialogResult = DialogResult.OK;
            buttonCancel.DialogResult = DialogResult.Cancel;
            buttonOk.SetBounds(System.Math.Max(12, label.Right - 158), label.Bottom + 36, 75, 23);
            buttonCancel.SetBounds(System.Math.Max(93, label.Right - 77), label.Bottom + 36, 75, 23);

            // Configure form
            form.Text = strTitle;
            form.ClientSize = new System.Drawing.Size(System.Math.Max(178, label.Right + 10), label.Bottom + 71);
            form.Controls.AddRange(new Control[] { textBox, buttonOk, buttonCancel });
            form.FormBorderStyle = FormBorderStyle.FixedDialog;
            form.StartPosition = FormStartPosition.CenterScreen;
            try {
                form.Icon = Icon.ExtractAssociatedIcon(Assembly.GetExecutingAssembly().Location);
            }
            catch
            { }
            form.MinimizeBox = false;
            form.MaximizeBox = false;
            form.AcceptButton = buttonOk;
            form.CancelButton = buttonCancel;

            // Show form and compute results
            DialogResult dialogResult = form.ShowDialog();
            strVal = textBox.Text;
            return dialogResult;
        }

        public static DialogResult Show(string strTitle, string strPrompt, ref string strVal)
        {
            return Show(strTitle, strPrompt, ref strVal, false);
        }
    }

    public class Choice_Box
    {
        public static int Show(System.Collections.ObjectModel.Collection<ChoiceDescription> arrChoice, int intDefault, string strTitle, string strPrompt)
        {
            // cancel if array is empty
            if (arrChoice == null) return -1;
            if (arrChoice.Count < 1) return -1;

            // Generate controls
            Form form = new Form();
            form.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            form.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            RadioButton[] aradioButton = new RadioButton[arrChoice.Count];
            ToolTip toolTip = new ToolTip();
            Button buttonOk = new Button();

            // Sizes and positions are defined according to the label
            // This control has to be finished first when a prompt is available
            int iPosY = 19, iMaxX = 0;
            if (!string.IsNullOrEmpty(strPrompt))
            {
                Label label = new Label();
                label.Text = strPrompt;
                label.Location = new Point(9, 19);
                label.MaximumSize = new System.Drawing.Size(System.Windows.Forms.Screen.FromControl(form).Bounds.Width*5/8 - 18, 0);
                label.AutoSize = true;
                // erst durch Add() wird die Größe des Labels ermittelt
                form.Controls.Add(label);
                iPosY = label.Bottom;
                iMaxX = label.Right;
            }

            // An den Radiobuttons orientieren sich die weiteren Größen und Positionen
            // Diese Controls also jetzt fertigstellen
            int Counter = 0;
            int tempWidth = System.Windows.Forms.Screen.FromControl(form).Bounds.Width*5/8 - 18;
            foreach (ChoiceDescription sAuswahl in arrChoice)
            {
                aradioButton[Counter] = new RadioButton();
                aradioButton[Counter].Text = sAuswahl.Label;
                if (Counter == intDefault)
                    aradioButton[Counter].Checked = true;
                aradioButton[Counter].Location = new Point(9, iPosY);
                aradioButton[Counter].AutoSize = true;
                // erst durch Add() wird die Größe des Labels ermittelt
                form.Controls.Add(aradioButton[Counter]);
                if (aradioButton[Counter].Width > tempWidth)
                { // radio field to wide for screen -> make two lines
                    int tempHeight = aradioButton[Counter].Height;
                    aradioButton[Counter].Height = tempHeight*(1 + (aradioButton[Counter].Width-1)/tempWidth);
                    aradioButton[Counter].Width = tempWidth;
                    aradioButton[Counter].AutoSize = false;
                }
                iPosY = aradioButton[Counter].Bottom;
                if (aradioButton[Counter].Right > iMaxX) { iMaxX = aradioButton[Counter].Right; }
                if (!string.IsNullOrEmpty(sAuswahl.HelpMessage))
                     toolTip.SetToolTip(aradioButton[Counter], sAuswahl.HelpMessage);
                Counter++;
            }

            // Tooltip auch anzeigen, wenn Parent-Fenster inaktiv ist
            toolTip.ShowAlways = true;

            // Button erzeugen
            buttonOk.Text = "OK";
            buttonOk.DialogResult = DialogResult.OK;
            buttonOk.SetBounds(System.Math.Max(12, iMaxX - 77), iPosY + 36, 75, 23);

            // configure form
            if (string.IsNullOrEmpty(strTitle))
                form.Text = System.AppDomain.CurrentDomain.FriendlyName;
            else
                form.Text = strTitle;
            form.ClientSize = new System.Drawing.Size(System.Math.Max(178, iMaxX + 10), iPosY + 71);
            form.Controls.Add(buttonOk);
            form.FormBorderStyle = FormBorderStyle.FixedDialog;
            form.StartPosition = FormStartPosition.CenterScreen;
            try {
                form.Icon = Icon.ExtractAssociatedIcon(Assembly.GetExecutingAssembly().Location);
            }
            catch
            { }
            form.MinimizeBox = false;
            form.MaximizeBox = false;
            form.AcceptButton = buttonOk;

            // show and compute form
            if (form.ShowDialog() == DialogResult.OK)
            { int iRueck = -1;
                for (Counter = 0; Counter < arrChoice.Count; Counter++)
                {
                    if (aradioButton[Counter].Checked == true)
                    { iRueck = Counter; }
                }
                return iRueck;
            }
            else
                return -1;
        }
    }

    public class ReadKey_Box
    {
        [DllImport("user32.dll")]
        public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpKeyState,
            [Out, MarshalAs(UnmanagedType.LPWStr, SizeConst = 64)] System.Text.StringBuilder pwszBuff,
            int cchBuff, uint wFlags);

        static string GetCharFromKeys(Keys keys, bool blShift, bool blAltGr)
        {
            System.Text.StringBuilder buffer = new System.Text.StringBuilder(64);
            byte[] keyboardState = new byte[256];
            if (blShift)
            { keyboardState[(int) Keys.ShiftKey] = 0xff; }
            if (blAltGr)
            { keyboardState[(int) Keys.ControlKey] = 0xff;
                keyboardState[(int) Keys.Menu] = 0xff;
            }
            if (ToUnicode((uint) keys, 0, keyboardState, buffer, 64, 0) >= 1)
                return buffer.ToString();
            else
                return "\0";
        }

        class Keyboard_Form : Form
        {
            public Keyboard_Form()
            {
                this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
                this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
                this.KeyDown += new KeyEventHandler(Keyboard_Form_KeyDown);
                this.KeyUp += new KeyEventHandler(Keyboard_Form_KeyUp);
            }

            // check for KeyDown or KeyUp?
            public bool checkKeyDown = true;
            // key code for pressed key
            public KeyInfo keyinfo;

            void Keyboard_Form_KeyDown(object sender, KeyEventArgs e)
            {
                if (checkKeyDown)
                { // store key info
                    keyinfo.VirtualKeyCode = e.KeyValue;
                    keyinfo.Character = GetCharFromKeys(e.KeyCode, e.Shift, e.Alt & e.Control)[0];
                    keyinfo.KeyDown = false;
                    keyinfo.ControlKeyState = 0;
                    if (e.Alt) { keyinfo.ControlKeyState = ControlKeyStates.LeftAltPressed | ControlKeyStates.RightAltPressed; }
                    if (e.Control)
                    { keyinfo.ControlKeyState |= ControlKeyStates.LeftCtrlPressed | ControlKeyStates.RightCtrlPressed;
                        if (!e.Alt)
                        { if (e.KeyValue > 64 && e.KeyValue < 96) keyinfo.Character = (char)(e.KeyValue - 64); }
                    }
                    if (e.Shift) { keyinfo.ControlKeyState |= ControlKeyStates.ShiftPressed; }
                    if ((e.Modifiers & System.Windows.Forms.Keys.CapsLock) > 0) { keyinfo.ControlKeyState |= ControlKeyStates.CapsLockOn; }
                    if ((e.Modifiers & System.Windows.Forms.Keys.NumLock) > 0) { keyinfo.ControlKeyState |= ControlKeyStates.NumLockOn; }
                    // and close the form
                    this.Close();
                }
            }

            void Keyboard_Form_KeyUp(object sender, KeyEventArgs e)
            {
                if (!checkKeyDown)
                { // store key info
                    keyinfo.VirtualKeyCode = e.KeyValue;
                    keyinfo.Character = GetCharFromKeys(e.KeyCode, e.Shift, e.Alt & e.Control)[0];
                    keyinfo.KeyDown = true;
                    keyinfo.ControlKeyState = 0;
                    if (e.Alt) { keyinfo.ControlKeyState = ControlKeyStates.LeftAltPressed | ControlKeyStates.RightAltPressed; }
                    if (e.Control)
                    { keyinfo.ControlKeyState |= ControlKeyStates.LeftCtrlPressed | ControlKeyStates.RightCtrlPressed;
                        if (!e.Alt)
                        { if (e.KeyValue > 64 && e.KeyValue < 96) keyinfo.Character = (char)(e.KeyValue - 64); }
                    }
                    if (e.Shift) { keyinfo.ControlKeyState |= ControlKeyStates.ShiftPressed; }
                    if ((e.Modifiers & System.Windows.Forms.Keys.CapsLock) > 0) { keyinfo.ControlKeyState |= ControlKeyStates.CapsLockOn; }
                    if ((e.Modifiers & System.Windows.Forms.Keys.NumLock) > 0) { keyinfo.ControlKeyState |= ControlKeyStates.NumLockOn; }
                    // and close the form
                    this.Close();
                }
            }
        }

        public static KeyInfo Show(string strTitle, string strPrompt, bool blIncludeKeyDown)
        {
            // Controls erzeugen
            Keyboard_Form form = new Keyboard_Form();
            Label label = new Label();

            // Am Label orientieren sich die Größen und Positionen
            // Dieses Control also zuerst fertigstellen
            if (string.IsNullOrEmpty(strPrompt))
            {
                    label.Text = "Press a key";
            }
            else
                label.Text = strPrompt;
            label.Location = new Point(9, 19);
            label.MaximumSize = new System.Drawing.Size(System.Windows.Forms.Screen.FromControl(form).Bounds.Width*5/8 - 18, 0);
            label.AutoSize = true;
            // erst durch Add() wird die Größe des Labels ermittelt
            form.Controls.Add(label);

            // configure form
            form.Text = strTitle;
            form.ClientSize = new System.Drawing.Size(System.Math.Max(178, label.Right + 10), label.Bottom + 55);
            form.FormBorderStyle = FormBorderStyle.FixedDialog;
            form.StartPosition = FormStartPosition.CenterScreen;
            try {
                form.Icon = Icon.ExtractAssociatedIcon(Assembly.GetExecutingAssembly().Location);
            }
            catch
            { }
            form.MinimizeBox = false;
            form.MaximizeBox = false;

            // show and compute form
            form.checkKeyDown = blIncludeKeyDown;
            form.ShowDialog();
            return form.keyinfo;
        }
    }

    public class Progress_Form : Form
    {
        private ConsoleColor ProgressBarColor = ConsoleColor.DarkCyan;
        private string WindowTitle = "";

    $(if (-not $NoVisualStyles) { "
        private System.Timers.Timer timer = new System.Timers.Timer();
        private int barNumber = -1;
        private int barValue = -1;
        private bool inTick = false;"
    })

        struct Progress_Data
        {
            internal Label lbActivity;
            internal Label lbStatus;
            internal ProgressBar objProgressBar;
            internal Label lbRemainingTime;
            internal Label lbOperation;
            internal int ActivityId;
            internal int ParentActivityId;
            internal int Depth;
        };

        private List<Progress_Data> progressDataList = new List<Progress_Data>();

        private Color DrawingColor(ConsoleColor color)
        {  // convert ConsoleColor to System.Drawing.Color
            switch (color)
            {
                case ConsoleColor.Black: return Color.Black;
                case ConsoleColor.Blue: return Color.Blue;
                case ConsoleColor.Cyan: return Color.Cyan;
                case ConsoleColor.DarkBlue: return ColorTranslator.FromHtml("#000080");
                case ConsoleColor.DarkGray: return ColorTranslator.FromHtml("#808080");
                case ConsoleColor.DarkGreen: return ColorTranslator.FromHtml("#008000");
                case ConsoleColor.DarkCyan: return ColorTranslator.FromHtml("#008080");
                case ConsoleColor.DarkMagenta: return ColorTranslator.FromHtml("#800080");
                case ConsoleColor.DarkRed: return ColorTranslator.FromHtml("#800000");
                case ConsoleColor.DarkYellow: return ColorTranslator.FromHtml("#808000");
                case ConsoleColor.Gray: return ColorTranslator.FromHtml("#C0C0C0");
                case ConsoleColor.Green: return ColorTranslator.FromHtml("#00FF00");
                case ConsoleColor.Magenta: return Color.Magenta;
                case ConsoleColor.Red: return Color.Red;
                case ConsoleColor.White: return Color.White;
                default: return Color.Yellow;
            }
        }

        public Progress_Form()
        {
            InitializeComponent();
        }

        public Progress_Form(ConsoleColor BarColor)
        {
            ProgressBarColor = BarColor;
            InitializeComponent();
        }

        public Progress_Form(string Title, ConsoleColor BarColor)
        {
            WindowTitle = Title;
            ProgressBarColor = BarColor;
            InitializeComponent();
        }

        private void InitializeComponent()
        {
            this.SuspendLayout();

            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;

            this.AutoScroll = true;
            this.Text = WindowTitle;
            this.Height = 147;
            this.Width = 800;
            this.BackColor = Color.White;
            this.FormBorderStyle = FormBorderStyle.FixedSingle;
            this.MinimizeBox = false;
            this.MaximizeBox = false;
            this.ControlBox = false;
            this.StartPosition = FormStartPosition.CenterScreen;

            this.ResumeLayout();
        $(if (-not $NoVisualStyles) { "
            timer.Elapsed += new System.Timers.ElapsedEventHandler(TimeTick);
            timer.Interval = 50; // milliseconds
            timer.AutoReset = true;
            timer.Start();"
        })
        }
    $(if (-not $NoVisualStyles) { "
        private void TimeTick(object source, System.Timers.ElapsedEventArgs e)
        { // worker function that is called by timer event

            if (inTick) return;
            inTick = true;
            if (barNumber >= 0)
            {
                if (barValue >= 0)
                {
                    progressDataList[barNumber].objProgressBar.Value = barValue;
                    barValue = -1;
                }
                progressDataList[barNumber].objProgressBar.Refresh();
            }
            inTick = false;
        }"
    })

        private void AddBar(ref Progress_Data pd, int position)
        {
            // Create Label
            pd.lbActivity = new Label();
            pd.lbActivity.Left = 5;
            pd.lbActivity.Top = 104*position + 10;
            pd.lbActivity.Width = 800 - 20;
            pd.lbActivity.Height = 16;
            pd.lbActivity.Font = new Font(pd.lbActivity.Font, FontStyle.Bold);
            pd.lbActivity.Text = "";
            // Add Label to Form
            this.Controls.Add(pd.lbActivity);

            // Create Label
            pd.lbStatus = new Label();
            pd.lbStatus.Left = 25;
            pd.lbStatus.Top = 104*position + 26;
            pd.lbStatus.Width = 800 - 40;
            pd.lbStatus.Height = 16;
            pd.lbStatus.Text = "";
            // Add Label to Form
            this.Controls.Add(pd.lbStatus);

            // Create ProgressBar
            pd.objProgressBar = new ProgressBar();
            pd.objProgressBar.Value = 0;
        $(if ($NoVisualStyles) { "
            pd.objProgressBar.Style = ProgressBarStyle.Continuous;"
        } else { "
            pd.objProgressBar.Style = ProgressBarStyle.Blocks;"
        })
            pd.objProgressBar.ForeColor = DrawingColor(ProgressBarColor);
            if (pd.Depth < 15)
            {
                pd.objProgressBar.Size = new System.Drawing.Size(800 - 60 - 30*pd.Depth, 20);
                pd.objProgressBar.Left = 25 + 30*pd.Depth;
            }
            else
            {
                pd.objProgressBar.Size = new System.Drawing.Size(800 - 60 - 450, 20);
                pd.objProgressBar.Left = 25 + 450;
            }
            pd.objProgressBar.Top = 104*position + 47;
            // Add ProgressBar to Form
            this.Controls.Add(pd.objProgressBar);

            // Create Label
            pd.lbRemainingTime = new Label();
            pd.lbRemainingTime.Left = 5;
            pd.lbRemainingTime.Top = 104*position + 72;
            pd.lbRemainingTime.Width = 800 - 20;
            pd.lbRemainingTime.Height = 16;
            pd.lbRemainingTime.Text = "";
            // Add Label to Form
            this.Controls.Add(pd.lbRemainingTime);

            // Create Label
            pd.lbOperation = new Label();
            pd.lbOperation.Left = 25;
            pd.lbOperation.Top = 104*position + 88;
            pd.lbOperation.Width = 800 - 40;
            pd.lbOperation.Height = 16;
            pd.lbOperation.Text = "";
            // Add Label to Form
            this.Controls.Add(pd.lbOperation);
        }

        public int GetCount()
        {
            return progressDataList.Count;
        }

        public void Update(ProgressRecord objRecord)
        {
            if (objRecord == null)
                return;

            int currentProgress = -1;
            for (int i = 0; i < progressDataList.Count; i++)
            {
                if (progressDataList[i].ActivityId == objRecord.ActivityId)
                { currentProgress = i;
                    break;
                }
            }

            if (objRecord.RecordType == ProgressRecordType.Completed)
            {
                if (currentProgress >= 0)
                {
                $(if (-not $NoVisualStyles) { "
                    if (barNumber == currentProgress) barNumber = -1;"
                })
                    this.Controls.Remove(progressDataList[currentProgress].lbActivity);
                    this.Controls.Remove(progressDataList[currentProgress].lbStatus);
                    this.Controls.Remove(progressDataList[currentProgress].objProgressBar);
                    this.Controls.Remove(progressDataList[currentProgress].lbRemainingTime);
                    this.Controls.Remove(progressDataList[currentProgress].lbOperation);

                    progressDataList[currentProgress].lbActivity.Dispose();
                    progressDataList[currentProgress].lbStatus.Dispose();
                    progressDataList[currentProgress].objProgressBar.Dispose();
                    progressDataList[currentProgress].lbRemainingTime.Dispose();
                    progressDataList[currentProgress].lbOperation.Dispose();

                    progressDataList.RemoveAt(currentProgress);
                }

                if (progressDataList.Count == 0)
                {
                $(if (-not $NoVisualStyles) { "
                    timer.Stop();
                    timer.Dispose();"
                })
                    this.Close();
                    return;
                }

                if (currentProgress < 0) return;

                for (int i = currentProgress; i < progressDataList.Count; i++)
                {
                    progressDataList[i].lbActivity.Top = 104*i + 10;
                    progressDataList[i].lbStatus.Top = 104*i + 26;
                    progressDataList[i].objProgressBar.Top = 104*i + 47;
                    progressDataList[i].lbRemainingTime.Top = 104*i + 72;
                    progressDataList[i].lbOperation.Top = 104*i + 88;
                }

                if (104*progressDataList.Count + 43 <= System.Windows.Forms.Screen.FromControl(this).Bounds.Height)
                {
                    this.Height = 104*progressDataList.Count + 43;
                    this.Location = new Point((System.Windows.Forms.Screen.FromControl(this).Bounds.Width - this.Width)/2, (System.Windows.Forms.Screen.FromControl(this).Bounds.Height - this.Height)/2);
                }
                else
                {
                    this.Height = System.Windows.Forms.Screen.FromControl(this).Bounds.Height;
                    this.Location = new Point((System.Windows.Forms.Screen.FromControl(this).Bounds.Width - this.Width)/2, 0);
                }

                return;
            }

            if (currentProgress < 0)
            {
                Progress_Data pd = new Progress_Data();
                pd.ActivityId = objRecord.ActivityId;
                pd.ParentActivityId = objRecord.ParentActivityId;
                pd.Depth = 0;

                int nextid = -1;
                int parentid = -1;
                if (pd.ParentActivityId >= 0)
                {
                    for (int i = 0; i < progressDataList.Count; i++)
                    {
                        if (progressDataList[i].ActivityId == pd.ParentActivityId)
                        { parentid = i;
                            break;
                        }
                    }
                }

                if (parentid >= 0)
                {
                    pd.Depth = progressDataList[parentid].Depth + 1;

                    for (int i = parentid + 1; i < progressDataList.Count; i++)
                    {
                        if ((progressDataList[i].Depth < pd.Depth) || ((progressDataList[i].Depth == pd.Depth) && (progressDataList[i].ParentActivityId != pd.ParentActivityId)))
                        { nextid = i;
                            break;
                        }
                    }
                }

                if (nextid == -1)
                {
                    AddBar(ref pd, progressDataList.Count);
                    currentProgress = progressDataList.Count;
                    progressDataList.Add(pd);
                }
                else
                {
                    AddBar(ref pd, nextid);
                    currentProgress = nextid;
                    progressDataList.Insert(nextid, pd);

                    for (int i = currentProgress+1; i < progressDataList.Count; i++)
                    {
                        progressDataList[i].lbActivity.Top = 104*i + 10;
                        progressDataList[i].lbStatus.Top = 104*i + 26;
                        progressDataList[i].objProgressBar.Top = 104*i + 47;
                        progressDataList[i].lbRemainingTime.Top = 104*i + 72;
                        progressDataList[i].lbOperation.Top = 104*i + 88;
                    }
                }
                if (104*progressDataList.Count + 43 <= System.Windows.Forms.Screen.FromControl(this).Bounds.Height)
                {
                    this.Height = 104*progressDataList.Count + 43;
                    this.Location = new Point((System.Windows.Forms.Screen.FromControl(this).Bounds.Width - this.Width)/2, (System.Windows.Forms.Screen.FromControl(this).Bounds.Height - this.Height)/2);
                }
                else
                {
                    this.Height = System.Windows.Forms.Screen.FromControl(this).Bounds.Height;
                    this.Location = new Point((System.Windows.Forms.Screen.FromControl(this).Bounds.Width - this.Width)/2, 0);
                }
            }

            if (!string.IsNullOrEmpty(objRecord.Activity))
                progressDataList[currentProgress].lbActivity.Text = objRecord.Activity;
            else
                progressDataList[currentProgress].lbActivity.Text = "";

            if (!string.IsNullOrEmpty(objRecord.StatusDescription))
                progressDataList[currentProgress].lbStatus.Text = objRecord.StatusDescription;
            else
                progressDataList[currentProgress].lbStatus.Text = "";

            if ((objRecord.PercentComplete >= 0) && (objRecord.PercentComplete <= 100))
            {
            $(if (-not $NoVisualStyles) { "
                if (objRecord.PercentComplete < 100)
                    progressDataList[currentProgress].objProgressBar.Value = objRecord.PercentComplete + 1;
                else
                    progressDataList[currentProgress].objProgressBar.Value = 99;
                progressDataList[currentProgress].objProgressBar.Visible = true;
                barNumber = currentProgress;
                barValue = objRecord.PercentComplete;"
            } else { "
                progressDataList[currentProgress].objProgressBar.Value = objRecord.PercentComplete;
                progressDataList[currentProgress].objProgressBar.Visible = true;"
            })
            }
            else
            { if (objRecord.PercentComplete > 100)
                {
                    progressDataList[currentProgress].objProgressBar.Value = 0;
                    progressDataList[currentProgress].objProgressBar.Visible = true;
                $(if (-not $NoVisualStyles) { "
                    barNumber = currentProgress;
                    barValue = 0;"
                })
                }
                else
                {
                    progressDataList[currentProgress].objProgressBar.Visible = false;
                $(if (-not $NoVisualStyles) { "
                    if (barNumber == currentProgress) barNumber = -1;"
                })
                }
            }

            if (objRecord.SecondsRemaining >= 0)
            {
                System.TimeSpan objTimeSpan = new System.TimeSpan(0, 0, objRecord.SecondsRemaining);
                progressDataList[currentProgress].lbRemainingTime.Text = "Remaining time: " + string.Format("{0:00}:{1:00}:{2:00}", (int)objTimeSpan.TotalHours, objTimeSpan.Minutes, objTimeSpan.Seconds);
            }
            else
                progressDataList[currentProgress].lbRemainingTime.Text = "";

            if (!string.IsNullOrEmpty(objRecord.CurrentOperation))
                progressDataList[currentProgress].lbOperation.Text = objRecord.CurrentOperation;
            else
                progressDataList[currentProgress].lbOperation.Text = "";

            Application.DoEvents();
        }
    }
"@
}

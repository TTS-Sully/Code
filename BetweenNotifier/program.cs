
using System;
using System.Drawing;
using System.Windows.Forms;

//LoginAcknowledge.exe --start=22:00 --end=06:00

namespace LoginAcknowledge
{
    internal static class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            // Configure default window (08:00–17:00 local time)
            var start = ParseTimeArg(args, "--start", new TimeSpan(8, 0, 0));
            var end   = ParseTimeArg(args, "--end",   new TimeSpan(17, 0, 0));

            var now = DateTime.Now.TimeOfDay;

            if (!IsWithinTimeWindow(now, start, end))
            {
                // Outside the window; simply exit.
                return;
            }

            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            // Show a blocking, topmost popup that must be acknowledged
            using (var form = new AckForm(
                title: "Important Notice",
                message: "Please acknowledge you have read and understand the policy.\r\n\r\nClick OK to continue."
            ))
            {
                form.ShowDialog(); // Modal; blocks until acknowledged
            }

            // Optionally: write a marker to a log file in LocalAppData
            // AcknowledgeLogger.Write("User acknowledged the notice at " + DateTime.Now);
        }

        /// <summary>
        /// Handles windows like 08:00–17:00 and cross-midnight windows like 22:00–06:00.
        /// </summary>
        static bool IsWithinTimeWindow(TimeSpan now, TimeSpan start, TimeSpan end)
        {
            if (start <= end)
                return now >= start && now <= end;   // normal same-day window
            else
                return now >= start || now <= end;   // crosses midnight
        }

        static TimeSpan ParseTimeArg(string[] args, string name, TimeSpan defaultVal)
        {
            foreach (var a in args)
            {
                if (a.StartsWith(name + "=", StringComparison.OrdinalIgnoreCase))
                {
                    var val = a.Substring(name.Length + 1);
                    if (TimeSpan.TryParse(val, out var ts))
                        return ts;
                }
            }
            return defaultVal;
        }
    }

    public class AckForm : Form
    {
        private bool _acknowledged;
        private readonly Button _okButton;
        private readonly Label _label;

        public AckForm(string title, string message)
        {
            Text = title;
            StartPosition = FormStartPosition.CenterScreen;
            FormBorderStyle = FormBorderStyle.FixedDialog;
            ControlBox = false;          // Hides the Close (X) button
            MaximizeBox = false;
            MinimizeBox = false;
            TopMost = true;              // Always on top
            ShowInTaskbar = false;
            Width = 520;
            Height = 240;

            _label = new Label
            {
                Dock = DockStyle.Top,
                Height = 140,
                TextAlign = ContentAlignment.MiddleCenter,
                Font = new Font(SystemFonts.MessageBoxFont.FontFamily, 10f, FontStyle.Regular),
                Text = message
            };

            _okButton = new Button
            {
                Text = "OK",
                Width = 110,
                Height = 36,
                Anchor = AnchorStyles.Bottom,
            };
            _okButton.Click += (s, e) => { _acknowledged = true; Close(); };

            Controls.Add(_label);
            Controls.Add(_okButton);

            // Position the OK button centered near the bottom
            Layout += (_, __) =>
            {
                _okButton.Left = (ClientSize.Width - _okButton.Width) / 2;
                _okButton.Top = ClientSize.Height - 70;
            };

            AcceptButton = _okButton; // Enter key triggers OK
        }

        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            base.OnFormClosing(e);

            // Block closing unless OK was clicked
            if (!_acknowledged)
            {
                e.Cancel = true;
            }
        }
    }

    // Optional: simple local logger
    public static class AcknowledgeLogger
    {
        public static void Write(string line)
        {
            try
            {
                var path = System.IO.Path.Combine(
                    Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                    "LoginAcknowledge", "ack.log");
                System.IO.Directory.CreateDirectory(System.IO.Path.GetDirectoryName(path)!);
                System.IO.File.AppendAllText(path, line + Environment.NewLine);
            }
            catch { /* swallow */ }
        }
    }
}

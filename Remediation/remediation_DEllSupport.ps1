##########################################################################################################################
### Tech Team Solutions Dell SupportAssist Remediation Script
### This script will uninstall Dell SupportAssist and remove the SARemediation folder if it exists.
### Last Updated 2026.07.24
### Written by ESS
##########################################################################################################################
$SAVer = Get-ChildItem `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" |
    Get-ItemProperty |
    Where-Object { $_.DisplayName -match "SupportAssist" }

foreach ($ver in $SAVer) {
    if ($ver.UninstallString) {
        if ($ver.UninstallString) {
            $exe = $ver.UninstallString.Split(' ')[0]
            $arg = ($ver.UninstallString.Substring($exe.Length)).Trim()
            Host.UI.WriteLine("Uninstalling SupportAssist version $($ver.DisplayVersion) using command: $exe $arg /quiet /norestart")
            Start-Process -FilePath $exe -ArgumentList "$arg /quiet /norestart" -Wait
        }
    }
}

if (Test-Path "C:\ProgramData\Dell\SARemediation"){
    Remove-Item "C:\ProgramData\Dell\SARemediation" -Recurse -Force
}
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\WPP"
New-Item -Path $regPath -Force -ErrorAction SilentlyContinue | Out-Null
New-ItemProperty -Path $regPath -Name "WindowsProtectedPrintMode" -Value 0 -PropertyType DWORD -Force | Out-Null
Restart-Service spooler
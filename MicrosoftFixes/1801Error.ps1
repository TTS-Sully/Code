Set-ExecutionPolicy Unrestricted
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module UEFIv2 -Force
Get-UEFISecureBootCerts db | Select-Object SignatureSubject
WinCsFlags.exe /apply --key "F33E0C8E002"
Start-ScheduledTask -TaskName "\Microsoft\Windows\PI\Secure-Boot-Update"
$taskName = "DisableProxyOnLogin"
$scriptPath = "c:\TTS\disable_proxy.ps1"

# Create the PowerShell script
$scriptContent = 'reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f'
Set-Content -Path $scriptPath -Value $scriptContent

# Create the scheduled task action
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""

# Create the trigger for user logon
$trigger = New-ScheduledTaskTrigger -AtLogOn

# Set the principal to run only for the specific user
$principal = New-ScheduledTaskPrincipal -UserId "MXL3112Y37\Manager" -LogonType Interactive -RunLevel Highest

# Register the task
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal
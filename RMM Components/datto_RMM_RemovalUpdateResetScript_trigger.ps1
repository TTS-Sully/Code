
##########################################################################################################################
### Tech Team Solutions Datto RMM Removal Registry Update Reset Script
### Last Updated 2026.01.22
### Written by ESS
##########################################################################################################################

$TTSPath = $env:SystemDrive + "\TTS"

# Create TTS Directory
if (!(Test-Path -Path $TTSPath)) {
    New-Item -ItemType Directory -Path $TTSPath | Out-Null
}

# Move Onsite Maintenance File attached to the job
Move-Item -Path datto_RMM_RemovalUpdateResetScript.ps1 -Destination "$TTSPath\datto_RMM_RemovalUpdateResetScript.ps1" -Force
Write-Host "File has been delivered..."

# Path to PowerShell script that will run at startup
$ScriptPath = "$TTSPath\datto_RMM_RemovalUpdateResetScript.ps1"
$TaskName = "EnableAutoUpdates_StartupOnce"

# Create task action
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""

# Trigger: Run at startup
$Trigger = New-ScheduledTaskTrigger -AtStartup

# Run as SYSTEM with highest privileges
$Principal = New-ScheduledTaskPrincipal
    -UserId "SYSTEM"
    -LogonType ServiceAccount
    -RunLevel Highest

# Settings
$Settings = New-ScheduledTaskSettingsSet
    -AllowStartIfOnBatteries
    -DontStopIfGoingOnBatteries
    -ExecutionTimeLimit (New-TimeSpan -Minutes 5)

# Register the task
Register-ScheduledTask -TaskName $TaskName
                       -Action $Action
                       -Trigger $Trigger
                       -Principal $Principal
                       -Settings $Settings
                       -Force

Write-Host "Startup task '$TaskName' created successfully."

$TaskName = "EnableAutoUpdates_StartupOnce"

# Ensure the AU key exists
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

if (-not (Test-Path $regPath)) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "AU" -Force | Out-Null
}

# Set NoAutoUpdate to 0 (enable automatic updates)
Set-ItemProperty -Path $regPath -Name "NoAutoUpdate" -Value 0 -Type DWord

# Self-delete the scheduled task after first run
$TaskName = "EnableAutoUpdates_StartupOnce"

try {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    Write-Output "Scheduled task '$TaskName' has been removed after execution."
} catch {
    Write-Output "Failed to remove scheduled task: $($_.Exception.Message)"
}

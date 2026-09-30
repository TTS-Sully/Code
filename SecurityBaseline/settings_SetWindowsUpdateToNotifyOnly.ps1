# Requires admin privileges
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

# Create the registry path if it doesn't exist
if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force
}

# Set the AUOptions value to 2 (Notify for download and notify for install)
Set-ItemProperty -Path $registryPath -Name "AUOptions" -Value 2

Write-Host "Windows Update settings updated: Notify for download and install."
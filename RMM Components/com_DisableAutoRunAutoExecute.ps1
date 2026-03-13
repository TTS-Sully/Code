##########################################################################################################################
### Tech Team Solutions - Disable Autoplay, AutoExecute, AutoRun for Removable Media
### Last Updated 2026.01.27
### Written by ESS
##########################################################################################################################

# Run PowerShell as Administrator

# Define registry paths
$explorerPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
# $autorunMapPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\IniFileMapping\Autorun.inf"

# Function to safely create a registry path if missing
function Ensure-RegistryPath {
    param (
        [string]$Path
    )
    if (-not (Test-Path $Path)) {
        Write-Host "Creating missing registry path: $Path"
        New-Item -Path $Path -Force | Out-Null
    }
}

# Ensure the required registry paths exist
Ensure-RegistryPath -Path $explorerPath
Ensure-RegistryPath -Path $autorunMapPath

# Disable AutoPlay
New-ItemProperty -Path $explorerPath -Name "NoAutoPlay" -Value 1 -PropertyType DWORD -Force

# Turn off AutoPlay for all drives (255 = disable all)
New-ItemProperty -Path $explorerPath -Name "NoDriveTypeAutoRun" -Value 255 -PropertyType DWORD -Force

# Disable AutoRun for all removable media
New-ItemProperty -Path $explorerPath -Name "AutorunDisabled" -Value 1 -PropertyType DWORD -Force

# Disable parsing of autorun.inf no longer needed in windows 11
# New-ItemProperty -Path $autorunMapPath -Name "(Default)" -Value "@SYS:DoesNotExist" -PropertyType String -Force

Write-Host "AutoRun and AutoPlay have been fully disabled with path safety checks." -ForegroundColor Green
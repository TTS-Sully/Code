##########################################################################################################################
### Tech Team Solutions NuGet, WinGet, PowerShell, and Windows Update for Powershell Installation Script
### Last Updated 2025.05.16
### Written by ESS
##########################################################################################################################

$FileSystemPath = [System.Environment]::GetEnvironmentVariable('SystemDrive')
$Date = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LogDirectoryPath = $FileSystemPath  + '\ProgramData\TTS'
# Set log file path with date to ensure uniqueness
$LogPath = $LogDirectoryPath + '\Maintenance_Log_' + $Date + '_Automation.txt'
$TTSPath = $FileSystemPath + '\TTS'

##########################################################################################################################
### Functions
##########################################################################################################################

function get-now {
    param ([string]$format = "yyyy-MM-dd_HH-mm-ss")
    return (Get-Date).ToString($format)
}

function Write-Log {
    param ([string]$Message)
    $timestamp = get-now
    "$timestamp $Message" | Out-File -FilePath $LogPath -Append
}

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -ErrorAction SilentlyContinue

##########################################################################################################################
### Install Microsoft NuGet
##########################################################################################################################

Write-Host "Installing NuGet and then the newest version of powershell."
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

##########################################################################################################################
### Install Microsoft Powershell
##########################################################################################################################

Install-Module -Name PowerShellGet -Force
Import-Module PackageManagement

##########################################################################################################################
### Install Microsoft WinGet
##########################################################################################################################

Write-Host "Installing Operation packages..."
Install-Module -Name Microsoft.WinGet.Client -RequiredVersion 0.2.1 -Force
Write-Host "WinGet installed"

##########################################################################################################################
### Install Microsoft Windows Update for PowerShell
##########################################################################################################################

Install-Module -Name PSWindowsUpdate -Repository PSGallery -Force
Import-Module PSWindowsUpdate
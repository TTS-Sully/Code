##########################################################################################################################
### Tech Team Solutions NuGet, WinGet, PowerShell, and Windows Update for Powershell Installation Script
### Last Updated 2025.05.16
### Written by ESS
##########################################################################################################################

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -ErrorAction SilentlyContinue


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

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

##########################################################################################################################
### Install Pending Reboot
##########################################################################################################################

Write-Host "Installing PendingReboot module..."
Install-Module -Name PendingReboot -Force -AllowClobber -Verbose:$false

##########################################################################################################################
### Install GroupPolicy
##########################################################################################################################

Import-Module GroupPolicy
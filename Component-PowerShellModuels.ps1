##########################################################################################################################
### Tech Team Solutions NuGet, WinGet, PowerShell, and Windows Update for Powershell Installation Script
### Last Updated 2025.05.16
### Written by ESS
##########################################################################################################################

Clear-Host
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -ErrorAction SilentlyContinue

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Register-PSRepository -Default

# Check if PSGallery is already registered
$source = Get-PackageSource -Name PSGallery -ErrorAction SilentlyContinue | Out-Null

if ($null -ne $source) {
    Write-Output "Module Repository 'PSGallery' exists."
} else {
    Write-Output "Module Repository 'PSGallery' does not exist. Registering now..."
    Register-PackageSource -Name PSGallery -Location "https://www.powershellgallery.com/api/v2" -ProviderName NuGet -Trusted -Force
}

##########################################################################################################################
### Install Microsoft NuGet
##########################################################################################################################

Write-Host "Installing NuGet and then the newest version of powershell."
#Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force 
Install-Module -Name NuGet -Force -Verbose:$false

##########################################################################################################################
### Install Microsoft Powershell
##########################################################################################################################

Install-Module -Name PowerShellGet -Force -AllowClobber -Verbose:$false

##########################################################################################################################
### Install Microsoft Windows Update for PowerShell
##########################################################################################################################

Install-Module -Name PSWindowsUpdate -Repository PSGallery -Force -AllowClobber -Verbose:$false

##########################################################################################################################
### Install Pending Reboot
##########################################################################################################################

Install-Module -Name PendingReboot -Force -AllowClobber -Verbose:$false
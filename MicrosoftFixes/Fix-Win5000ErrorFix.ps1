##########################################################################################################################
### Tech Team Solutions Windows 5000 Remove Fix
### Last Updated 2025.07.22
### Written by ESS
##########################################################################################################################

#Installs Windows Security and Resets the package
Get-AppxPackage *Microsoft.SecHealthUI* -AllUsers | Reset-AppxPackage

# Enables Windows Defender in local group policy
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Name DisableAntiSpyware -Value 0
Set-Service -Name WinDefend -StartupType Automatic

###########################################################################################################################
#Enable Memory Integrity
$path = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"

if (-not (Test-Path $path)) {
    New-Item -Path $path -Force | Out-Null
    Write-Output "Registry path created: $path"
} else {
    Write-Output "Registry path already exists: $path"
}

Set-ItemProperty -Path $path -Name Enabled -Value 1

###########################################################################################################################
# Enable Windows Defender PUA Protection
$path = "HKLM:\Software\Microsoft\Edge\SmartScreenPuaEnabled"

if (-not (Test-Path $path)) {
    New-Item -Path $path -Force | Out-Null
    Write-Output "Registry path created: $path"
} else {
    Write-Output "Registry path already exists: $path"
}

Set-ItemProperty -Path $path -Name "(Default)" -Value 1

###########################################################################################################################
# Enable Windows Defender App and Browser Control
# Enable SmartScreen for File Explorer (Check apps and files)
# This sets a local group policy equivalent to enable SmartScreen for checking apps and files.
$explorerPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
if (-not (Test-Path $explorerPolicyPath)) {
    New-Item -Path $explorerPolicyPath -Force | Out-Null
}
Set-ItemProperty -Path $explorerPolicyPath -Name "EnableSmartScreen" -Value 1 -Type DWord

# Enable SmartScreen for Microsoft Edge (optional)
$edgePolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
if (-not (Test-Path $edgePolicyPath)) {
    New-Item -Path $edgePolicyPath -Force | Out-Null
}
Set-ItemProperty -Path $edgePolicyPath -Name "SmartScreenEnabled" -Value 1 -Type DWord

#Turn on Blocking of potentially unwanted applications (PUA)
#New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine" -Force
#Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine" -Name "MpEnablePus" -Value 1 -Type DWord



##########################################################################################################################
### Tech Team Solutions Windows 5000 Remove Fix
### Last Updated 2025.07.22
### Written by ESS
##########################################################################################################################

#Installs Windows Security and Resets the package
Get-AppxPackage *Microsoft.SecHealthUI* -AllUsers | Reset-AppxPackage

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
# Loads the default user registry hive
reg load HKLM\DEFAULT c:\users\default\ntuser.dat

# Turn on app and browser control
reg add "HKLM\DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer" /v SmartScreenEnabled /t REG_DWORD /d 1 /f

# Unload the default user registry hive
reg unload HKLM\DEFAULT
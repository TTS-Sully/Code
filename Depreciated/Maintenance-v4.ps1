##########################################################################################################################
### Tech Team Solutions Deployable Maitenance Script
### Last Updated 2025.04.01
### Written by ESS
##########################################################################################################################
# Requires -RunAsAdministrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Script needs to be run as administrator."
    exit
}

#Set-ExecutionPolicy Unrestricted -Force -Scope Process
Write-Host "Starting Local Maintenance Script..."

# Set log file path with date to ensure uniqueness
$Date = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LogDirectoryPath = "C:\ProgramData\TTS"
$LogPath = $LogDirectoryPath + '\Maintenance_Log_' + $Date + '_Automation.txt'
$TTSPath = "C:\TTS"
# $DattoPackagesPath = "C:\ProgramData\CentraStage\Packages"

if (!(Test-Path -Path $LogDirectoryPath)) {
    New-Item -ItemType Directory -Path $LogDirectoryPath
}

# Function to write to log
function Write-Log {
    param ([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Out-File -FilePath $LogPath -Append
}

# Start logging
Write-Log "Maintenance Log Started at $Date"

# Check for Datto RMM environment variables
$DattoProfileDir = $env:CS_PROFILE_DIR
if ($DattoProfileDir) {
    Write-Log "Running under Datto RMM profile: $DattoProfileDir"
} else {
    Write-Log "No Datto RMM profile detected; running in standalone mode."
}

# Create TTS Directory
if (!(Test-Path -Path $TTSPath)) {
    New-Item -ItemType Directory -Path $TTSPath
}

##########################################################################################################################
# Pre Cleanup System Drive Disk Usage
##########################################################################################################################

$Volume = Get-Volume -DriveLetter C -ErrorAction SilentlyContinue
if ($Volume) {
    $TotalSpace = $Volume.Size
    $FreeSpace = $Volume.SizeRemaining
    $UsedSpace = $TotalSpace - $FreeSpace
    $UsedSpacePercent = [math]::Round(($UsedSpace / $TotalSpace) * 100, 2)
    Write-Log "C: drive usage: $UsedSpacePercent%"
} else {
    Write-Log "C: drive not found. Exiting script."
    exit
}

##########################################################################################################################
### Bloatware Removial List
##########################################################################################################################

Write-Log "Removing Unneeded Windows Preinstalled Apps"
Try {
    #Remove Windows Bloatware
    Get-AppxPackage *Microsoft.3dbuilder* | Remove-AppxPackage
    Get-AppxPackage *AdobeSystemsIncorporated.AdobePhotoshopExpress* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.WindowsAlarms* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.Asphalt8Airborne* | Remove-AppxPackage
    Get-AppxPackage *microsoft.windowscommunicationsapps* | Remove-AppxPackage
    Get-AppxPackage *king.com.CandyCrushSodaSaga* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.DrawboardPDF* | Remove-AppxPackage
    Get-AppxPackage *Facebook* | Remove-AppxPackage
    Get-AppxPackage *BethesdaSoftworks.FalloutShelter* | Remove-AppxPackage
    Get-AppxPackage *FarmVille2CountryEscape* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.WindowsFeedbackHub* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.GetHelp* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.Getstarted* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.ZuneMusic* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.WindowsMaps* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.Messaging* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.Wallet* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.MicrosoftSolitaireCollection* | Remove-AppxPackage
    Get-AppxPackage *Todos* | Remove-AppxPackage
    Get-AppxPackage *ConnectivityStore* | Remove-AppxPackage
    Get-AppxPackage *MinecraftUWP* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.OneConnect* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.BingFinance* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.ZuneVideo* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.BingNews* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.MicrosoftOfficeHub* | Remove-AppxPackage
    Get-AppxPackage *Netflix* | Remove-AppxPackage
    Get-AppxPackage *OneNote* | Remove-AppxPackage
    Get-AppxPackage *PandoraMediaInc* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.People* | Remove-AppxPackage
    Get-AppxPackage *CommsPhone* | Remove-AppxPackage
    Get-AppxPackage *windowsphone* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.Print3D* | Remove-AppxPackage
    Get-AppxPackage *flaregamesGmbH.RoyalRevolt2* | Remove-AppxPackage
    Get-AppxPackage *AutodeskSketchBook* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.SkypeApp* | Remove-AppxPackage
    Get-AppxPackage *bingsports* | Remove-AppxPackage
    Get-AppxPackage *Office.Sway* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.Getstarted* | Remove-AppxPackage
    Get-AppxPackage *Twitter* | Remove-AppxPackage
    Get-AppxPackage *Microsoft3DViewer* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.WindowsSoundRecorder* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.BingWeather* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.XboxApp* | Remove-AppxPackage
    Get-AppxPackage *XboxOneSmartGlass* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.XboxSpeechToTextOverlay* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.XboxIdentityProvider* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.XboxGameingOverlay* | Remove-AppxPackage
} catch {
    Write-Log "There was a problem removing preinstalled software"
}

##########################################################################################################################
### DISM Cleanup
##########################################################################################################################

# Import the DISM module
Import-Module Dism

# Rebuild the DISM image
try {
    # Perform the component cleanup and reset base
    $DismParams = @{
        Online = $true
        CleanupImage = "StartComponentCleanup"
        ResetBase = $true
    }

    $d1 = Dism @DismParams
    #$d1 = Start-Process -FilePath "Dism.exe " -ArgumentList "/Online /Cleanup-Image /StartComponentCleanup /ResetBase" -WindowStyle Hidden -PassThru | Out-Null
    Wait-Process -InputObject $d1
    Write-Log "DISM - ResetBase completed"
} catch {
    Write-Log "There was a problem with the DISM ResetBase command"
}

# clears out superseded updates
try {
    # Perform the component cleanup and remove superseded updates
    $DismParams = @{
        Online = $true
        CleanupImage = "SPSuperseded"
    }

    $d2 = Dism @DismParams
    Wait-Process -InputObject $d2
    Write-Log "DISM - Superseded completed"
} catch {
    Write-Log "There was a problem with the DISM Superseded command"
}

##########################################################################################################################
### Prep and Run Windows Update
##########################################################################################################################

# Set Current Version Information
Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate -Name ProductVersion -Value "Windows 11"
Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate -Name TargetReleaseVersion -Value 1
Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate -Name TargetReleaseVersionInfo -Value "23H2"

# Check if the package source exists
$source = Get-PackageSource -Name "NuGet" -ErrorAction SilentlyContinue

if ($source) {
    Write-Output "Package source NuGet already exists."
} else {
    # Install the new Powershell Windows Update modules
    try{
        Register-PackageSource -Name NuGet -Location https://www.nuget.org/api/v2 -ProviderName NuGet
        Set-PackageSource -Name NuGet -Trusted -ProviderName NuGet
        Install-Package -Name Newtonsoft.Json -ProviderName NuGet -Source NuGet
        Write-Log "NuGet Package Source installed successfully."
    } catch {
        Write-Log "NuGet Failed to install"
    }
}

try {
    Install-Module -Name PSWindowsUpdate -Force -AllowClobber
} catch {
    Write-Log "PSWindowsUpdate was already installed."
}

# Authorize Service Manager to inlcude all updates
Add-WUServiceManager -ServiceID "7971f918-a847-4430-9279-4a52d1efe18d" -AddServiceFlag 7 -Confirm:$False | Out-Null
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot

# Triggers the Settings > Control > Update
#control update

# Triggers Windows Update Scan to update the "Last Checked" list
usoclient startinteractivescan

Wait-Process -Name "*usoclient*"

##########################################################################################################################
### Post Cleanup System Drive Usage
##########################################################################################################################

$Volume = Get-Volume -DriveLetter C -ErrorAction SilentlyContinue
if ($Volume) {
    $TotalSpace = $Volume.Size
    $FreeSpace = $Volume.SizeRemaining
    $UsedSpace = $TotalSpace - $FreeSpace
    $UsedSpacePercent = [math]::Round(($UsedSpace / $TotalSpace) * 100, 2)
    Write-Log "C: drive usage: $UsedSpacePercent%"
} else {
    Write-Log "C: drive not found. Exiting script."
    exit
}

# Finalize log
$EndDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
Write-Log "Maintenance Log completed $EndDate"

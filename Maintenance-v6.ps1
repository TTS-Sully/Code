##########################################################################################################################
### Tech Team Solutions Deployable Maitenance Script
### Last Updated 2025.04.11
### Written by ESS
##########################################################################################################################
# Requires -RunAsAdministrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Script needs to be run as administrator."
    exit
}

##########################################################################################################################
### Variable Builder
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

function Write-Log {
    param ([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Out-File -FilePath $LogPath -Append
}

function Write-DriveSpaceNotification {
    param ([string]$Message)
    # Extract the drive letter from the file system path
    $DriveLetter = $FileSystemPath.Substring(0, 1)

    # Get the partition object associated with the drive letter
    $Partition = Get-Partition -DriveLetter $DriveLetter

    # Use the partition object with Get-Volume
    $Volume = Get-Volume -Partition $Partition

    if ($Volume) {
        $TotalSpace = $Volume.Size
        $FreeSpace = $Volume.SizeRemaining
        $UsedSpace = $TotalSpace - $FreeSpace
        $UsedSpacePercent = [math]::Round(($UsedSpace / $TotalSpace) * 100, 2)
        Write-Log "$Volume drive usage: $UsedSpacePercent%"
    } else {
        Write-Log "$volume drive not found. Exiting script."
        exit
    }
}

##########################################################################################################################
### Script Start
##########################################################################################################################

#Set-ExecutionPolicy Unrestricted -Force -Scope Process

Write-Host "Starting Local Maintenance Script v5..."

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

if (!(Test-Path -Path $LogDirectoryPath)) {
    New-Item -ItemType Directory -Path $LogDirectoryPath
}

# Start logging
Write-Log "Maintenance Log Started at $Date"

# Create TTS Directory
if (!(Test-Path -Path $TTSPath)) {
    New-Item -ItemType Directory -Path $TTSPath
}

##########################################################################################################################
### Check for Pending Reboot
##########################################################################################################################

Install-Module -Name PendingReboot -Force -AllowClobber -Verbose:$false
if((Test-PendingReboot -Detailed -SkipConfigurationManagerClientCheck -SkipPendingFileRenameOperations).RebootPending -eq $true) {
    Write-Log "Reboot Pending. Exiting script."
    Write-Host "Reboot Pending. Please Restart the Device and start maintenance again."
    Read-Host "Press Enter to exit..."
    exit
}

##########################################################################################################################
### Pre Cleanup System Drive Disk Usage
##########################################################################################################################

Write-DriveSpaceNotification

##########################################################################################################################
### Resolve Metadata Service URL Issue Error 131 Before patching
##########################################################################################################################

Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata' -Name DeviceMetadataServiceURL -Value 'http://dmd.metaservices.microsoft.com/dms/metadata.svc'

##########################################################################################################################
### Install Microsoft winget
##########################################################################################################################

Write-Host "Installing Operation packages..." | Write-Log "Installing Operation packages..."
try {
    winget --version | Out-Null
    Write-Host "Winget is already installed" | Write-Log "Winget is already installed"
} catch {  
    Install-Module -Name Microsoft.WinGet.Client -Force -Confirm:$false
    Import-Module -Name Microsoft.WinGet.Client -Force -Confirm:$false
    Write-Host "Winget installed" | Write-Log "Winget Installed"
}

##########################################################################################################################
### Install Microsoft NuGet
##########################################################################################################################

# Check if the package source exists
$source = Get-PackageSource -Name "NuGet" -ErrorAction SilentlyContinue

if ($source) {
    Write-Host "Package source NuGet already exists." | Write-Log "Package source NuGet already exists."
} else {
    # Install the new Powershell Windows Update modules
    try{
        Register-PackageSource -Name NuGet -Location https://www.nuget.org/api/v2 -ProviderName NuGet
        Set-PackageSource -Name NuGet -Trusted -ProviderName NuGet
        Install-Package -Name Newtonsoft.Json -ProviderName NuGet -Source NuGet
        Write-Host "NuGet Package Source installed successfully" | Write-Log "NuGet Package Source installed successfully."
    } catch {
        Write-Host "NuGet Failed to install" | Write-Log "NuGet Failed to install"
    }
}

##########################################################################################################################
### Prep and Run HP Drivers and Software Updates
##########################################################################################################################

$system = Get-CimInstance -ClassName Win32_ComputerSystem
if ($system.Manufacturer -eq "HP") {
    Install-Module -Name HPCMSL -Force -AcceptLicense
    Install-Module -Name HPDrivers -Force

    #Get-HPDrivers -NoPrompt -ShowSoftware -BIOS -DeleteInstallationFiles -SuspendBL
    Get-HPDrivers -NoPrompt -ShowSoftware -DeleteInstallationFiles -SuspendBL

    # Output the result
    Write-Output "HP Drivers and Software Updates completed." | Write-Log "HP Drivers and Software Updates completed."
} else {
    Write-Output "This system is not an HP device. Skipping HP Drivers and Software Updates." | Write-Log "This system is not an HP device. Skipping HP Drivers and Software Updates."
}

##########################################################################################################################
### Prep and Run Windows Store / Windows Packages Updates
##########################################################################################################################

Write-Host "Starting Windows Store Updates..." | Write-Log "Starting Windows Store Updates..."
try {
    if ($PSVersionTable.PSVersion.Major -eq 7) {
        Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" | Invoke-CimMethod -MethodName UpdateScanMethod
    } else {
        # Scan and install Windows Store Updates
        $namespaceName = "root\cimv2\mdm\dmmap"
        $className = "MDM_EnterpriseModernAppManagement_AppManagement01"   
        $wmiObj = Get-WmiObject -Namespace $namespaceName -Class $className
        $result = $wmiObj.UpdateScanMethod()
    }
    Write-Host "Windows Store Update Scan Method Result: $result" | Write-Log "Windows Store Update Scan Method Result: $result"
} catch {
    Write-Host "Windows Store Update Failed" | Write-Log "Windows Store Update Failed"
}

##########################################################################################################################
### Prep and Run Windows Update
##########################################################################################################################

Write-Host "Starting Monitored Windows Updates..." | Write-Log "Starting Monitored Windows Updates..."

try {
    # Authorize Service Manager to inlcude all updates
    Add-WUServiceManager -ServiceID "7971f918-a847-4430-9279-4a52d1efe18d" -AddServiceFlag 7 -Confirm:$False | Out-Null
    Write-Host "Windows Update Has Started" | Write-Log "Windows Update Has Started"
    Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot 

    # Triggers the Settings > Control > Update
    #control update

    # Triggers Windows Update Scan to update the "Last Checked" list
    usoclient startinteractivescan

    Wait-Process -Name "*usoclient*"
    Write-Host "Windows Updates have completed..." | Write-Log "Windows Updates have completed..."
} catch {
    Write-Host "Windows Update failed... " + $_.Exception.Message | Write-Log "Windows Update failed... " + $_.Exception.Message
}

##########################################################################################################################
### Install Microsoft Application Side Loader
##########################################################################################################################

# Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe | Out-Null
# Write-Log "Microsoft Application Side Loader Installed"

##########################################################################################################################
### Prep and Run winget appropriate package updates
##########################################################################################################################

# winget upgrade --all --accept-package-agreements --accept-source-agreements

##########################################################################################################################
### Begin Windows Cleanup and Optimization
##########################################################################################################################
### Bloatware Removial List
##########################################################################################################################

Write-Host "Removing Unneeded Windows Preinstalled Apps" | Write-Log "Removing Unneeded Windows Preinstalled Apps"
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
    Write-Host "There was a problem removing preinstalled software" | Write-Log "There was a problem removing preinstalled software" + $_.Exception.Message
}

##########################################################################################################################
### Detect and Clean Orphaned and Obsolete Windows Fix Files
##########################################################################################################################

Write-Host "Cleaning Orphaned and Obsolete Windows Fix Files..." | Write-Log "Cleaning Orphaned and Obsolete Windows Fix Files..."
if(Test-Path ('$FileSystemPath\Windows\SoftwareDistribution.old')) {
    Remove-Item -Path '$FileSystemPath\Windows\SoftwareDistribution.old' -Recurse -Force
}

if(Test-Path ('$FileSystemPath\Windows\System32\catroot2.old')) {
    Remove-Item -Path '$FileSystemPath\Windows\System32\catroot2.old' -Recurse -Force
}

##########################################################################################################################
### CleanMGR Configuration Setup and Run Commands
##########################################################################################################################

# Clear Disk Cleanup options
Write-Host "Setting Disk Cleanup options..." | Write-Log "Setting Disk Cleanup options..."
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
$CleanupCategories = @(
    "Active Setup Temp Folders",
    "BranchCache",
    "D3D Shader Cache",
    "Delivery Optimization Files",
    "Diagnostic Data Viewer database files",
    "Downloaded Program Files",
    "Feedback Hub Archive log files",
    "Internet Cache Files",
    "Offline Pages Files",        
    "Old ChkDsk Files",
    "Previous Installations",
    "Recycle Bin",
    "RetailDemo Offline Content",
    "Setup Log Files",
    "System error memory dump files",
    "System error minidump files",
    "Temporary Files",
    "Temporary Setup Files",
    "Thumbnail Cache",
    "Update Cleanup",
    "User file versions",
    "Windows Defender",
    "Windows Error Reporting Files",
    "Windows Upgrade Log Files",
    #below here may error
    "Memory Dump Files",
    "Service Pack Cleanup"
)

#Delete StateFlag0234 from any configurations
Get-ItemProperty -Path ($RegPath + '*') -Name StateFlags0234 -ErrorAction SilentlyContinue | Remove-ItemProperty -Name StateFlags0234 -ErrorAction SilentlyContinue

#Rebuild StateFlag0234 for approved folders
foreach ($Category in $CleanupCategories) {
    $Key = "$RegPath\$Category"
    if (Test-Path $Key) {
        Set-ItemProperty -Path $Key -Name "StateFlags0234" -Value 2 -Type DWord -ErrorAction SilentlyContinue
    }
}

# Run Disk Cleanup
Write-Host "Running Disk Cleanup..." | Write-Log "Running Disk Cleanup..."
try {
        if (-not(Get-Process -Name "cleanmgr*")){
            $CleanupProcess = Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:0234 /VERYLOWDISK" -WindowStyle Hidden -PassThru
            
            # Wait for Cleanup to Finish before proceeding
        }

        Wait-Process -InputObject $CleanupProcess
        Write-Host "Disk Cleanup Process Finished." | Write-Log "Disk Cleanup Process Finished."

} catch {
    Write-Host "Error during Disk Cleanup: $_" | Write-Log "Error during Disk Cleanup: $_"
}

##########################################################################################################################
### Post Cleanup System Drive Usage
##########################################################################################################################

Write-DriveSpaceNotification

# Finalize log
$EndDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
Write-Log "Maintenance Log completed $EndDate"
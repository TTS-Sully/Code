##########################################################################################################################
### Tech Team Solutions Maintenance Script v6
### Last Updated 2026.07.23
### Written by ESS
##########################################################################################################################
# Requires -RunAsAdministrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Script needs to be run as administrator."
    exit
}

### Force TLS 1.2 (critical for older systems)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

### PSGallery
try {
    if (-not (Get-PackageSource -Name PSGallery -ErrorAction SilentlyContinue)) {
        Register-PackageSource `
            -Name PSGallery `
            -ProviderName PowerShellGet `
            -Location "https://www.powershellgallery.com/api/v2" `
            -Trusted `
            -Force `
            -ErrorAction Stop

        Write-Host "[SUCCESS] PSGallery package source registered." -ForegroundColor Green
    }
    else {
        Set-PackageSource -Name PSGallery -Trusted -Force -ErrorAction Stop
        Write-Host "[SUCCESS] PSGallery package source already present and trusted." -ForegroundColor Green
    }
} catch {
    Write-Host "[ERROR] Failed to configure PSGallery: $($_.Exception.Message)" -ForegroundColor Red
}

### Install NuGet Package Provider (if not already installed)

Install-PackageProvider -Name NuGet -MinimumVersion '2.8.5.201' -Scope AllUsers -Force -Confirm:$false -ErrorAction Stop

### PendingReboot Module
try {
   if (-not (Get-Module -ListAvailable -Name PendingReboot)) {
        Install-Module `
            -Name PendingReboot `
            -Repository PSGallery `
            -Force `
            -SkipPublisherCheck `
            -ErrorAction Stop

        Write-Host "[SUCCESS] PendingReboot module installed." -ForegroundColor Green
    }
    else {
        Write-Host "[SUCCESS] PendingReboot module already installed." -ForegroundColor Green
    }
} catch {
    Write-Host "[ERROR] Failed to install PendingReboot module: $($_.Exception.Message)" -ForegroundColor Red
}

### PSWindowsUpdate Module
try {
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Install-Module `
            -Name PSWindowsUpdate `
            -Repository PSGallery `
            -RequiredVersion 2.2.1.4 `
            -Force `
            -SkipPublisherCheck `
            -AllowClobber `
            -ErrorAction Stop

        Write-Host "[SUCCESS] PSWindowsUpdate module installed." -ForegroundColor Green
    }
    else {
        Write-Host "[SUCCESS] PSWindowsUpdate module already installed." -ForegroundColor Green
    }
} catch {
    Write-Host "[ERROR] Failed to install PSWindowsUpdate module: $($_.Exception.Message)" -ForegroundColor Red
}

### Import PSWindowsUpdate
try {
    Import-Module PSWindowsUpdate -Force -ErrorAction Stop
    Write-Host "[SUCCESS] PSWindowsUpdate module imported." -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to import PSWindowsUpdate module: $($_.Exception.Message)" -ForegroundColor Red
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

function get-now {
    param ([string]$format = "yyyy-MM-dd_HH-mm-ss")
    return (Get-Date).ToString($format)
}

function Write-Log {
    param ([string]$Message)
    $timestamp = get-now
    "$timestamp $Message" | Out-File -FilePath $LogPath -Append
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

# Set-ExecutionPolicy Unrestricted -Force -Scope Process

Write-Host "Starting Local Maintenance Script v6..."

##########################################################################################################################
# Trigger a Windows Restore Point Creation
##########################################################################################################################

$newnow = get-now
Checkpoint-Computer -Description "TTS Maintenance: $newnow" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue


if (!(Test-Path -Path $LogDirectoryPath)) {
    New-Item -ItemType Directory -Path $LogDirectoryPath
}

# Start logging
$newnow = get-now
Write-Log "Maintenance Log Started at $newnow"

# Create TTS Directory
if (!(Test-Path -Path $TTSPath)) {
    New-Item -ItemType Directory -Path $TTSPath
}

##########################################################################################################################
### Check for Pending Reboot
##########################################################################################################################


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
### Prep and Run Windows Store Updates"
##########################################################################################################################

$EntraJoined = $false

if (Get-Command dsregcmd.exe -ErrorAction SilentlyContinue) {
    $EntraJoined = @(dsregcmd /status) -match '^\s*AzureAdJoined\s*:\s*YES\s*$'
}

if($EntraJoined) {
    Write-Host 'Starting Windows Store Updates...'

    $namespaceName = 'root\cimv2\mdm\dmmap'
    $className = 'MDM_EnterpriseModernAppManagement_AppManagement01'

$namespaceName = 'root\cimv2\mdm\dmmap'
$className = 'MDM_EnterpriseModernAppManagement_AppManagement01'

    $classExists = $false

    try {
        $classExists = $null -ne (
            Get-CimClass `
                -Namespace $namespaceName `
                -ClassName $className `
                -ErrorAction Stop
        )
    }
    catch {
        $classExists = $false
    }

    Write-Host "Class exists: $classExists"    
    <#try {
        # Verify the namespace exists.
        Get-CimClass -Namespace $namespaceName -ClassName $className -ErrorAction Stop |
            Out-Null

        # Retrieve the class instance.
        $wmiObj = Get-CimInstance `
            -Namespace $namespaceName `
            -ClassName $className `
            -ErrorAction Stop

        if ($null -eq $wmiObj) {
            throw "No instance was returned for $className."
        }

        # Invoke the scan method.
        $result = Invoke-CimMethod `
            -InputObject $wmiObj `
            -MethodName 'UpdateScanMethod' `
            -ErrorAction Stop

        if ($null -eq $result) {
            throw 'UpdateScanMethod returned no result.'
        }

        Write-Host "Windows Store update scan completed. Return value: $($result.ReturnValue)"
    }
    catch [Microsoft.Management.Infrastructure.CimException] {
        Write-Host "Windows Store update scan failed: $($_.Exception.Message)" `
            -ForegroundColor Red
        exit 1
    }
    catch {
        Write-Host "Windows Store update scan failed: $($_.Exception.Message)" `
            -ForegroundColor Red
        exit 1
    }#>
}

##########################################################################################################################
### Prep and Run Windows Update (Requires NuGet)
##########################################################################################################################
<#
Write-Host "Starting Monitored Windows Updates..." | Write-Log "Starting Monitored Windows Updates..."

try {
    Import-Module PSWindowsUpdate
    # Authorize Service Manager to inlcude all updates
    
    Start-Process -FilePath "UsoClient.exe" -ArgumentList "StartScan" -Wait
    Start-Process -FilePath "UsoClient.exe" -ArgumentList "StartDownload" -Wait
    Start-Process -FilePath "UsoClient.exe" -ArgumentList "StartInstall" -Wait

    # Triggers Windows Update Scan to update the "Last Checked" list
    usoclient startinteractivescan

    Wait-Process -Name "*usoclient*"
    Write-Host "Windows Updates have completed..." | Write-Log "Windows Updates have completed..."
} catch {
    Write-Host "Windows Update failed... " + $_.Exception.Message | Write-Log "Windows Update failed... " + $_.Exception.Message
}
#>
##########################################################################################################################
### Install and run Microsoft Safety Scanner Download
##########################################################################################################################
#
# Set the target folder and file path
#$targetDir = "$TTSPath\Tools\MSERT"
#$targetFile = Join-Path $targetDir "msert.exe"

# Create the directory if it doesn't exist
#if (-not (Test-Path $targetDir)) {
#    New-Item -ItemType Directory -Path $targetDir | Out-Null
#}

# Download the latest 64-bit MSERT executable
#Write-Host "Downloading the latest MSERT version..." -ForegroundColor Cyan
#Invoke-WebRequest -Uri "https://microsoft.com" -OutFile $targetFile

# Launch MSERT
#Write-Host "Download complete. Starting Microsoft Safety Scanner..." -ForegroundColor Green
#Start-Process -FilePath $targetFile

##########################################################################################################################
### Begin Registry Backup
##########################################################################################################################
<#
#craete a backup folder
New-Item -ItemType Directory -Path "$TTSPath\Backup\SystemFiles" -Force

#backup registry
$regExport = Start-Process -FilePath "regedit.exe" -ArgumentList "/E `"$TTSPath\Backup\SystemFiles\FullRegistryBackup.reg`"" -PassThru
$regExport.WaitForExit()
#>
##########################################################################################################################
### Begin Browser Data Backup
##########################################################################################################################
<#
# Create a backup folder
New-Item -ItemType Directory -Path "$TTSPath\Backup\EdgeData" -Force
New-Item -ItemType Directory -Path "$TTSPath\Backup\ChromeData" -Force

# Copy Bookmarks, Settings, and Passwords
if (Test-Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Bookmarks") {
    Copy-Item -Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Bookmarks" -Destination "$TTSPath\Backup\EdgeData\Bookmarks"
}

if (Test-Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Preferences") {
    Copy-Item -Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Preferences" -Destination "$TTSPath\Backup\EdgeData\Preferences"
}

if (Test-Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data") {
    Copy-Item -Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data" -Destination "$TTSPath\Backup\EdgeData\Login Data"
}

if (Test-Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Bookmarks") {
    Copy-Item -Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Bookmarks" -Destination "$TTSPath\Backup\ChromeData\Bookmarks"
}

if (Test-Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Preferences") {
    Copy-Item -Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Preferences" -Destination "$TTSPath\Backup\ChromeData\Preferences"
}

if (Test-Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data") {
    Copy-Item -Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data" -Destination "$TTSPath\Backup\ChromeData\Login Data"
}
#>

##########################################################################################################################
### Archive Backup Files
##########################################################################################################################
<#
$SourcePath = "$TTSPath\Backup"
$ZipFile = "$TTSPath\Backup\Backup_$(Get-Date -Format 'yyyyMMdd').zip"

Get-ChildItem -Path $SourcePath -Directory |
    Select-Object -ExpandProperty FullName |
    Compress-Archive -Path {$_} -DestinationPath $ZipFile -Force
#>
##########################################################################################################################
### Begin Windows Cleanup and Optimization
##########################################################################################################################
### Self Cleanup
<#
if (Test-Path "$TTSPath\Backup\EdgeData") {
    Remove-Item "$TTSPath\Backup\EdgeData" -Recurse -Force
}

if (Test-Path "$TTSPath\Backup\ChromeData") {
    Remove-Item "$TTSPath\Backup\ChromeData" -Recurse -Force
}

if (Test-Path "$TTSPath\Backup\SystemFiles") {
    Remove-Item "$TTSPath\Backup\SystemFiles" -Recurse -Force
}

### Keep only the 3 most recent backup ZIPs
$BackupFolder = "$TTSPath\Backup"

Get-ChildItem -Path $BackupFolder -Filter "Backup_*.zip" |
    Sort-Object LastWriteTime -Descending |
    Select-Object -Skip 3 |
    Remove-Item -Force
#>
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
    Get-AppxPackage *Microsoft.Xbox.TCUI* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.XboxGameOverlay* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.XboxGamingOverlay* | Remove-AppxPackage
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

if(Test-Path ('$FileSystemPath\Windows.old')) {
    Remove-Item -Path '$FileSystemPath\Windows.old' -Recurse -Force
}

# Stops the Print Spooler Service and clears the print queue then restarts the service
Write-Host "Clearing Print Spooler Queue..." | Write-Log "Clearing Print Spooler Queue..."

Stop-Service -Name "Spooler" -Force
$folderPath = "$env:windir\System32\spool\PRINTERS"
Get-ChildItem -Path $folderPath | Remove-Item -Force
Start-Service -Name "Spooler"


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
$newnow = get-now
Write-Host "Maintenance Log completed $newnow" | Write-Log "Maintenance Log completed $newnow"

Set-Location -Path $TTSPath
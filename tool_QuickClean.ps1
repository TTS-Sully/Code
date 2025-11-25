##########################################################################################################################
### Tech Team Solutions - Quick Clean Script
### Last Updated 2025.08.06
### Written by ESS
##########################################################################################################################

Write-Host "Removing Unneeded Windows Preinstalled Apps"
Try {
    # Remove 3D Builder
    Write-Host "Removing 3D Builder"
    Get-AppxPackage *Microsoft.3dbuilder* | Remove-AppxPackage

    # Remove Adobe Photoshop Express
    Write-Host "Removing Adobe Photoshop Express"
    Get-AppxPackage *AdobeSystemsIncorporated.AdobePhotoshopExpress* | Remove-AppxPackage

    # Remove Alarms and Clock
    Write-Host "Removing Alarms and Clock"
    Get-AppxPackage *Microsoft.WindowsAlarms* | Remove-AppxPackage

    # Remove Asphalt 8
    Write-Host "Removing Asphalt 8"
    Get-AppxPackage *Microsoft.Asphalt8Airborne* | Remove-AppxPackage

    # Remove Calendar and Mail
    Write-Host "Removing Calendar and Mail"
    Get-AppxPackage *microsoft.windowscommunicationsapps* | Remove-AppxPackage

    # Remove Candy Crush Soda Saga
    Write-Host "Removing all king.com games"
    Get-AppxPackage *king.com* | Remove-AppxPackage

    # Remove Drawboard PDF
    Write-Host "Removing Drawboard PDF"
    Get-AppxPackage *Microsoft.DrawboardPDF* | Remove-AppxPackage

    # Remove Facebook
    Write-Host "Removing Facebook"
    Get-AppxPackage *Facebook* | Remove-AppxPackage

    # Remove Fallout Shelter
    Write-Host "Removing Fallout Shelter"
    Get-AppxPackage *BethesdaSoftworks.FalloutShelter* | Remove-AppxPackage
    # Remove FarmVille 2
    Write-Host "Removing FarmVille 2"
    Get-AppxPackage *FarmVille2CountryEscape* | Remove-AppxPackage

    # Remove Feedback Hub
    Write-Host "Removing Feedback Hub"
    Get-AppxPackage *Microsoft.WindowsFeedbackHub* | Remove-AppxPackage

    # Remove Get Help
    Write-Host "Removing Get Help"
    Get-AppxPackage *Microsoft.GetHelp* | Remove-AppxPackage
    # Remove Get Started
    Write-Host "Removing Get Started"
    Get-AppxPackage *Microsoft.Getstarted* | Remove-AppxPackage

    # Remove Groove Music
    Write-Host "Removing Groove Music"
    Get-AppxPackage *Microsoft.ZuneMusic* | Remove-AppxPackage

    # Remove Maps
    Write-Host "Removing Maps"
    Get-AppxPackage *Microsoft.WindowsMaps* | Remove-AppxPackage

    # Remove Messaging
    Write-Host "Removing Messaging"
    Get-AppxPackage *Microsoft.Messaging* | Remove-AppxPackage

    # Remove Wallet
    Write-Host "Removing Wallet"
    Get-AppxPackage *Microsoft.Wallet* | Remove-AppxPackage

    # Remove Solitaire Collection
    Write-Host "Removing Solitaire Collection"
    Get-AppxPackage *Microsoft.MicrosoftSolitaireCollection* | Remove-AppxPackage

    # Remove Todos
    Write-Host "Removing Todos"
    Get-AppxPackage *Todos* | Remove-AppxPackage

    # Remove Connectivity Store
    Write-Host "Removing Connectivity Store"
    Get-AppxPackage *ConnectivityStore* | Remove-AppxPackage

    # Remove Minecraft
    Write-Host "Removing Minecraft"
    Get-AppxPackage *MinecraftUWP* | Remove-AppxPackage

    # Remove OneConnect
    Write-Host "Removing OneConnect"
    Get-AppxPackage *Microsoft.OneConnect* | Remove-AppxPackage

    # Remove Bing Finance
    Write-Host "Removing Bing Finance"
    Get-AppxPackage *Microsoft.BingFinance* | Remove-AppxPackage

    # Remove Zune Video
    Write-Host "Removing Zune Video"
    Get-AppxPackage *Microsoft.ZuneVideo* | Remove-AppxPackage

    # Remove Bing News
    Write-Host "Removing Bing News"
    Get-AppxPackage *Microsoft.BingNews* | Remove-AppxPackage

    # Remove Office Hub
    Write-Host "Removing Office Hub"
    Get-AppxPackage *Microsoft.MicrosoftOfficeHub* | Remove-AppxPackage

    # Remove Netflix
    Write-Host "Removing Netflix"
    Get-AppxPackage *Netflix* | Remove-AppxPackage

    # Remove OneNote
    Write-Host "Removing OneNote"
    Get-AppxPackage *OneNote* | Remove-AppxPackage

    # Remove Pandora
    Write-Host "Removing Pandora"
    Get-AppxPackage *PandoraMediaInc* | Remove-AppxPackage

    # Remove People
    Write-Host "Removing People"
    Get-AppxPackage *Microsoft.People* | Remove-AppxPackage

    # Remove Phone
    Write-Host "Removing Phone"
    Get-AppxPackage *CommsPhone* | Remove-AppxPackage

    # Remove Windows Phone Companion
    Write-Host "Removing Windows Phone Companion"
    Get-AppxPackage *windowsphone* | Remove-AppxPackage

    # Remove Print 3D
    Write-Host "Removing Print 3D"
    Get-AppxPackage *Microsoft.Print3D* | Remove-AppxPackage

    # Remove Royal Revolt 2
    Write-Host "Removing Royal Revolt 2"
    Get-AppxPackage *flaregamesGmbH.RoyalRevolt2* | Remove-AppxPackage

    # Remove SketchBook
    Write-Host "Removing SketchBook"
    Get-AppxPackage *AutodeskSketchBook* | Remove-AppxPackage

    # Remove Skype
    Write-Host "Removing Skype"
    Get-AppxPackage *Microsoft.SkypeApp* | Remove-AppxPackage

    # Remove Bing Sports
    Write-Host "Removing Bing Sports"
    Get-AppxPackage *bingsports* | Remove-AppxPackage

    # Remove Sway
    Write-Host "Removing Sway"
    Get-AppxPackage *Office.Sway* | Remove-AppxPackage

    # Remove Twitter
    Write-Host "Removing Twitter"
    Get-AppxPackage *Twitter* | Remove-AppxPackage

    # Remove 3D Viewer
    Write-Host "Removing 3D Viewer"
    Get-AppxPackage *Microsoft3DViewer* | Remove-AppxPackage

    # Remove Sound Recorder
    Write-Host "Removing Sound Recorder"
    Get-AppxPackage *Microsoft.WindowsSoundRecorder* | Remove-AppxPackage

    # Remove Bing Weather
    Write-Host "Removing Bing Weather"
    Get-AppxPackage *Microsoft.BingWeather* | Remove-AppxPackage

    # Remove Xbox App
    Write-Host "Removing Xbox App"
    Get-AppxPackage *Microsoft.XboxApp* | Remove-AppxPackage

    # Remove Xbox SmartGlass
    Write-Host "Removing Xbox SmartGlass"
    Get-AppxPackage *XboxOneSmartGlass* | Remove-AppxPackage

    # Remove Xbox Speech to Text Overlay
    Write-Host "Removing Xbox Speech to Text Overlay"
    Get-AppxPackage *Microsoft.XboxSpeechToTextOverlay* | Remove-AppxPackage

    # Remove Xbox Identity Provider
    Get-AppxPackage *Microsoft.XboxIdentityProvider* | Remove-AppxPackage

    # Remove Xbox Gaming Overlay
    Write-Host "Removing Xbox Gaming Overlay"
    Get-AppxPackage *Microsoft.XboxGameingOverlay* | Remove-AppxPackage

    # Remove Outlook for Windows
    Write-Host "Removing Outlook for Windows"
     Get-AppxPackage *Microsoft.OutlookForWindows* | Remove-AppxPackage

} catch {
    Write-Host "There was a problem removing preinstalled software"
}

##########################################################################################################################
### Detect and Clean Orphaned and Obsolete Windows Fix Files
##########################################################################################################################
$FileSystemPath = $env:SystemDrive
Write-Host "Cleaning Orphaned and Obsolete Windows Fix Files..."

$obsoleteFolders = @(
    "Windows\SoftwareDistribution.old",
    "Windows\System32\catroot2.old",
    "Windows.old"
)

foreach ($folder in $obsoleteFolders) {
    $fullPath = Join-Path $FileSystemPath $folder
    if (Test-Path $fullPath) {
        Write-Host "Attempting to remove $fullPath..."
        try {
            Remove-Item -Path $fullPath -Recurse -Force -ErrorAction Stop
            Write-Host "Removed: $fullPath"
        }
        catch {
            Write-Warning "Failed to remove $fullPath. Reason: $($_.Exception.Message)"
        }
    } else {
        Write-Host "Not found: $fullPath"
    }
}

##########################################################################################################################
### CleanMGR Configuration Setup and Run Commands
##########################################################################################################################

# Clear Disk Cleanup options
Write-Host "Setting Disk Cleanup options..."
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
Write-Host "Running Disk Cleanup..."
try {
        if (-not(Get-Process -Name "cleanmgr*")){
            $CleanupProcess = Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:0234 /VERYLOWDISK" -WindowStyle Hidden -PassThru
            
            # Wait for Cleanup to Finish before proceeding
        } else {
            $CleanupProcess = Get-Process -Name "cleanmgr*"
        }

        Wait-Process -InputObject $CleanupProcess
        Write-Host "Disk Cleanup Process Finished." 

} catch {
    Write-Host "Error during Disk Cleanup: $_"
}
# Here to make sure this runs when copy / pasted
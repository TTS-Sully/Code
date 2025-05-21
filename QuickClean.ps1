Write-Host "Removing Unneeded Windows Preinstalled Apps"
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
    Write-Host "There was a problem removing preinstalled software"
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
        }

        Wait-Process -InputObject $CleanupProcess
        Write-Host "Disk Cleanup Process Finished." 

} catch {
    Write-Host "Error during Disk Cleanup: $_"
}
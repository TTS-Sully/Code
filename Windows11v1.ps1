##########################################################################################################################
### Tech Team Solutions Deployable Maitenance Script
### Last Updated 2025.03.11
### Written by ESS
##########################################################################################################################
Write-Host "Windows 11 23H2 Upgrade Started" -ForegroundColor Green
# Set Current Version Information

$WURegPath = "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate"

if (!(Test-Path -Path $WURegPath)) {
    New-Item -Path $WURegPath -Force
}
Set-ItemProperty -Path $WURegPath -Name ProductVersion -Value "Windows 11" -Force
Set-ItemProperty -Path $WURegPath -Name TargetReleaseVersion -Value 1 -Force
Set-ItemProperty -Path $WURegPath -Name TargetReleaseVersionInfo -Value "23H2" -Force
# Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator -Name InstallAtShutdown -Type DWord -Value "1"

##########################################################################################################################
# Execute File Copy to Local Machine
##########################################################################################################################
# Set the install path and script directory
$installpath = "C:\TTS"
$scriptDirectory = $PSScriptRoot

Write-Host "Attempting to copy .iso to $installpath" -ForegroundColor Green
try {
    # Create TTS Directory
    if (!(Test-Path -Path $installpath)) {
        New-Item -ItemType Directory -Path $installpath -Force
    }

    # copy the ISO file to the TTS directory
    if(!(Test-Path -Path "$installpath\Win11_23H2_English_x64.iso")) {
        Copy-Item -Path "$scriptDirectory\Win11_23H2_English_x64.iso" -Destination $installpath
    }
} catch {
    Write-Host "Error: Unable to copy the ISO file to the local machine" -ForegroundColor Red
    Write-Host $_.Exception.Message
    Exit
}

##########################################################################################################################
# Mount the ISO file and Install Windows 11
##########################################################################################################################
Write-Host "Attempting to install Windows 11" -ForegroundColor Green
try {
    # Mount the ISO file
    $vol= Mount-DiskImage -ImagePath "$installpath\Win11_23H2_English_x64.iso" -PassThru | Get-DiskImage | Get-Volume | Select-Object DriveLetter
    # Set the image path and Start the install
    $imagepath = '{0}:\' -f $vol.DriveLetter
    #Set-Location $imagepath
    $process_setup = Start-Process -FilePath "$imagepath\setup.exe" -ArgumentList "/auto upgrade /eula accept /migratedrivers all /DynamicUpdate NoLCU" -Wait -PassThru
    #$process_setup = Start-Process -FilePath "$imagepath\setup.exe" -ArgumentList "/auto upgrade /eula accept /migratedrivers all" -Wait -PassThru
    Write-Host "Windows 11 23H2 Upgrade Completed Successfully" -ForegroundColor Green
} catch {
    Write-Host "Error: Unable to mount the ISO file and install Windows 11" -ForegroundColor Red
    Write-Host $_.Exception.Message
    Exit
}
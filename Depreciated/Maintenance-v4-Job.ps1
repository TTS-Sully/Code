##########################################################################################################################
### Tech Team Solutions Deployable Maitenance Script
### Last Updated 2025.03.06
### Written by ESS
##########################################################################################################################

##########################################################################################################################
# Deployable Maitenance Script and Adding Right Click Context to Run as Admin
##########################################################################################################################

$TTSPath = $env:SystemDrive + "\TTS"

# Delete files if they exist
if(Test-Path $TTSPath\Maintenance-v4.ps1 -PathType Leaf) {
    Remove-Item -Path $TTSPath\Maintenance-v4.ps1
}

if(Test-Path $TTSPath\Maintenance.bat -PathType Leaf) {
    Remove-Item -Path $TTSPath\Maintenance.bat
}

# Move Onsite Maitenance File attached to the job
Move-Item -Path Maintenance-v4.ps1 -Destination $TTSPath\Maintenance-v4.ps1
Move-Item -Path Maintenance.bat -Destination $TTSPath\Maintenance.bat
Write-Host "Maitenance File has been delivered... "
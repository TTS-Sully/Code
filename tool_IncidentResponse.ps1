##########################################################################################################################
### Tech Team Solutions Incident Response - Desktop
### Last Updated 2025.04.03
### Written by ESS
##########################################################################################################################

function ZipFiles( $zipfilename, $sourcedir ){
    Add-Type -Assembly System.IO.Compression.FileSystem
    $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
    [System.IO.Compression.ZipFile]::CreateFromDirectory($sourcedir, $zipfilename, $compressionLevel, $false)
}

# Get the current date and time
$currentDate = Get-Date

# Format the date as year number, month number, day number
$formattedDate = $currentDate.ToString("yyyy-MM-dd")

# Get the drive letter of the OS drive
$osDrive = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -eq [System.IO.Path]::GetPathRoot($PSHome) }

# Set drive to send the final archive to
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$driveTOARCHIVETO = (Split-Path -Path $scriptDirectory -Qualifier) + "\"

#$rootPath = "c:\"
$rootPath = "$($osDrive.Root)"
$pathSHADOW = $rootPath + "shadowcopyroot"
$pathOUTPUT = $driveTOARCHIVETO + "TTS"
$pathARCHIVE = $rootPath + "_toArchive"
$pathEvents = $rootPath + "_toArchive\EventLogs"
$zipfilename =  $pathOUTPUT + "\" + $formattedDate + "-Archive.zip"

$shadowCopy = Invoke-CimMethod -ClassName Win32_ShadowCopy -MethodName Create -Arguments @{Volume = "C:\\"; Context = "ClientAccessible"}
$shadowCopyObject = Get-CimInstance -ClassName Win32_ShadowCopy | Where-Object { $_.ID -eq $shadowCopy.ShadowID }
$deviceObject = $shadowCopyObject.DeviceObject + "\"

$launchARGUMENTS = "/c mklink /D $pathSHADOW $deviceObject"
Start-Process "cmd.exe" -ArgumentList $launchARGUMENTS -NoNewWindow -Wait | Out-Null

# Read-Host "Shadow Copy Created. Press Enter to continue..."

# Build Directory Structure
if (!(Test-Path -Path $pathARCHIVE)) {
    New-Item -ItemType Directory -Path $pathARCHIVE | Out-Null
}

if (!(Test-Path -Path $pathOUTPUT)) {
    New-Item -ItemType Directory -Path $pathOUTPUT | Out-Null
}

if (!(Test-Path -Path $pathEvents)) {
    New-Item -ItemType Directory -Path $pathEvents | Out-Null
}

# move Browser Files to Archive
Write-Host "Moving Browser Files to Archive"
$profiles = Get-ChildItem -Path "$pathSHADOW\Users" -Directory
foreach ($profile in $profiles) {
    try {
        # CHROME TARGETING
        $sourceFolder = $profile.FullName + "\appdata\local\google\chrome\user data\default"
        $targetFolder = $pathARCHIVE + "\Chrome\" + $profile.Name

        if (Test-Path -Path $sourceFolder){
            robocopy "$sourceFolder" "$targetFolder" /E /COPYALL /R:1 /W:1 /NFL /NDL /NJS /NJH /nc /ns /np
            Write-Host "Robocopying Chrome data from $sourceFolder"
        } else {
            Write-Host "Chrome data not found for $($profile.Name)"
        }
    } catch {
        Write-Host "Error: $($_.Exception.Message)"
    }

    try {
        # EDGE TARGETING
        $sourceFolder = $profile.FullName + "\AppData\Local\Microsoft\Edge\User Data\Default"
        $targetFolder = $pathARCHIVE + "\Edge\" + $profile.Name

        if (Test-Path -Path $sourceFolder){
            robocopy "$sourceFolder" "$targetFolder" /E /COPYALL /R:1 /W:1 /NFL /NDL /NJS /NJH /nc /ns /np
            Write-Host "Robocopying Edge data from $sourceFolder"
        } else {
            Write-Host "Edge data not found for $($profile.Name)"
        }
    } catch {
        Write-Host "Error: $($_.Exception.Message)"
    }

    try {
        # FIREFOX TARGETING
        $sourceFolder = $profile.FullName + "\AppData\Local\Mozilla\Firefox\Profiles"
        $targetFolder = $pathARCHIVE + "\Firefox\" + $profile.Name
        if (Test-Path -Path $sourceFolder){
            robocopy "$sourceFolder" "$targetFolder" /E /COPYALL /R:1 /W:1 /NFL /NDL /NJS /NJH /nc /ns /np
            Write-Host "Robocopying Firefox data from $sourceFolder"
        } else {
            Write-Host "Firefox data not found for $($profile.Name)"
        }
    } catch {
        Write-Host "Error: $($_.Exception.Message)"
    }
}

# Registry Hive Export
Write-Host "Exporting Registry Hives to Archive"
try{
    $userHive = "HKCU" 
    $destinationPath = "$pathARCHIVE\NTUSER.DAT"
    reg save $userHive $destinationPath /y
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}

# Exporting Event Logs
Write-Host "Exporting Event Logs to Archive"
$logPath = "$rootPath\Windows\System32\winevt\Logs"

Get-ChildItem -Path $logPath -Filter "*.evtx" | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-14)} | Copy-Item -Destination "$pathARCHIVE\EventLogs"

# Build ZIP Archive
Write-Host "Building ZIP Archive"
try{
    ZipFiles $zipfilename $pathARCHIVE
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}

# Remove Shadow Copy volume, delete the symbolic link, and remove the archive directory
Remove-CimInstance -InputObject $shadowCopyObject
Remove-Item -Path $pathSHADOW -Recurse -Force
Remove-Item -Path $pathARCHIVE -Recurse -Force

Read-Host "Compleated - Press Enter to exit..."
$TTSPath = "c:\TTS"
$DriverDestination = "C:\Program Files\HP\HP ScanJet Pro 3000 s3\DriverStoreTwain\HPScanUnusedStubDriver"

if (!(Test-Path -Path $TTSPath)) {
    New-Item -ItemType Directory -Path $TTSPath
}

if (!(Test-Path -Path $DriverDestination)) {
    New-Item -ItemType Directory -Path $DriverDestination
}

Move-Item -Path UnusedScanStub_SJ3000_U.cat -Destination $DriverDestination\UnusedScanStub_SJ3000_U.cat
Move-Item -Path UnusedScanStub_SJ3000_U.inf -Destination $DriverDestination\UnusedScanStub_SJ3000_U.inf

# Remove broken USB PRINTING SUPPORT devices
$deviceDRIVERSTOUPDATE = Get-PnpDevice -FriendlyName "*USB Printing Support*"
if ($null -eq $deviceDRIVERSTOUPDATE -or $deviceDRIVERSTOUPDATE.Count -eq 0) {
    if ($deviceDRIVERSTOUPDATE) {
        # Remove the device
        $deviceDRIVERSTOUPDATE | ForEach-Object { & pnputil /remove-device $_.InstanceId }
    }
}
# TODO: Install HP Scanner USB Printing Support
foreach ($Camera in $Cameras) {
    if ($Camera.InfName -ne "usbvideo.inf") {
    Write-Host "Updating Driver"
    
    # Uninstall current driver
    $CurrentDriver = Get-WindowsDriver -Online -All | Where-Object Driver -eq $Camera.InfName
    pnputil.exe /delete-driver $CurrentDriver.OriginalFileName /uninstall
    
    # Install new driver
    pnputil.exe /add-driver $NewDriverPath /install
    } else {
    Write-Host "Driver is already updated"
    }
}


# GPO Hardware block location: Computer Configuration > Policies > Administrative Templates > System > Device Installation 


<#


#Removes broen HP 3000 devices
$devicesREMOVE = Get-PnpDevice -FriendlyName "*HP*3000*" -Class USB, Image
if( $null -eq $devicesREMOVE -or $devicesREMOVE.Count -eq 0) {
    if ($devicesREMOVE) {
        # Remove the device
        $devicesREMOVE | ForEach-Object { & pnputil /remove-device $_.InstanceId }
    }
}







PNPUtil.exe /add-driver "C:\Drivers\MyDriver\*.inf" /install



#Trigger to scan for new devices
pnputil.exe /scan-devices

$devicesDISABLE = Get-PnpDevice -FriendlyName "*HP HP*3000*"
if($null -eq $devicesDISABLE -or $devicesDISABLE.Count -eq 0) {
    if ($devicesDISABLE) {
        # Disable the device
        $devicesDISABLE | ForEach-Object { Disable-PnpDevice -InstanceId $_.InstanceId}
    }
}

#>
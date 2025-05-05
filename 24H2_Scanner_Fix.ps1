# Remove broken USB PRINTING SUPPORT devices
$devicesREMOVE_PRINTINGSUPPORT = Get-PnpDevice -FriendlyName "*USB Printing Support*"
if ($null -eq $devicesREMOVE_PRINTINGSUPPORT -or $devicesREMOVE_PRINTINGSUPPORT.Count -eq 0) {
    if ($devicesREMOVE_PRINTINGSUPPORT) {
        # Remove the device
        $devicesREMOVE_PRINTINGSUPPORT | ForEach-Object { & pnputil /remove-device $_.InstanceId }
    }
}

#Removes broen HP 3000 devices
$devicesREMOVE = Get-PnpDevice -FriendlyName "*HP*3000*" -Class USB, Image
if( $null -eq $devicesREMOVE -or $devicesREMOVE.Count -eq 0) {
    if ($devicesREMOVE) {
        # Remove the device
        $devicesREMOVE | ForEach-Object { & pnputil /remove-device $_.InstanceId }
    }
}

# TODO: Install HP Scanner USB Printing Support
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
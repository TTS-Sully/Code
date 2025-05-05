# Get all imaging devices and their hardware IDs
$imagingDevices = Get-PnpDevice -Class Image, USB -ErrorAction SilentlyContinue #| Select-Object Name, InstanceId

# Check if $imagingDevices is null or empty
if ($null -eq $imagingDevices -or $imagingDevices.Count -eq 0) {
     Write-Host "No imaging devices found."
} else {
    # Define the hardware ID you want to block
    #$hardwareID = "USB\\VID_XXXX&PID_XXXX"

    # Define the registry path for device installation restrictions
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions"

    # Create the registry key if it doesn't exist
    if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force }

    # Add the hardware ID to the DenyDeviceIDs list
    Set-ItemProperty -Path $regPath -Name "DenyDeviceIDs" -Value $hardwareID

    # Enable device installation restrictions
    Set-ItemProperty -Path $regPath -Name "DenyDeviceIDsRetroactive" -Value 1

    Write-Host "Hardware ID $hardwareID has been blocked."

    # Get the device using its hardware ID
    # device may have a (USB) or (NULL) suffix, so we need to check for both
    $device = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*$friendlyName*" -or $_.FriendlyName -like "*$friendlyName (USB)*" -or $_.FriendlyName -like "*$friendlyName (NULL)*" }

    # Check if the device is found
    if ($device) {
        # Remove the device
        $device | ForEach-Object { & pnputil /remove-device $_.InstanceId }
        Write-Host "Device with hardware ID $hardwareID has been removed."
    } else {
        Write-Host "Device with hardware ID $hardwareID not found."
    }
}

$devicesREMOVE_PRINTINGSUPPORT = Get-PnpDevice -FriendlyName "*USB Pritning Support"

if ($devicesREMOVE_PRINTINGSUPPORT) {
    # Remove the device
    $devicesREMOVE_PRINTINGSUPPORT | ForEach-Object { & pnputil /remove-device $_.InstanceId }
} 

$devicesREMOVE = Get-PnpDevice -FriendlyName "*HP*3000*"

if ($devicesREMOVE) {
    # Remove the device
    $devicesREMOVE | ForEach-Object { & pnputil /remove-device $_.InstanceId }
}

pnputil.exe /scan-devices

$devicesDISABLE = Get-PnpDevice -FriendlyName "*HP HP*3000*" -Class Image, USB, PrintQueue

if ($devicesREMOVE) {
    # Remove the device
    $devicesREMOVE | ForEach-Object { Disable-PnpDevice -InstanceId $_.InstanceId}
}

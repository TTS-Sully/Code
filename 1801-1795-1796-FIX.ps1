$path = "HKLM:\SYSTEM\CurrentControlSet\Control\Secureboot"

# --- MicrosoftUpdateManagedOptIn ---
if (Get-ItemProperty -Path $path -Name "MicrosoftUpdateManagedOptIn" -ErrorAction SilentlyContinue) {
    # Exists → Set it
    Set-ItemProperty -Path $path -Name "MicrosoftUpdateManagedOptIn" -Value 0x5944 -Force
    Write-Host "MicrosoftUpdateManagedOptIn already exists, setting it to 0x5944."
} else {
    # Does not exist → Create it
    New-ItemProperty -Path $path -Name "MicrosoftUpdateManagedOptIn" -PropertyType DWord -Value 0x5944  -Force
    Write-Host "MicrosoftUpdateManagedOptIn did not exist, created it with value 0x5944."
}

# --- AvailableUpdates ---
if (Get-ItemProperty -Path $path -Name "AvailableUpdates" -ErrorAction SilentlyContinue) {
    # Exists → Set it
    Set-ItemProperty -Path $path -Name "AvailableUpdates" -Value 0x5be6 -Force
    Write-Host "AvailableUpdates already exists, setting it to 0x5be6."
} else {
    # Does not exist → Create it
    New-ItemProperty -Path $path -Name "AvailableUpdates" -PropertyType DWord -Value 0x5be6 -Force
    Write-Host "AvailableUpdates did not exist, created it with value 0x5be6."
}

if((Get-ComputerInfo).BiosFirmwareType -eq "UEFI"){
    if(([System.Text.Encoding]::ASCII.GetString((Get-SecureBootUEFI db).bytes) -match 'Windows UEFI CA 2023') -eq $true){
        Suspend-BitLocker -MountPoint "C:" -RebootCount 1
        Write-Host "The system is UEFI and has the correct certificate, applying the update now."
        WinCsFlags.exe /apply --key "F33E0C8E002"
        Start-ScheduledTask -TaskName "\Microsoft\Windows\PI\Secure-Boot-Update"
    } else {
        Write-Host "The system is UEFI but does not have the correct certificate, skipping the rest of the script."
        exit 1
    }
} else {
    Write-Host "This system is not UEFI, skipping the rest of the script."
    exit 1
}
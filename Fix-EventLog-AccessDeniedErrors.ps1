##########################################################################################################################
### Tech Team Solutions - Fix Event Viewer Fixer
### Last Updated 2025.08.04
### Written by ESS
##########################################################################################################################

# Switch statement to handle different cases
function DisplayLISTOPTIONS {
    clear-host
    # Prompt user for input
    write-output "1. Internet Explorer Access Denied"
    write-output "2. Microsoft-Windows-USBVideo/Analytic"
    write-output "3. Remote Desktop Services - Remote FX Session"
    $userInput = Read-Host "Enter a numbered Choice."

    switch ($userInput.ToLower()) {
        "1" { resetIEPermissions }
        "2" { removeMSWUSBVideo }
        "3" { removeRemoteDesktopServicesRemoteFXSessionLicensing}
        default {
            Write-Output "Invalid Choice, please select a valid choice"
            DisplayLISTOPTIONS
        }
    }
}

function resetIEPermissions {
    ################################ Reset IE Event Log Permissions
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Internet Explorer" -Name "CustomSD" -Value "O:BAG:SYD:(A;;0x07;;;DA)(A;;0x07;;;LA)(D;;0x07;;;DU)(A;;0x07;;;WD)S:(ML;;0x1;;;LW)"
}

function removeMSWUSBVideo {
    ################################ Microsoft-Windows-USBVideo/Analytic
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-USBVideo/Analytic" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\PnpResources\Registry\HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-USBVideo/Analytic" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Publishers\{da1d1dbd-3186-4fa2-bc2d-075efd9e43e2}" -Recurse -Force -ErrorAction SilentlyContinue
}

function removeRemoteDesktopServicesRemoteFXSessionLicensing {
    ############################### RemoteDesktopServices-RemoteFX-SessionLicensing
    # Remove registry key: RemoteDesktopServices-RemoteFX-SessionLicensing-Debug
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\RemoteDesktopServices-RemoteFX-SessionLicensing-Debug" -Force

    # Remove registry key: ChannelReferences\2
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Publishers\{10ab3154-c36a-4f24-9d91-ffb5bcd331ef}\ChannelReferences\2" -Force

    # Remove registry key: EventLog-RemoteDesktopServices-RemoteFX-SessionLicensing-Debug
    Remove-Item -Path "HKLM:\SYSTEM\ControlSet001\Control\WMI\Autologger\EventLog-RemoteDesktopServices-RemoteFX-SessionLicensing-Debug" -Recurse -Force -ErrorAction SilentlyContinue  
}

# START
DisplayLISTOPTIONS
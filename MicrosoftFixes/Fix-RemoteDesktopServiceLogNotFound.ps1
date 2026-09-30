##########################################################################################################################
### Tech Team Solutions - Fix RemoteDesktopServices-RemoteFX-SessionLicensing-Debug Error
### Last Updated 2025.07.21
### Written by ESS
##########################################################################################################################

# Remove registry key: RemoteDesktopServices-RemoteFX-SessionLicensing-Debug
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\RemoteDesktopServices-RemoteFX-SessionLicensing-Debug" -Force

# Remove registry key: ChannelReferences\2
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Publishers\{10ab3154-c36a-4f24-9d91-ffb5bcd331ef}\ChannelReferences\2" -Force

# Remove registry key: EventLog-RemoteDesktopServices-RemoteFX-SessionLicensing-Debug
Remove-Item -Path "HKLM:\SYSTEM\ControlSet001\Control\WMI\Autologger\EventLog-RemoteDesktopServices-RemoteFX-SessionLicensing-Debug" -Recurse -Force -ErrorAction SilentlyContinue




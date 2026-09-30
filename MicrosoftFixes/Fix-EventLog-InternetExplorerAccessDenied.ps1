##########################################################################################################################
### Tech Team Solutions - Fix Event Viewer - Internet Explorer Access Denied Error
### Last Updated 2025.08.04
### Written by ESS
##########################################################################################################################

Remove-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Internet Explorer" -Recurse -Force -ErrorAction SilentlyContinue
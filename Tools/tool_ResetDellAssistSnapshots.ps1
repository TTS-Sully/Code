##########################################################################################################################
### Tech Team Solutions - reset DELL Assist Snapshots
### Last Updated 2025.09.26
### Written by ESS
##########################################################################################################################

Stop-Service -Name "SafeServiceHandle" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "SupportAssistAgent" -Force -ErrorAction SilentlyContinue

Remove-Item -Path "C:\Users\All Users\Dell\SARemediation\SystemRepair\Snapshots\*" -Recurse -Force -ErrorAction SilentlyContinue

Start-Service -Name "SafeServiceHandle" -ErrorAction SilentlyContinue
Start-Service -Name "SupportAssistAgent" -ErrorAction SilentlyContinue
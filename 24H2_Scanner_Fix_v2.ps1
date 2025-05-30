#Services that need to be stopped and started for the fix to work
# This script is designed to fix the scanner issue in Windows 11 24H2
# 
# reference:
# Get-Service -Name "ServiceName" | Select-Object *
# Set-Service -Name "ServiceName" -StartupType Automatic

# Windows Image Acquisition (WIA)
Set-Service -Name "StiSvc" -StartupType Automatic
Restart-Service -Name "StiSvc" -Force

# Shell Hardware Detection
Set-Service -Name "ShellHWDetection" -StartupType Automatic
Restart-Service -Name "ShellHWDetection" -Force

# Remote Procedure Call (RPC)
# NOTE: Editing the RPC service is problamatic because of the dependencies it has.
# Set-Service -Name "RpcSs" -StartupType Automatic
# Restart-Service -Name "RpcSs" -Force
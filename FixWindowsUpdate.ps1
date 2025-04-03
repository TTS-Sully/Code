#https://docs.microsoft.com/en-us/windows/deployment/update/windows-update-resources

# Stopping Windows Update Services
Stop-Service -Name BITS -Force
Stop-Service -Name wuauserv 
Stop-Service -Name appidsvc 
Stop-Service -Name cryptsvc -Force
 
# Remove QMGR Data file
Remove-Item "$env:allusersprofile\Application Data\Microsoft\Network\Downloader\qmgr*.dat" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:allusersprofile\Microsoft\Network\Downloader\qmgr*.dat" -Force -ErrorAction SilentlyContinue
 
# Renaming the Software Distribution and CatRoot Folder
# Remove-Item "$env:systemroot\SoftwareDistribution" -Force -Recurse -ErrorAction SilentlyContinue 
Rename-Item "$env:systemroot\SoftwareDistribution" "$env:systemroot\SoftwareDistribution-$(Get-Date -Format "yyyy-MM-dd")"
Remove-Item "$env:systemroot\System32\Catroot2" -Force -Recurse -ErrorAction SilentlyContinue 
 
# Removing old Windows Update log 
Remove-Item "$env:systemroot\WindowsUpdate.log" -Force -ErrorAction SilentlyContinue 
 
# Resetting the Windows Update Services to defualt settings
"sc.exe sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)" 
"sc.exe sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"

# Reregistering the BITS files and the Windows Update files  
Set-Location $env:systemroot\system32 
regsvr32.exe /s atl.dll 
regsvr32.exe /s urlmon.dll 
regsvr32.exe /s mshtml.dll 
regsvr32.exe /s shdocvw.dll 
regsvr32.exe /s browseui.dll 
regsvr32.exe /s jscript.dll 
regsvr32.exe /s vbscript.dll 
regsvr32.exe /s scrrun.dll 
regsvr32.exe /s msxml.dll 
regsvr32.exe /s msxml3.dll 
regsvr32.exe /s msxml6.dll 
regsvr32.exe /s actxprxy.dll 
regsvr32.exe /s softpub.dll 
regsvr32.exe /s wintrust.dll 
regsvr32.exe /s dssenh.dll 
regsvr32.exe /s rsaenh.dll 
regsvr32.exe /s gpkcsp.dll 
regsvr32.exe /s sccbase.dll 
regsvr32.exe /s slbcsp.dll 
regsvr32.exe /s cryptdlg.dll 
regsvr32.exe /s oleaut32.dll 
regsvr32.exe /s ole32.dll 
regsvr32.exe /s shell32.dll 
regsvr32.exe /s initpki.dll 
regsvr32.exe /s wuapi.dll 
regsvr32.exe /s wuaueng.dll 
regsvr32.exe /s wuaueng1.dll 
regsvr32.exe /s wucltui.dll 
regsvr32.exe /s wups.dll 
regsvr32.exe /s wups2.dll 
regsvr32.exe /s wuweb.dll 
regsvr32.exe /s qmgr.dll 
regsvr32.exe /s qmgrprxy.dll 
regsvr32.exe /s wucltux.dll 
regsvr32.exe /s muweb.dll 
regsvr32.exe /s wuwebv.dll 
 
# Removing WSUS client settings
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v AccountDomainSid /f 
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v PingID /f 
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v SusClientId /f 
#REG DELETE "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /f
#REG DELETE "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\WindowsUpdate" /f
#REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /f
#REG DELETE "HKLM\SOFTWARE\WOW6432Node\Microsoft\WindowsUpdate" /f
 
# Resetting the WinSock
#netsh winsock reset 
#netsh winhttp reset proxy 
 
# Delete all BITS jobs
Get-BitsTransfer | Remove-BitsTransfer 
 
 
# Starting Windows Update Services 
Start-Service -Name BITS 
Start-Service -Name wuauserv 
Start-Service -Name appidsvc 
Start-Service -Name cryptsvc 

# Force Group Policy Update
gpupdate /force /wait:0
 
#Forcing discovery
wuauclt /resetauthorization /detectnow
#WUAUClt /updatenow
#WUAUClt /SelfUpdateUnmanaged
USOCLIENT.EXE RefreshSettings
USOCLIENT.EXE StartScan
USOClient.exe ScanInstallWait 
USOClient.exe StartInstall
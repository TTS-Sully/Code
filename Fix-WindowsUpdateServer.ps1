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
Rename-Item "$env:systemroot\SoftwareDistribution" "$env:systemroot\SoftwareDistribution-$(Get-Date -Format "yyyy-MM-dd-HHmmss")" -ErrorAction SilentlyContinue
Remove-Item "$env:systemroot\System32\Catroot2" -Force -Recurse -ErrorAction SilentlyContinue 
 
# Removing old Windows Update log 
Remove-Item "$env:systemroot\WindowsUpdate.log" -Force -ErrorAction SilentlyContinue 

# Resetting the Windows Update Services to defualt settings
"sc.exe sdset bits D:(A;CI;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;IU)(A;;CCLCSWLOCRRC;;;SU)"
"sc.exe sdset wuauserv D:(A;;CCLCSWRPLORC;;;AU)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;SY)"

# Reregistering the BITS files and the Windows Update files  
Set-Location $env:systemroot\system32 
regsvr32.exe atl.dll
regsvr32.exe urlmon.dll
regsvr32.exe mshtml.dll
regsvr32.exe shdocvw.dll
regsvr32.exe browseui.dll
regsvr32.exe jscript.dll
regsvr32.exe vbscript.dll
regsvr32.exe scrrun.dll
regsvr32.exe msxml.dll
regsvr32.exe msxml3.dll
regsvr32.exe msxml6.dll
regsvr32.exe actxprxy.dll
regsvr32.exe softpub.dll
regsvr32.exe wintrust.dll
regsvr32.exe dssenh.dll
regsvr32.exe rsaenh.dll
regsvr32.exe gpkcsp.dll
regsvr32.exe sccbase.dll
regsvr32.exe slbcsp.dll
regsvr32.exe cryptdlg.dll
regsvr32.exe oleaut32.dll
regsvr32.exe ole32.dll
regsvr32.exe shell32.dll
regsvr32.exe initpki.dll
regsvr32.exe wuapi.dll
regsvr32.exe wuaueng.dll
regsvr32.exe wuaueng1.dll
regsvr32.exe wucltui.dll
regsvr32.exe wups.dll
regsvr32.exe wups2.dll
regsvr32.exe wuweb.dll
regsvr32.exe qmgr.dll
regsvr32.exe qmgrprxy.dll
regsvr32.exe wucltux.dll
regsvr32.exe muweb.dll
regsvr32.exe wuwebv.dll

# Resetting Winsock
netsh winsock reset
 
# Delete all BITS jobs
Get-BitsTransfer | Remove-BitsTransfer 
 
# Starting Windows Update Services 
Start-Service -Name BITS 
Start-Service -Name wuauserv 
Start-Service -Name appidsvc 
Start-Service -Name cryptsvc
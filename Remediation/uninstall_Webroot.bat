sc delete WRSkyClient
sc delete WRCoreService
sc delete WRSVC
del /f "C:\windows\system32\drivers\wrkrn.sys"
del /f "C:\windows\system32\wruser.dll"
del /f "C:\program files\webroot\*.*
del /f "C:\Program Files (x86)\Webroot\*.*"
del /f "C:\ProgramData\WRCore\*.*"
del /f "C:\ProgramData\WRData\*.*"
rd /s /q "C:\ProgramData\WRData\"
rd /s /q "C:\Program Files\Webroot\"
rd /s /q "C:\Program Files (x86)\Webroot\"
rd /s /q "C:\ProgramData\WRCore\"
reg Delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WRUNINST" /f
reg Delete "HKLM\SOFTWARE\WRData" /f
reg Delete "HKLM\SYSTEM\ControlSet001\services\WRSVC" /f
reg Delete "HKLM\SYSTEM\ControlSet002\services\WRSVC" /f
reg Delete "HKLM\SYSTEM\CurrentControlSet\services\WRSVC" /f
reg delete "HKLM\SOFTWARE\WOW6432Node\Webroot" /f
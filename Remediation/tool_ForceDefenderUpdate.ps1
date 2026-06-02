# Force Microsoft Defender engine update 64bit
Update-MpSignature

# Update the Defender platform if an update is available
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?LinkID=121721&arch=x64" -OutFile "$env:TEMP\Mpam-feX64.exe"
Start-Process "$env:TEMP\Mpam-feX64.exe" -ArgumentList "/quiet" -Wait

# Gives defender version
Get-MpComputerStatus | Select-Object AntivirusSignatureVersion, AntivirusSignatureLastUpdated, AntispywareSignatureVersion,  AntispywareSignatureLastUpdated
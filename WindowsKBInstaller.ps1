# KB URL
#$fileUrl = "https://catalog.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/beae415c-d56f-477c-9a3a-3aa4336890f6/public/windows11.0-kb5055523-x64_b1df8c7b11308991a9c45ae3fba6caa0e2996157.msu"
$fileUrl = "https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/updt/2019/02/windows10.0-kb4482887-x64_826158e9ebfcabe08b425bf2cb160cd5bc1401da.msu"
# SAVEPATH

$destinationFolder = "C:\TTS"
# Create the folder if it doesn't exist
if (!(Test-Path $destinationFolder)) {
    New-Item -ItemType Directory -Path $destinationFolder -Force
}
 
# Download the file to the specified folder
Invoke-WebRequest -Uri $fileUrl -OutFile "$destinationFolder\kb4482887.msu"

DISM /Online /Add-Package /PackagePath:c:\tts\kb4482887.msu
 
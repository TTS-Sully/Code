Write-Host "Attempting to set Metadata Service URL..."
#Error 131 metadata resolution
try {
  Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata' -Name DeviceMetadataServiceURL -Value 'http://dmd.metaservices.microsoft.com/dms/metadata.svc'
  Write-Host "Metadata URL has been set"
  exit 0
} catch {
  Write-Host "A Unknown Problem Has Occured"
  exit 2
}
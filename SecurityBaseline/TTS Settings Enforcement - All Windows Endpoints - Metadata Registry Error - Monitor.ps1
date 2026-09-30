Write-Host "Checking for Metadata Error..."
#Monitoring for discrepency that causes the Windows 131 Error regarding Device Metadata
try {
    $testkey = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata'
    if($testkey -ne $null){
        if($testkey.DeviceMetadataServiceURL -ne 'http://dmd.metaservices.microsoft.com/dms/metadata.svc'){
            Write-Host "Metadata Settings are Incorrect"
            exit 1
        } else {
            Write-Host "Metadata Settings are Correct"
            exit 0
        }
    }
} catch {
    Write-Host "An Unknown Error Has Occured"
    exit 2
}
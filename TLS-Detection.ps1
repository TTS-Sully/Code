# Define the registry path
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"

# Get all child keys
$childKeys = Get-ChildItem -Path $regPath

# Display the child keys
foreach ($key in $childKeys) {
    $testkey = $key.Name
    if($testkey -ne $null){
        if($testkey -like 'TLS 1.2'){
            Write-Output "TLS 1.2 is not enabled"
            #exit 1
        } else {
            Write-Output "TLS 1.2 is enabled"
            #exit 0
        }
    }
}
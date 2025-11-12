# Get all installed antivirus products
Write-Host "Listing installed antivirus products..."
$avProducts = Get-WmiObject -Namespace "root\SecurityCenter2" -Class AntiVirusProduct

# Display the results
$avProducts | Format-Table displayName, instanceGuid, pathToSignedProductExe

# Prompt for GUID to delete
$guidToDelete = Read-Host "Enter the instance GUID of the antivirus product to remove"

# Build WMI path for deletion
$wmiPath = "\\localhost\ROOT\SecurityCenter2:AntiVirusProduct.instanceGuid=`"$guidToDelete`""

Write-Host "Attempting to remove antivirus product with GUID: $guidToDelete"

try {
    Remove-WmiObject -Path $wmiPath
    Write-Host "Successfully removed antivirus product with GUID: $guidToDelete"
}
catch {
    Write-Warning "Failed to remove antivirus product. Reason: $($_.Exception.Message)"
}
Write-Host "Antivirus removal script completed."
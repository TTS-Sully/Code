##########################################################################################################################
### Tech Team Solutions - Detect EFI System Partition and Size
### Last Updated 2026.08.18
### Written by ESS
##########################################################################################################################

$efi = Get-Partition |
    Where-Object {
        $_.GptType -eq '{C12A7328-F81F-11D2-BA4B-00A0C93EC93B}'
    } |
    Sort-Object -Property Size -Descending |
    Select-Object -First 1

if ($null -eq $efi) {
    Write-Output '{"EFI":"Not found"}'
    exit 1
}

$sizeBytes = [int64]$efi.Size

$result = [pscustomobject]@{
    EFI             = 'Found'
    DiskNumber      = [int]$efi.DiskNumber
    PartitionNumber = [int]$efi.PartitionNumber
    SizeMB          = [math]::Round($sizeBytes / 1MB, 0)
    SizeBytes       = $sizeBytes
}

$result | ConvertTo-Json -Compress

if ($result.SizeMB -le 150) {
    exit 1
} else {
    exit 0
}
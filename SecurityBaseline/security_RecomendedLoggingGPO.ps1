Import-Module GroupPolicy

$GpoName = "RecomendedLogging"
$CsvPath = "RecomendedLogging.csv"

# Create GPO if it doesn't exist
$GPO = Get-GPO -Name $GpoName -ErrorAction SilentlyContinue
if (-not $GPO) {
    $GPO = New-GPO -Name $GpoName
    Write-Host "Created GPO: $GpoName"
}
else {
    Write-Host "Using existing GPO: $GpoName"
}

# Create temporary backup structure
$TempPath = Join-Path $env:TEMP "RecommendedLoggingGPO"
Remove-Item $TempPath -Recurse -Force -ErrorAction SilentlyContinue

New-Item -ItemType Directory -Path "$TempPath\DomainSysvol\GPO\Machine\Microsoft\Windows NT\Audit" -Force | Out-Null

# Convert Huntress CSV format to audit.csv format expected by GPO
$AuditCsvPath = "$TempPath\DomainSysvol\GPO\Machine\Microsoft\Windows NT\Audit\audit.csv"

Import-Csv $CsvPath | ForEach-Object {
    "$($_.'Subcategory GUID'),$($_.'Setting Value')"
} | Set-Content $AuditCsvPath -Encoding ASCII

# Create minimal backup.xml
@"
<?xml version="1.0" encoding="utf-8"?>
<BackupInst xmlns="http://www.microsoft.com/GroupPolicy/GPOOperations/Manifest">
  <GroupPolicyBackupScheme>SinglePolicy</GroupPolicyBackupScheme>
</BackupInst>
"@ | Set-Content "$TempPath\bkupInfo.xml"

# Backup existing GPO to obtain valid structure
$BackupPath = Join-Path $env:TEMP "GpoBackup"
Remove-Item $BackupPath -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory $BackupPath | Out-Null

Backup-GPO -Guid $GPO.Id -Path $BackupPath | Out-Null

# Locate backup folder
$BackupFolder = Get-ChildItem $BackupPath | Where-Object { $_.PSIsContainer } | Select-Object -First 1

# Replace audit.csv in backup
$AuditTarget = Join-Path $BackupFolder.FullName "DomainSysvol\GPO\Machine\Microsoft\Windows NT\Audit"
New-Item -ItemType Directory -Path $AuditTarget -Force | Out-Null
Copy-Item $AuditCsvPath "$AuditTarget\audit.csv" -Force

# Import settings into GPO
Import-GPO `
    -BackupId $BackupFolder.Name `
    -TargetGuid $GPO.Id `
    -Path $BackupPath `
    -CreateIfNeeded

Write-Host "Advanced Audit Policy imported into GPO '$GpoName'"
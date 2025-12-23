# Requires elevation
$currUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currUser)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator. Right-click PowerShell and select 'Run as administrator'."
    exit 1
}

$regPath    = 'HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Internet Explorer'
$valueName  = 'CustomSD'
$newSDDL    = 'O:BAG:SYD:(A;;0x07;;;WD)S:(ML;;0x1;;;LW)'

try {
    # Ensure the key exists
    if (-not (Test-Path -Path $regPath)) {
        Write-Error "Registry path not found: $regPath"
        exit 1
    }

    # Read current value (if present)
    $currentSDDL = $null
    $prop = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue
    if ($prop -and ($prop.PSObject.Properties.Name -contains $valueName)) {
        $currentSDDL = $prop.$valueName
    }

    # Backup current SDDL to a file
    $timestamp = (Get-Date).ToString('yyyyMMdd-HHmmss')
    $backupDir = Join-Path $env:ProgramData 'EventLog-SDDL-Backups'
    if (-not (Test-Path $backupDir)) { New-Item -Path $backupDir -ItemType Directory | Out-Null }
    $backupFile = Join-Path $backupDir "IE-EventLog-CustomSD-$timestamp.txt"

    if ($null -ne $currentSDDL) {
        "Registry Path : $regPath`nValue Name    : $valueName`nTimestamp     : $timestamp`nCurrent SDDL  : $currentSDDL" |
            Out-File -FilePath $backupFile -Encoding UTF8
        Write-Host "Backed up current SDDL to: $backupFile" -ForegroundColor Yellow
    } else {
        "Registry Path : $regPath`nValue Name    : $valueName`nTimestamp     : $timestamp`nCurrent SDDL  : (value not present)" |
            Out-File -FilePath $backupFile -Encoding UTF8
        Write-Host "No existing SDDL found. Created placeholder backup: $backupFile" -ForegroundColor Yellow
    }

    # Set the new SDDL
    if ($null -eq $currentSDDL) {
        New-ItemProperty -Path $regPath -Name $valueName -Value $newSDDL -PropertyType String -Force | Out-Null
    } else {
        Set-ItemProperty -Path $regPath -Name $valueName -Value $newSDDL
    }

    # Verify change
    $updatedSDDL = (Get-ItemProperty -Path $regPath).$valueName
    Write-Host "`n--- Result ---" -ForegroundColor Cyan
    Write-Host "Before: $currentSDDL"
    Write-Host "After : $updatedSDDL"

    if ($updatedSDDL -ne $newSDDL) {
        Write-Error "The registry value did not update to the expected SDDL."
        exit 1
    } else {
        Write-Host "`nSDDL successfully updated." -ForegroundColor Green
    }

    # OPTIONAL: Restart the Windows Event Log service to apply permissions immediately.
    # Comment out these lines if you prefer to reboot later.
    $svc = Get-Service -Name 'EventLog' -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -eq 'Running') {
        Write-Host "`nRestarting Windows Event Log service..." -ForegroundColor Cyan
        try {
            Restart-Service -Name 'EventLog' -Force -ErrorAction Stop
            Write-Host "Event Log service restarted." -ForegroundColor Green
        } catch {
            Write-Warning "Could not restart Event Log service automatically. A reboot may be required for changes to fully apply."
        }
    }

} catch {
    Write-Error "Failed to update SDDL. Error: $($_.Exception.Message)"
    exit 1
}
##################################################################################################
# Define paths for Business and Personal accounts
$LogPaths = @(
    "$env:LOCALAPPDATA\Microsoft\OneDrive\logs\Business1\SyncDiagnostics.log",
    "$env:LOCALAPPDATA\Microsoft\OneDrive\logs\Personal\SyncDiagnostics.log"
)

foreach ($Path in $LogPaths) {
    if (Test-Path $Path) {
        $AccountType = if ($Path -like "*Business1*") { "Business" } else { "Personal" }

        Write-Host ""
        Write-Host "==============================" -ForegroundColor Cyan
        Write-Host "Account Type        : $AccountType" -ForegroundColor Cyan
        # Write-Host "Log File     : $Path" -ForegroundColor Cyan

        $StateLine = Select-String -Path $Path -Pattern "SyncProgressState" -List | Select-Object -First 1

        if ($StateLine -and $StateLine.Line -match 'SyncProgressState\s*[:=]\s*(\d+)') {

            $StateCode = [int]$Matches[1]

            # Map the code to its known state
            $Status = switch ($StateCode) {
                0        { "Up-to-Date / Idle" }
                16777216 { "Up-to-Date" }
                65536    { "Paused" }
                8194     { "Not Syncing" }
                1854     { "Syncing Errors Encountered" }
                Default  { "Active / Processing Changes ($StateCode)" }
            }

            Write-Host "Status              : $Status" -ForegroundColor Green
            Write-Host "Raw Code            : $StateCode"
            Write-Host "Last Updated        : $((Get-Item $Path).LastWriteTime)"
        } else {
            Write-Host "SyncProgressState value not found." -ForegroundColor Yellow

            if ($StateLine) {
                Write-Host "Matched line: $($StateLine.Line)"
            }
        }

        $StallDetected = Select-String -Path $Path -Pattern "syncStallDetected" -List | Select-Object -First 1

        if ($StallDetected -and $StallDetected.Line -match 'syncStallDetected\s*[:=]\s*(\d+)') {
            $StallCode = [int]$Matches[1]
            $StallStatus = if ($StallCode -eq 1) { "Yes" } else { "No" }
            Write-Host "Sync Stall Detected : $StallStatus" -ForegroundColor Yellow
        } else {
            Write-Host "Sync stall detection information not found." -ForegroundColor Yellow
        }
    }
}
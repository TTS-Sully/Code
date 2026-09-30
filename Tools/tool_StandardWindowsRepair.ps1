##########################################################################################################################
### Rebuild Windows Component Store
##########################################################################################################################

Start-Process -FilePath sfc -ArgumentList "/scannow" -Wait -NoNewWindow

$commands = @(
    "/Cleanup-Mountpoints",
    "/Online /Cleanup-Image /ScanHealth",
    "/Online /Cleanup-Image /RestoreHealth",
    "/Online /Cleanup-Image /StartComponentCleanup /ResetBase"
)

foreach ($cmd in $commands) {
    Write-Host "Running: DISM $cmd"
    Start-Process -FilePath "DISM.exe" -ArgumentList $cmd -Verb RunAs -Wait
}
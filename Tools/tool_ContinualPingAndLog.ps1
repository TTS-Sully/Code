$IPAddress = "9.0.0.15"
$LogFile = "c:\tts\"

while ($true) {
    $PingResult = Test-Connection -ComputerName $IPAddress -Count 1 -ErrorAction SilentlyContinue
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Status = if ($PingResult) { "SUCCESS" } else { "FAILED" }
    $LogEntry = $TimeStamp + "- Ping to " + $IPAddress + ":" + $Status
    Write-Host $LogEntry
    Add-Content -Path $LogFile -Value $LogEntry

    Start-Sleep -Seconds 10 
}
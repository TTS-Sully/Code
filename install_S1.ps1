$msiPath = "SentinelAgent.msi"
$siteToken = $env:usrS1Token
$logPath = "C:\TTS\LOGS\SentinelOne"

New-Item -Path $logPath -ItemType Directory -Force

# Start the msiexec process
$process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$msiPath`" SITE_TOKEN=`"$siteToken`" /quiet /norestart /L*v $logPath\log.log" -PassThru
# Output the process ID
Write-Host "SentinelOne installation started with msiexec PID: $($process.Id)"
while(get-process -Id $process.Id -ErrorAction SilentlyContinue) {
    Start-Sleep -Seconds 5
}

$question = get-service -Name "SentinelAgent" -ErrorAction SilentlyContinue
if ($question.Status -eq 'Running') {
    Write-Host "SentinelOne Agent installed and running successfully."
    exit 0
} else {
    Write-Host "SentinelOne Agent installation failed or the service is not running."
    exit 1
}

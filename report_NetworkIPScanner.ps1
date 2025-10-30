# Prompt for IP range
#$ipSTART = Read-Host "Enter starting IP (or press Enter to auto-detect)"
#$ipEND = Read-Host "Enter ending IP (or press Enter to auto-detect)"

$ipSTART = $env:IPRangeStart
$ipEND = $env:IPRangeEnd


# Ensure log folder exists
$logFolder = "C:\tts"
if (-not (Test-Path $logFolder)) {
    New-Item -Path $logFolder -ItemType Directory | Out-Null
}

# Create log file with timestamp
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = "$logFolder\IPScanLog_$timestamp.txt"

# Function to test IP range
function Test-IPRange {
    param (
        [string]$startIP,
        [string]$endIP
    )

    $ipArrayStart = $startIP -split "\."
    $ipArrayEnd = $endIP -split "\."

    for ($i = [int]$ipArrayStart[0]; $i -le [int]$ipArrayEnd[0]; $i++) {
        for ($j = [int]$ipArrayStart[1]; $j -le [int]$ipArrayEnd[1]; $j++) {
            for ($k = [int]$ipArrayStart[2]; $k -le [int]$ipArrayEnd[2]; $k++) {
                for ($l = [int]$ipArrayStart[3]; $l -le [int]$ipArrayEnd[3]; $l++) {
                    $currentIP = "$i.$j.$k.$l"
                    $ping = Test-Connection -ComputerName $currentIP -Count 1 -Quiet
                    if ($ping) {
                        try {
                            $hostname = [System.Net.Dns]::GetHostEntry($currentIP).HostName
                        } catch {
                            $hostname = "Unknown"
                        }
                        $logEntry = "$currentIP is reachable - Hostname: $hostname"
                        Write-Host $logEntry -ForegroundColor Green
                        Add-Content -Path $logFile -Value $logEntry
                    }
                }
            }
        }
    }
}

# If IPs are not provided, auto-detect NICs and generate ranges
if ([string]::IsNullOrWhiteSpace($ipSTART) -or [string]::IsNullOrWhiteSpace($ipEND)) {
    $nics = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
        $_.IPAddress -notlike "169.254.*" -and $_.IPAddress -notlike "127.*"
    }

    foreach ($nic in $nics) {
        $ipParts = $nic.IPAddress -split "\."
        $subnetStart = "$($ipParts[0]).$($ipParts[1]).$($ipParts[2]).0"
        $subnetEnd = "$($ipParts[0]).$($ipParts[1]).$($ipParts[2]).255"

        Test-IPRange $subnetStart $subnetEnd
    }
} else {
    Test-IPRange $ipSTART $ipEND
}

Write-Host "Scan complete. Results saved to $logFile" -ForegroundColor Cyan
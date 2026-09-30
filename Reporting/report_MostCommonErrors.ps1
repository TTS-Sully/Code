# Top 10 Windows Event Log Errors from All Logs in the Last 12 Hours

$HoursBack = 12
$StartTime = (Get-Date).AddHours(-$HoursBack)

# Get all enabled logs
$LogNames = Get-WinEvent -ListLog * -ErrorAction SilentlyContinue |
    Where-Object { $_.IsEnabled } |
    Select-Object -ExpandProperty LogName

$results = Get-WinEvent -FilterHashtable @{
    LogName   = $LogNames
    Level     = 2
    StartTime = $StartTime
} -ErrorAction SilentlyContinue |
    Group-Object {
        "$($_.ProviderName)|$($_.Id)|$(($_.Message -split "`r?`n")[0])"
    } |
    Sort-Object Count -Descending |
    Select-Object -First 10

if (!$results) {
    Write-Output "No errors found in last $HoursBack hours"
    exit 0
}

foreach ($item in $results) {
    $parts = $item.Name.Split('|')
    "{0,-5} | {1,-35} | {2,-8} | {3}" -f "$($item.Count)x", $parts[0], $parts[1], $parts[2]
}
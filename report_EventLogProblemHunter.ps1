Clear-Host

$startTime = (Get-Date).AddDays(-1)

# List of event IDs to search for
$eventIds = @(5008, 2002, 4012, 3041, 8230, 1023)

# Initialize a dictionary to hold results
$errorDetails = @{}
$logContent = ""

# Get all enabled logs
$allLogs = Get-WinEvent -ListLog * | Where-Object { $_.IsEnabled }

foreach ($log in $allLogs) {
    foreach ($eventId in $eventIds) {
        try {
            # Redirect error stream to $null to suppress warnings
            $events = Get-WinEvent -FilterHashtable @{
                LogName = $log.LogName
                Id = $eventId
                StartTime = $startTime
            } -ErrorAction SilentlyContinue

            $count = $events.Count
            if ($count -gt 0) {
                $key = "${eventId} in ${log.LogName}"
                $errorDetails[$key] = $count
                $logContent += "Event ID ${eventId} found in ${log.LogName}: ${count}`n"
            }
        } catch {
            # Silently skip logs that can't be read
            continue
        }
    }
}

# Output only if events were found
if ($logContent) {
    Write-Host $logContent
} else {
    Write-Host "No matching events found in the past 24 hours."
}

# Exit with code 1 if any errors were found
if ($errorDetails.Count -gt 0) {
    exit 1
} else {
    exit 0
}
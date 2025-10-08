Clear-Host
# Define the time range
$startDate = (Get-Date).AddHours(-10)

# Get all logs that might be relevant to desktop activity
#$logs = Get-WinEvent -ListLog * | Where-Object { $_.LogName -like "*Desktop*" }
$logs = Get-WinEvent -ListLog *

# Collect error events from each log
$allErrors = foreach ($log in $logs) {
    try {
        Get-WinEvent -FilterHashtable @{
            LogName = $log.LogName
            Level = 2  # Error level
            StartTime = $startDate
        } -ErrorAction Stop
    } catch {
        # Skip logs that can't be queried
        Write-Verbose "Skipping log: $($log.LogName)"
    }
}

# Flatten the results and filter unique errors
$uniqueErrors = $allErrors | Select-Object -Property Id, Message, ProviderName, TimeCreated -Unique

# Display the results
$uniqueErrors | Format-Table -AutoSize
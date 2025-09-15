##########################################################################################################################
### Tech Team Solutions All Unique Failed Logins Report
### Last Updated 2025.09.15
### Written by ESS
##########################################################################################################################

# Define the time range for the search
$startTime = (Get-Date).AddMonths(-1)  # Adjust as needed

# Get all 4625 events from the Security log
$events = Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    ID = 4625
    StartTime = $startTime
}

# Extract relevant properties and create custom objects
$parsedEvents = $events | ForEach-Object {
    [PSCustomObject]@{
        TimeCreated   = $_.TimeCreated
        AccountName   = $_.Properties[5].Value
        SourceIP      = $_.Properties[18].Value
        FailureReason = $_.Properties[23].Value
    }
}

if($parsedEvents.Count -eq 0) {
    Write-Output "No failed login events found in the specified time range."
    Exit 1
} else {
    # Filter out events with missing SourceIP or AccountName
    $filteredEvents = $parsedEvents | Where-Object {
        $_.SourceIP -and $_.AccountName
    }

    # Get unique events based on SourceIP and AccountName
    $uniqueEvents = $filteredEvents | Sort-Object SourceIP, AccountName | Get-Unique -AsString

    # Display the results
    $uniqueEvents | Format-Table -AutoSize
    Exit 0
}


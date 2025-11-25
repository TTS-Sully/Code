# Define the wildcard pattern for the account name
$wildcardPattern = $env:PatternToHunt

# Define the event ID for failed logons (Event ID 4625)
$eventID = 4625

# Get failed logon events from the Security log
$events = Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    Id = $eventID
} -MaxEvents 1000

# Parse and filter events
$filteredEvents = foreach ($event in $events) {
    $xml = [xml]$event.ToXml()
    $accountName = $xml.Event.EventData.Data | Where-Object { $_.Name -eq "TargetUserName" } | Select-Object -ExpandProperty '#text'
    
    if ($accountName -like $wildcardPattern) {
        $ipAddress = $xml.Event.EventData.Data | Where-Object { $_.Name -eq "IpAddress" } | Select-Object -ExpandProperty '#text'
        [PSCustomObject]@{
            TimeCreated = $event.TimeCreated
            AccountName = $accountName
            IPAddress = $ipAddress
            WorkstationName = $xml.Event.EventData.Data | Where-Object { $_.Name -eq "WorkstationName" } | Select-Object -ExpandProperty '#text'
        }
    }
}

# Output the results
$filteredEvents | Format-Table -AutoSize

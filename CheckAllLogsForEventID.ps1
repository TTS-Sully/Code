# Define the event ID you want to search for
#$EventID = $env:EventIDToFind
$EventID = 2

# Get all event logs on the system
$EventLogs = Get-EventLog -List

# Loop through each event log and search for the event ID
foreach ($Log in $EventLogs) {
    $Events = Get-EventLog -LogName $Log.Log -InstanceId $EventID -ErrorAction SilentlyContinue
    if ($Events) {
        #Write-Host "Found events with the specified ID"
        exit 0
    } else {
        #Write-Host "Found no events with the specified ID in this log"
    }
}
##########################################################################################################################
### Tech Team Solutions Windows Event Log Hunter
### Last Updated 2025.07.16
### Written by ESS
##########################################################################################################################
# Define the event ID you want to search for
$EventID = $env:EventIDToFind
#$EventID = 2
$EventWindow = $env:EventWindow #in minutes
#$EventWindow = 24

# Get all event logs on the system
$EventLogs = Get-EventLog -List

# Loop through each event log and search for the event ID
foreach ($Log in $EventLogs) {
    
$Events = Get-EventLog -LogName $Log.Log -InstanceId $EventID -After (Get-Date).AddMinutes(-($EventWindow)) -ErrorAction SilentlyContinue

    if ($Events) {
        Write-Host "Found events with the specified ID"
        exit 0
    } else {
        #Write-Host "Found no events with the specified ID in this log"
    }
}
Write-Host "Found No Events"
exit 1
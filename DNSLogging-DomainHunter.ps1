# Define the domain to search for
$domain = "btloader.com"

# Get DNS client events from the operational log
$events = Get-WinEvent -LogName "Microsoft-Windows-DNS-Client/Operational" -FilterXPath "*[System/EventID=3006]"

# Filter events for the specified domain
$filteredEvents = $events | Where-Object { $_.Message -like "*$domain*" }

# Define the CSV file path
$csvFilePath = "dns_client_events.csv"

# Export the filtered events to a CSV file
$filteredEvents | Select-Object TimeCreated, Message | Export-Csv -Path $csvFilePath -NoTypeInformation

Write-Output "Filtered DNS client events have been exported to $csvFilePath."
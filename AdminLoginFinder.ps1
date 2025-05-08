############################################################################################################################################
# WORK IN PROGRESS
# This script retrieves failed login attempts from the Windows Event Log and displays the account names and computer names involved.
# It uses the Get-EventLog cmdlet to filter for event ID 4625, which corresponds to failed login attempts.
# The script then formats and outputs the relevant information for each failed login attempt.
# Created by: Erik S. Sullivan for Tech Team Solutions
# Date: 2025-05-08
############################################################################################################################################

# Define the event log and event ID for failed login attempts
$logName = "Security"
$eventID = 4625

# Get the failed login attempts from the event log
$failedLogins = Get-EventLog -LogName $logName -InstanceId $eventID -ErrorAction SilentlyContinue

# Display the results
foreach ($attempt in $failedLogins) {
    $accountName = $attempt.ReplacementStrings[5]
    $computerName = $attempt.ReplacementStrings[18]
    $timeGenerated = $attempt.TimeGenerated
    Write-Output "Failed login attempt by $accountName from $computerName at $timeGenerated"
}

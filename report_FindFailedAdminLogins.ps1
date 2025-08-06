##########################################################################################################################
### Tech Team Solutions - report back failed logins for Administrator account
### Last Updated 2025.08.06
### Written by ESS
##########################################################################################################################
# Define the time range for the search
$startTime = (Get-Date).AddDays(-365)  # Last 24 hours
$adminUser = "Administrator"

# Search Security Event Log for failed logon attempts using the Administrator account
Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    ID = 4625  # Failed logon
    StartTime = $startTime
} | Where-Object {
    $_.Properties[5].Value -eq $adminUser -or $_.Properties[1].Value -eq $adminUser
} | Select-Object TimeCreated, @{Name="AccountName";Expression={$_.Properties[5].Value}}, @{Name="SourceIP";Expression={$_.Properties[18].Value}}, @{Name="FailureReason";Expression={$_.Properties[23].Value}} | Format-Table -AutoSize

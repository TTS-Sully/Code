Set-Executionpolicy -ExecutionPolicy unrestricted

# Connect to Exchange Online
# Connect-ExchangeOnline -UserPrincipalName 

$TimeStamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$ReportPath = "C:\tts\ExchangeLitigationHoldReport_$TimeStamp.csv"

# Export Litigation Hold report
Get-Mailbox -ResultSize Unlimited | Select-Object @{
        Name = 'UserPrincipalName'
        Expression = {$_.UserPrincipalName}
    },@{
        Name = 'LitigationHoldEnabled'
        Expression = {$_.LitigationHoldEnabled}
    },@{
        Name = 'LitigationHoldDate'
        Expression = {$_.LitigationHoldDate}
    } | Export-Csv -Path $ReportPath -NoTypeInformation

Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Report exported to $ReportPath"




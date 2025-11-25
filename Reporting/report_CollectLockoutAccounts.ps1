#Collect lockout accounts from ADS

$logname = "security"
$dcname = (Get-AdDomain).pdcemulator
$eventID = "4740"
$content = Get-EventLog -LogName $logname -ComputerName $dcname -After (Get-Date).AddDays(-1) -InstanceId $eventID | Select-Object TimeGenerated, ReplacementStrings
$ofs = "`r`n`r`n"
$body = "Fetching event log started on " + (Get-Date) + $ofs

If ($null -eq $content) {
    $body = $body + "No lock-out accounts happened today" + $ofs
} Else {
    Foreach ($ofevent in $content) {
        $source = $content.ReplacementStrings[1]
        $username = $content.ReplacementStrings[0]
        $body = $body + $ofevent.TimeGenerated + ": " + $username + " - " + $source + $ofs
    }
}
$body
cls
$processresults = Get-NetTcpConnection | Select-Object Local*,Remote*,State,@{Name="Process";Expression={(Get-Process -Id $_.OwningProcess).ProcessName}} | Where-Object{$_.Process -eq "HuntressAgent"}

if($processresults.count -eq 0){
    Write-Output "Huntress Agent is not running"
    #Exit 1
} else {
    $out = ""
    foreach($result in $processresults){
        $out += $result.State + ": " + $result.LocalPort + ", "
    }
    Write-Output "Huntress Agent is using: $out"
    #Exit 0
}
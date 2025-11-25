$startDate = (Get-Date).AddDays(-30)

Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    Id = 4648
    StartTime = $startDate
} | ForEach-Object {
    [PSCustomObject]@{
        TimeCreated = $_.TimeCreated
        Message     = $_.Message
    }
}
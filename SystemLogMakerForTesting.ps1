$evt = new-object System.Diagnostics.EventLog("Application")
$evt.Source = "MyEvent"
$infoevent = [System.Diagnostics.EventLogEntryType]::Information

for($i=0; $i -lt 1000; $i++){
    $evt.WriteEntry("My Test Event",$infoevent,70)
}
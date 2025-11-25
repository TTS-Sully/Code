# Get the hostname
$hostname = $env:COMPUTERNAME
# Define the base registry path
$basePath = "HKLM:\Software\CaseWare\Working Papers"

# Output CSV file path
$csvPath = "c:\tts\logs\settings\CWKS_Registrations_Log.csv"

# Initialize an array to hold log entries
$logEntries = @()

# Get all subkeys under the base path (these should be version numbers)
$versionKeys = Get-ChildItem -Path $basePath

foreach ($versionKey in $versionKeys) {
    $version = $versionKey.PSChildName
    $registrationPath = Join-Path $versionKey.PSPath "CWLS\Registrations"

    if (Test-Path $registrationPath) {
        # Get all subkeys and values under the registration path
        Get-ChildItem -Path $registrationPath -Recurse | ForEach-Object {
            $keyPath = $_.Name
            $properties = Get-ItemProperty -Path $_.PSPath

            foreach ($property in $properties.PSObject.Properties) {
                $logEntries += [PSCustomObject]@{
                    Hostname       = $hostname
                    VersionKey     = $version
                    RegistryKey    = $keyPath
                    PropertyName   = $property.Name
                    PropertyValue  = $property.Value
                }
            }
        }
    }
}

# Export to CSV
$logEntries | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

Write-Host "Log saved to: $csvPath"

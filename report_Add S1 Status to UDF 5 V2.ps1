#https://github.com/Jonathan-Bullock/Datto-RMM-UDF-Fields/blob/main/S1%20Status%20to%20UDF%205.ps1
#find current version Config File

# Check if SentinelOne directory exists
if (!(Test-Path "C:\Program Files\SentinelOne\")) {
    Write-Error "C:\Program Files\SentinelOne\ doesn't exist. Exiting early..."
    exit 1
}

# Find all sentinelctl files
$folders = Get-ChildItem -Path "C:\Program Files\SentinelOne\" -Recurse -Filter *sentinelctl*

# Create an array of objects with Version and FullPath
$folderVersions = foreach ($folder in $folders) {
    if ($folder.FullName -match '\d+(\.\d+){3}') {
        $versionString = $matches[0]

        # Build custom object with Version and FullPath
        [PSCustomObject]@{
            Version   = [Version]$versionString
            FullPath  = $folder.FullName
            Directory = $folder.DirectoryName
        }
    }
}

# Sort by Version and get the highest version
$highestFolder = $folderVersions | Sort-Object Version -Descending | Select-Object -First 1

# Change location to the directory of the highest version
Set-Location $highestFolder.Directory

$s1_mgmtServer = .\sentinelctl configure server.mgmtServer
$S1_Site = .\sentinelctl configure server.site
$S1_vssSnapshots  = .\sentinelctl configure agent.vssSnapshots 

#Build String
$udf = "VSS Snapshots: " + $S1_vssSnapshots + ", Site ID: " + $S1_Site + ", MGMT SVR: " +$s1_mgmtServer
#write sting to terminal
$udf

#Write to registry for Datto RMM UDF
Set-ItemProperty "HKLM:\Software\CentraStage" -Name "Custom5$env:usrUDF5" -Value $udf

#used for Performance Tracking
Get-Date
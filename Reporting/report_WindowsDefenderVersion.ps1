$reportMESSAGE = ""
$reportERRORS = 0
if($null -eq $env:EngineVersion -and $null -eq $env:ProductVersion){
    Write-Host "No version requirements specified, skipping the rest of the script."
    exit 0
}

if ($null -ne $env.EngineVersion) {
    $currentENGINEVERSION=[version](Get-MpComputerStatus).AMEngineVersion
    if ($currentENGINEVERSION -lt [version]$env:EngineVersion) {
        $reportMESSAGE += "Engine version is $currentENGINEVERSION and is outdated. "
        $reportERRORS ++
    }
}

if ($null -ne $env:ProductVersion) {
    $currentPRODUCTVERSION=[version](Get-MpComputerStatus).AMProductVersion
    if ($currentPRODUCTVERSION -lt [version]$env:ProductVersion) {
        $reportMESSAGE += "Product version is $currentPRODUCTVERSION and is outdated. "
        $reportERRORS ++
    }
}

if($reportERRORS -gt 0){
    Write-Host $reportMESSAGE
    exit 1
} else {
    Write-Host "Windows Defender Does not match any of these requirements."
    exit 0
}
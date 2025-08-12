##########################################################################################################################
### Tech Team Solutions - Find Administrator in Local Security Cache
### Last Updated 2025.08.06
### Written by ESS
##########################################################################################################################
# Get domain information
$computerSystem = Get-WmiObject Win32_ComputerSystem

if ($computerSystem.PartOfDomain) {
    $domainAdmin = $computerSystem.Domain + "\\Administrator"  

    # Check for saved credentials in Credential Manager
    Write-Host "Checking Credential Manager..."
    cmdkey /list | Select-String $domainAdmin

    # Check for recent logons in Security Event Log
    Write-Host "Checking Security Event Log for recent logons..."
    Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        ID = 4624
        StartTime = (Get-Date).AddDays(-7)
    } | Where-Object {
        $_.Properties[5].Value -eq "Administrator" -or $_.Properties[1].Value -eq "Administrator"
    } | Select-Object TimeCreated, @{Name="Account";Expression={$_.Properties[5].Value}}, @{Name="Source";Expression={$_.Properties[18].Value}}

    # Check for RDP session history
    Write-Host "Checking RDP session history..."
    Get-EventLog -LogName "Security" -InstanceId 4624 -Newest 1000 | Where-Object {
        $_.ReplacementStrings -like "*Administrator*"
    } | Select-Object TimeGenerated, ReplacementStrings

    # Check for scheduled tasks running as Domain Admin
    Write-Host "Checking Scheduled Tasks..."
    Get-ScheduledTask | Where-Object {
        $_.Principal.UserId -eq $domainAdmin
    } | Select-Object TaskName, State, @{Name="RunAsUser";Expression={$_.Principal.UserId}}

    # Check for services running as Domain Admin
    Write-Host "Checking Services..."
    Get-WmiObject Win32_Service | Where-Object {
        $_.StartName -eq $domainAdmin
    } | Select-Object Name, StartName, State
} else {
    Write-Host "This computer is not joined to any domain."
}

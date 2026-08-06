$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

$files = @(
    "C:\Windows\security\audit\audit.csv",
    "C:\Windows\System32\GroupPolicy\Machine\Microsoft\Windows NT\Audit\audit.csv"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        $directory = Split-Path $file -Parent
        $newName = "audit-$timestamp.csv.bak"

        Rename-Item -Path $file -NewName $newName -Force

        Write-Host "Renamed: $file -> $directory\$newName"
    }
    else {
        Write-Warning "File not found: $file"
    }
}

################################################################################
### Converted these to poweshell commands from the auditpol.exe commands in the original script
### auditpol /set /subcategory:"Credential Validation","Kerberos Authentication Service","Kerberos Service Ticket Operations","Computer Account Management","Distribution Group Management","Security Group Management","User Account Management","Directory Service Access","Logon","Network Policy Server","Other Logon/Logoff Events","Detailed File Share","File Share","Kernel Object","Other Object Access Events","Removable Storage","MPSSVC Rule-Level Policy Change","Other Policy Change Events","Sensitive Privilege Use","Other System Events","System Integrity" /success:enable /failure:enable
### auditpol /set /subcategory:"Other Account Management Events","Plug and Play Events","Directory Service Changes","Logoff","Special Logon","Audit Policy Change","Authentication Policy Change","Authorization Policy Change","Filtering Platform Policy Change","Security State Change","Security System Extension" /success:enable
### auditpol /set /subcategory:"Account Lockout","Filtering Platform Connection" /failure:enable
################################################################################

# Enable Success and Failure auditing
$SuccessFailureCategories = @(
    "Credential Validation",
    "Kerberos Authentication Service",
    "Kerberos Service Ticket Operations",
    "Computer Account Management",
    "Distribution Group Management",
    "Security Group Management",
    "User Account Management",
    "Directory Service Access",
    "Logon",
    "Network Policy Server",
    "Other Logon/Logoff Events",
    "Detailed File Share",
    "File Share",
    "Kernel Object",
    "Other Object Access Events",
    "Removable Storage",
    "MPSSVC Rule-Level Policy Change",
    "Other Policy Change Events",
    "Sensitive Privilege Use",
    "Other System Events",
    "System Integrity"
)

foreach ($Category in $SuccessFailureCategories) {
    auditpol /set /subcategory:"$Category" /success:enable /failure:enable
}

# Enable Success auditing only
$SuccessOnlyCategories = @(
    "Other Account Management Events",
    "Plug and Play Events",
    "Directory Service Changes",
    "Logoff",
    "Special Logon",
    "Audit Policy Change",
    "Authentication Policy Change",
    "Authorization Policy Change",
    "Filtering Platform Policy Change",
    "Security State Change",
    "Security System Extension"
)

foreach ($Category in $SuccessOnlyCategories) {
    auditpol /set /subcategory:"$Category" /success:enable
}

# Enable Failure auditing only
$FailureOnlyCategories = @(
    "Account Lockout",
    "Filtering Platform Connection"
)

foreach ($Category in $FailureOnlyCategories) {
    auditpol /set /subcategory:"$Category" /failure:enable
}

Write-Host "Audit policy configuration"

Limit-EventLog -LogName Security -MaximumSize 512000KB -OverflowAction OverwriteAsNeeded

New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging" -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging" -Name "EnableModuleLogging" -Value 1 -PropertyType DWord -Force | Out-Null

New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames" -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames" -Name "*" -Value "*" -PropertyType String -Force | Out-Null

New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -Value 1 -PropertyType DWord -Force | Out-Null
 windows update diagnose/fix script :: REDUX 2 :: build 54/seagull, july 2026
   script variables: usrClearWSUS/Bln :: usrResetWUA/Bln :: usrUpdateScan/Bln :: usrUDF/str

   datto labs shouts-out: jim d., simon m., jon n.

   this script, like all datto RMM Component scripts unless otherwise explicitly stated, is the copyrighted property of Datto, Inc.;
   it may not be shared, sold, or distributed beyond the Datto RMM product, whole or in part, even with modifications applied, for 
   any reason. this includes on reddit, on discord, or as part of other RMM tools. PCSM and VSAX stand as exceptions to this rule.
   	
   the moment you edit this script it becomes your own risk and support will not provide assistance with it.#>

#region Functions & Variables -------------------------------------------------------------------------------------

#regEnum build 7 (datto) :: enumerate a registry location..........................................................
function regEnum ($locationArray) {
    $arrEnum=@{}
    [int]$varCounter=0

    foreach ($location in $locationArray) {
        if (!(test-path $location -ea 0)) {
            #key does not exist
            continue
        }

        #add the contents of the base location
        try {
            gp $location | get-member -ea 1 | ? {$_.memberType -eq 'NoteProperty'} | ? {$_.name -notmatch '^PS'} | % {
                $varEnum=new-object PSObject
                $varCounter++
                $varEnum | add-member -MemberType NoteProperty -Name "Registry Path" -Value $location
                $varEnum | add-member -MemberType NoteProperty -Name "Value Name"    -Value $_.name
                $varEnum | add-member -MemberType NoteProperty -Name "Data"          -Value (gp $location -Name $_.name).$($_.name)
                try {
                    $varEnum | add-member -MemberType NoteProperty -Name "Type"      -Value (get-item $location).getValueKind($_.name)
                } catch {
                    $varEnum | add-member -MemberType NoteProperty -Name "Type"      -Value "String"
                }
                $arrEnum[$varCounter]=$varEnum
            }
        } catch {
            #key is empty
            $varEnum=new-object PSObject
            $varCounter++
            $varEnum | add-member -MemberType NoteProperty -Name "Registry Path" -Value $location
            $varEnum | add-member -MemberType NoteProperty -Name "Value Name"    -Value "[No Values]"
            $varEnum | add-member -MemberType NoteProperty -Name "Data"          -Value "[N/A]"
            $varEnum | add-member -MemberType NoteProperty -Name "Type"          -Value "Key"
            $arrEnum[$varCounter]=$varEnum
        }

        #next, enumerate the subsequent keys, if any
        gci $location -recurse | % {
            $subLocation=$_.name -replace "HKEY_LOCAL_MACHINE","HKLM:"
            try {
                gp $sublocation | get-member -ea 1 | ? {$_.memberType -eq 'NoteProperty'} | ? {$_.name -notmatch '^PS'} | % {
                    $varEnum=new-object PSObject
                    $varCounter++
                    $varEnum | add-member -MemberType NoteProperty -Name "Registry Path" -Value $sublocation
                    $varEnum | add-member -MemberType NoteProperty -Name "Value Name"    -Value $_.name
                    $varEnum | add-member -MemberType NoteProperty -Name "Data"          -Value (gp $sublocation -Name $_.name).$($_.name)
                    try {
                        $varEnum | add-member -MemberType NoteProperty -Name "Type"      -Value (get-item $sublocation).getValueKind($_.name)
                    } catch {
                        $varEnum | add-member -MemberType NoteProperty -Name "Type"      -Value "String"
                    }
                    $arrEnum[$varCounter]=$varEnum
                }
            } catch {
                #subkey is empty
                $varEnum=new-object PSObject
                $varCounter++
                $varEnum | add-member -MemberType NoteProperty -Name "Registry Path" -Value $sublocation
                $varEnum | add-member -MemberType NoteProperty -Name "Value Name"    -Value "[No Values]"
                $varEnum | add-member -MemberType NoteProperty -Name "Data"          -Value "[N/A]"
                $varEnum | add-member -MemberType NoteProperty -Name "Type"          -Value "Key"
                $arrEnum[$varCounter]=$varEnum
            }
        }
    }

    #splat
    return $arrEnum.values
}

#write udf.........................................................................................................
function writeUDF ($message) {
    if (($env:usrUDF -as [int]) -ge 1) {
        New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name Custom$env:usrUDF -Value $message -Force | Out-Null
        write-host "- Data written to User-defined Field $env:usrUDF`."
    } else {
        write-host "- Not writing data to UDF (no field specified)."
    }
}

#windows version table (adapted from forensic audit)...............................................................
function getWinVer ($kernel) {
    switch ([int]$kernel) {
        10240 {return "Windows 10, RTM"}
        10586 {return "Windows 10, Version 1511"}
        14393 {return "Windows 10/Server 2016, Version 1607"}
        15063 {return "Windows 10, Version 1703"}
        16299 {return "Windows 10/Server, Version 1709"}
        17134 {return "Windows 10/Server, Version 1803"}
        17763 {return "Windows 10/Server, Version 1809"}
        18362 {return "Windows 10/Server, Version 1903"}
        18363 {return "Windows 10/Server, Version 1909"}
        19041 {return "Windows 10/Server, Version 2004"}
        19042 {return "Windows 10/Server, Version 20H2"}
        19043 {return "Windows 10, Version 21H1"}
        19044 {return "Windows 10, Version 21H2"}
        19045 {return "Windows 10, Version 22H2"}
        20348 {return "Windows Server 2022, Version 21H2"}
        22000 {return "Windows 11, Version 21H2"}
        22621 {return "Windows 11, Version 22H2"}
        22631 {return "Windows 11, Version 23H2"}
        26100 {return "Windows 11, Version 24H2"}
        26200 {return "Windows 11, Version 25H2"}
        26300 {return "Windows 11, Version 26H2"}
        default {
	        if ($kernel -gt 26200) {
                return "Windows 11/Server 2022 or newer"
            } else {
                return "Unknown"
            }
        }
    }
}

#standard variables................................................................................................
try {
    if ($null -ne (get-host).UI -and $null -ne (get-host).UI.RawUI) {
        $(get-host).UI.RawUI.bufferSize=New-Object System.Management.Automation.Host.Size(140,80)
    }
} catch {
    #do nothing
}

[Net.ServicePointManager]::SecurityProtocol = [Enum]::ToObject([Net.SecurityProtocolType], 3072)
[int]$varOS=(gwmi win32_operatingsystem).buildNumber
[int]$varUBR=(get-itemproperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").UBR

if (((7..10),(12..15),(17..25),(29..46),(50..56),(59..64),72,76,77,79,80,95,96,109,110,120,(143..148),159,160,168,169 | write-output) -contains $((gwmi win32_operatingsystem).operatingSystemSKU)) {
    $varType="Server"
} else {
    $varType="Workstation"
}

#region Get Agent log data ----------------------------------------------------------------------------------------

try {
    if ([IntPtr]::Size -eq 4) {
        $varCSLog=get-content "$env:ProgramFiles\CentraStage\log.txt" -ea 1
    } else {
        $varCSLog=get-content "${env:ProgramFiles(x86)}\CentraStage\log.txt" -ea 1
    }
} catch {
    try {
        if ([IntPtr]::Size -eq 4) {
            $varCSLog=get-content "$env:ProgramFiles\Panda Cloud Systems Management\log.txt" -ea 1
        } else {
            $varCSLog=get-content "${env:ProgramFiles(x86)}\Panda Cloud Systems Management\log.txt" -ea 1
        }
    } catch {
        write-host "! ERROR: Unable to parse the Datto RMM Agent log file."
        write-host "  This suggests bigger issues than failures to update."
        write-host "  You are advised to contact Support."
        exit 1
    }
}

#get the most recent part of the log where a patch audit was dealt (thanks jim)....................................
try {
    #find line number for the most recent "Running Audit"
    $varLOG_AuditMarker=($varCSLog | select-string "Running Audit" | select -last 1).LineNumber

    #find diffs for our five searches
    $arrLOG_Searches=@{}
    "REQUESTED_BY_PLATFORM","INTERVAL","PATCH_POLICY_AUDIT_ONLY","AFTER_INSTALLING_PATCHES","AFTER_REBOOT" | % {
        $varLOG_Result=$varCSLog | select-string "Audit reason: $_" | select -last 1
        if ($varLOG_Result) {
            $varLOG_Object=new-object PSObject
            $varLOG_Object | add-member -MemberType NoteProperty -Name "Query" -Value $_
            $varLOG_Object | add-member -MemberType NoteProperty -Name "LnNum" -Value $varLOG_Result.LineNumber
            $varLOG_Object | add-member -MemberType NoteProperty -Name "Diff"  -Value $($varLOG_Result.LineNumber - $varLOG_AuditMarker)
            $arrLOG_Searches[$_]=$varLOG_Object
        }
    } #this may appear overcomplicated, but when debugging, having full visibility of `$arrLOG_Searches.values` is a godsend

    #pull the contents of the log between these two figures
    $varLOG_FinalContents=$varCSLog | Select-Object -Index (($varLOG_AuditMarker-1)..$(($arrLOG_Searches.values | ? {$_.Diff -ge 0} | sort -Property Diff | select -first 1).LnNum))
} catch {
    #do nothing; no log data = no problem
}

#region Intro/System Info -----------------------------------------------------------------------------------------

write-host "Windows Update Toolkit"

if ($varOS -lt 10240) {
    write-host "! ERROR: The oldest workstation version of Windows still supported is Windows 10 RTM (10240)."
    write-host "  (This Component is not intended for Servers.)"
    write-host "  Cannot continue. Exiting."
    exit 1
}

@"
 
----[System Information]-------------------------------------------------------------------------------------------------------------------

 Device hostname: $env:COMPUTERNAME
            Is a: $varType
"@ | write-host

if ((gwmi win32_processor).architecture -eq 12) {
    write-host "         Running: $((gwmi win32_operatingsystem).caption) [Arm64]"
} else {
    if ([intptr]::Size -eq 8) {
        write-host "         Running: $((gwmi win32_operatingsystem).caption) [x86-64]"
    } else {
        write-host "         Running: $((gwmi win32_operatingsystem).caption) [x86]"
    }
}

@"
      of Version: $varOS.$varUBR
with WUA Version: $((New-Object -ComObject Microsoft.Update.AgentInfo).GetInfo('ProductVersionString'))
              At: $(get-date)

----[Registry]-----------------------------------------------------------------------------------------------------------------------------
 
"@ | write-host

#region Enumerate Registry artefacts ------------------------------------------------------------------------------

write-host "- The following Windows Update-related Registry keys and values are configured for this device."
write-host "  These can affect aspects such as WSUS, Update deferral, and servicing channel."
write-host "- Policy-based and standalone Registry values (abridged):"

$varReg=regEnum "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate","HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy\PolicyState","HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization","HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"

#de-dupe policyState in favour of HKSP values
$varReg.'value name' | select -unique | % {
    $varName=$_
    if ((($varReg | ? {$_.'Value Name' -eq $varName}).'Data').count -gt 1) {
         ($varReg | ? {$_.'Value Name' -eq $varName} | ? {$_.'Registry Path' -match 'PolicyState'}).'Value Name'="!REMOVED!"
    }
}

#output filtered values
$varReg | ? {$_.'Registry Path' -notmatch 'UX'} | ? {$_.'Value Name' -ne '!REMOVED!'} | sort -Property "registry path" | ft

write-host "- User-configured ('UX') settings (these can be superseded by the values above):"

$varReg | ? {$_.'Registry Path' -match 'UX'} | sort -Property "registry path" | ft

#region Explain Registry artefacts --------------------------------------------------------------------------------

write-host "- Reference for Registry values (non-exhaustive):"

#wsus
if ($varReg | ? {$_.'Value Name' -eq 'WUServer'}) {
    write-host ":                 WSUS: Configuration detected."
    $varAux+="[WSUS]"
    $varDC=gwmi win32_ntdomain #normally i wouldn't, but the query takes forever, so
    if ($varDC.dnsforestname) {
        write-host "                        Domain: $($varDC.dnsforestname        | select -Skip 1)"
        write-host "                           DC1: $($varDC.domainControllerName | select -first 1) ('$($varDC.dcSiteName | select -first 1)' @ $($varDC.domainControllerAddress | select -first 1))"
        write-host "                           DC2: $($varDC.domainControllerName | select -skip 1) ('$($varDC.dcSiteName | select -skip 1)' @ $($varDC.domainControllerAddress | select -skip 1))"
    } else {
        write-host "                    Using WSUS: $(($varReg | ? {$_.'Value Name' -eq 'UseWUServer'}).Data)"
        write-host "                        Server: $(($varReg | ? {$_.'Value Name' -eq 'WUServer'}).Data)"
        write-host "                 Status Server: $(($varReg | ? {$_.'Value Name' -eq 'WUStatusServer'}).Data)"
    }
} else {
    write-host ":                 WSUS: Not configured - Device does not use WSUS to receive updates."
}

#noautoupdate
if (($varReg | ? {$_.'Value Name' -eq 'NoAutoUpdate'}).Data -eq '1') {
    write-host ":         NoAutoUpdate: 1 - Automatic Updates are disabled on this system. Valid, provided Patch Management is in use."
} else {
    write-host ":         NoAutoUpdate: 0/Unset - Automatic Updates are enabled on this system."
}

#auoptions :: https://learn.microsoft.com/de-de/security-updates/windowsupdateservices/18127499 (warum im deutsch? kein idee.)
if ($varReg | ? {$_.'Value Name' -eq "AUOptions"}) {
    switch (($varReg | ? {$_.'Value Name' -eq "AUOptions"}).data) {
        1 {write-host ":            AUOptions: 1 - Automatic Updates are disabled on this system. Invalid configuration for Windows 10+."}
        2 {write-host ":            AUOptions: 2 - Device will notify end-user to download updates which will then be installed automatically."}
        3 {write-host ":            AUOptions: 3 - Device will automatically download updates and then prompt the end-user to install them."}
        4 {write-host ":            AUOptions: 4 - Device will automatically download updates and then schedule their installation."}
        5 {write-host ":            AUOptions: 5 - Device will automatically install updates, but the end-user can exert some control."}
        6 {write-host ":            AUOptions: 6 - Invalid setting of unknown status. Updates will be processed as normal."}
        7 {write-host ":            AUOptions: 7 - Device will automatically download updates and then prompt the end-user to install & reboot."}
    }
}

<#windows branch readiness level

    this is a mess of microsoft's making. it's unclear how respected this setting is as of 2024; MS seem to have mostly migrated across to
    using deferral settings, which is a wiser option, but the setting remains with at least three different schemata dictating its actions.
    this isn't helped by BranchReadinessLevel being present in two different registry locations, often containing vastly different data.

    to wit:
    - https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-update#branchreadinesslevel -- lists values from 2 to 128 and lists 16 as default.
    - https://learn.microsoft.com/en-us/windows/deployment/update/waas-configure-wufb -- lists values from 2 to 32 and implies 32 as default. calls 2 and 4 "fast" and "slow".
    - https://blogs.windows.com/windows-insider/2020/06/15/introducing-windows-insider-channels/ -- suggests that "fast" and "slow" are deprecated and prefers "dev" and "beta".
    - https://learn.microsoft.com/en-us/windows/deployment/update/waas-overview#servicing-channels -- suggests there are only "insider", "general", and "LTS" channels.
    - https://github.com/MSEndpointMgr/Reporting/blob/main/Workbooks/Windows%20Update%20Device%20Settings.workbook -- (non-MS) suggests option #6 as "release preview".

    what you are seeing here is a best-fit, with 16 and 32 registering the same value. modern windows will disregard invalid entries so either will work as GA.
    it's a sad situation when MS can't even keep their own documentation up-to-date. what chance do MSPs have at regulating their estates with these tools?
        - seagull, july 2024
#>

if ($varReg | ? {$_.'Value Name' -eq 'BranchReadinessLevel'}) {
    switch (($varReg | ? {$_.'Value Name' -eq 'BranchReadinessLevel'}).Data) {
        'CB'  {write-host ": BranchReadinessLevel: CB - Current Branch. Invalid legacy setting - Device will receive all updates."}
        'CBB' {write-host ": BranchReadinessLevel: CBB - Current Branch for Business. Invalid legacy setting - Device will receive all updates."}
        2     {write-host ": BranchReadinessLevel: 2 - Windows Insider branch (Dev/Fast). Device will receive developmental updates."}
        4     {write-host ": BranchReadinessLevel: 4 - Windows Insider branch (Beta/Slow). Device will receive beta updates."}
        6     {write-host ": BranchReadinessLevel: 6 - Release Preview branch. Device will receive large updates slightly before all QA has passed."}
        8     {write-host ": BranchReadinessLevel: 8 - Release Preview branch. Device will receive large updates slightly before all QA has passed."}
        16    {write-host ": BranchReadinessLevel: 16 - General Availability (Default). Device will receive all applicable updates immediately."}
        32    {write-host ": BranchReadinessLevel: 32 - General Availability (Default). Device will receive all applicable updates immediately."}
        64    {write-host ": BranchReadinessLevel: 64 - Release Preview branch. Invalid legacy setting. Device will receive all updates."}
        128   {write-host ": BranchReadinessLevel: 128 - Canary. Invalid legacy setting. Device will receive all updates."}
    }
    write-host "                        Remember: The greatest control over updates in $((get-date).year) is afforded to the deferral settings below."
} else {
    write-host ": BranchReadinessLevel not configured. Device will receive all applicable updates."
}

#ltsc
if (((gwmi win32_operatingsystem).operatingsystemsku -eq 125) -or ((gwmi win32_operatingsystem).operatingsystemsku -eq 126)) {
    write-host "  (Operating System SKU corresponds to Long-Term Servicing Channel; this will affect update cadence.)"
    $varAux+="[LTSC]"
}

#deferral
"Quality","Feature" | % {
    $varSetting=$_
    if ($varReg | ? {$_.'Value Name' -eq "Defer$varSetting`Updates"}) {
        switch (($varReg | ? {$_.'Value Name' -eq "Defer$varSetting`Updates"}).Data) {
            0 {write-host ":  Defer$varSetting`Updates: 0 - $varSetting Updates will show in patch scans the moment they are applicable to this device."}
            1 {
                write-host ":  Defer$varSetting`Updates: 1 - $varSetting Updates will not show in patch scans until the deferral period for the individual update has elapsed."
                write-host "                        $varSetting Updates will be deferred for [$(($varReg | ? {$_.'Value Name' -eq "Defer$varSetting`UpdatesPeriodInDays"}).Data)] days."
                $varAux+="[DEF$varSetting]"
            }
        }
    }
}

#release version targeting
"TargetReleaseVersionInfo","ProductVersion","TargetReleaseVersion" | % {
    $varSetting=$_
    if ($varReg | ? {$_.'Value Name' -eq $varSetting}) {
        $varTarget=$true
    }
}

if ($varTarget) {
    if (($varReg | ? {$_.'value name' -eq 'TargetReleaseVersion'}).data -eq 0) {
        write-host ": TargetReleaseVersion: Set to 0. Feature Updates will be processed as normal."
    } else {
        $varAux+="[TargetSet]"
        write-host ": TargetReleaseVersion: Set (et al). Device is attached to a release version."
    }
} else {
    write-host ": TargetReleaseVersion: Unset. Feature Updates will be processed as normal."
}

#tray icon
if (($varReg | ? {$_.'Value Name' -eq 'TrayIconVisibility'}).Data -eq '1') {
    write-host ":   TrayIconVisibility: 1 - This device hides the Windows Update tray icon."
    write-host "    (NOTICE: This setting is of limited use in Windows 10/11 version 24H2 onwards)"
} #do not note if this isn't configured, since it doesn't do anything anymore :: april 2026

#delivery optimisation
if ((gp "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization\" -ea 0).DODownloadMode) {
    switch ((gp "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization\" -ea 0).DODownloadMode) {
        0 {write-host ":       DODownloadMode: 0 - HTTP: This device downloads updates from the internet and MS Cache Servers."}
        1 {write-host ":       DODownloadMode: 1 - LAN: This device downloads updates from peers on the same NAT only."}
        2 {write-host ":       DODownloadMode: 2 - Group: This device downloads updates from a group (Domain, AD DS, etc)."}
        3 {write-host ":       DODownloadMode: 3 - Internet: This device downloads updates from internet-sourced peers."}
       99 {write-host ":       DODownloadMode: 99 - Simple: This device downloads updates directly."}
      100 {
            if ($varOS -ge 22000) {
                write-host "! ERROR:DODownloadMode: 100 - Bypass: This device downloads updates directly."
                write-host "                        This setting is NOT VALID for Windows 11 and will cause issues."
                $varScriptErrors++
                $varAux+="[DOptimis]"
            } else {
                write-host ":       DODownloadMode: 100 - Bypass: This device downloads updates directly."
            }
          }
    }
} else {
    write-host ":       DODownloadMode: Unset. Delivery Optimisation disabled; this device downloads updates directly."
}

#settings page
if ((gp "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ea 0).SettingsPageVisibility) {
    if (((gp "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ea 0).SettingsPageVisibility -match "windowsupdate")) {
        write-host ": SettingsPageVisibility: $((gp "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ea 0).SettingsPageVisibility)"
    }
}

#closeout
@"

: Useful references for Registry locations:
  https://admx.help/HKLM/Software/Policies/Microsoft/Windows/WindowsUpdate
  https://admx.help/HKLM/Software/Policies/Microsoft/Windows/WindowsUpdate/AU
"@ | write-host

write-host `r
write-host "----[Connectivity]-------------------------------------------------------------------------------------------------------------------------"
write-host `r

#region Windows Update Connectivity -------------------------------------------------------------------------------

"https://www.catalog.update.microsoft.com/Home.aspx","https://download.microsoft.com" | % {
    try {
        if ([int]$([System.Net.WebRequest]::Create("$_")).GetResponse().StatusCode -ne '200') {
            write-host "! NOTICE: Device was unable to contact $_."
            write-host "  Please investigate connectivity to Windows Update services."
            $varScriptErrors++
        } else {
            write-host "- No issues contacting $_."
        }
    } catch {
        write-host "! NOTICE: $_"
        write-host "  Please investigate connectivity to Windows Update services."
        $varScriptErrors++
    }
}

write-host `r
write-host "----[Windows Update Agent]-----------------------------------------------------------------------------------------------------------------"
write-host `r

#region Windows Update Subsystem ----------------------------------------------------------------------------------

write-host "- Windows Update Agent version: $((New-Object -ComObject Microsoft.Update.AgentInfo).GetInfo('ProductVersionString'))"

if ((gwmi win32_service | ? {$_.name -match 'wuauserv'}).startmode -eq 'Disabled') {
    Set-Service -Name wuauserv -StartupType Automatic
    Write-Host "! NOTICE: Device has the Windows Update service disabled. This will cause issues when attempting to update."
    write-host "  It has been set to Automatic."
    $varScriptErrors++
} else {
    write-host "- Windows Update service is set to Automatic."
}

#windows update service
if ($((get-service wuauserv).Status.value__) -eq 3) {
    write-host "! NOTICE: Windows Update service (wuauserv) is in 'stopping' state."
    write-host "  Windows Update starts and stops automatically, so this may be normal; however, it could also indicate"
    write-host "  that the service is stuck in this state. Suggested course of action is to wait 5 minutes and re-check."
    write-host "  If the service remains in this state it indicates a serious issue with the Windows Update subsystem."
    $varScriptErrors++
}

#broken WUA july 2024
if ($((New-Object -ComObject Microsoft.Update.AgentInfo).GetInfo('ProductVersionString')) -in "1301.2403.14011.0","1305.2405.14022.0","1306.2405.21022.0") {
    write-host "! ERROR: Device has a known-problematic WUA version installed."
    write-host "  Please run the 'WUA JSON Adjustment Tool' Component from the ComStore to fix update scans."
    $varScriptErrors++
    $varAux+="[BadWUA]"
}

#broken certificates november 2025 (chris d., datto community)
if (((certutil -verifyctl Disallowed | select-string "lastSyncTime") -split '"')[1] -as [datetime] -lt (get-date).AddDays(-7)) {
    write-host "! ERROR: Certificates may be out-of-date; Disallowed certificates were last synched over a week ago."
    $varCertIssue++
}

if (((certutil -verifyctl AuthRoot | select-string "lastSyncTime") -split '"')[1] -as [datetime] -lt (get-date).AddDays(-7)) {
    write-host "! ERROR: Certificates may be out-of-date; AuthRoot certificates were last synched over a week ago."
    $varCertIssue++
}

if ($varCertIssue) {
    write-host "  This will almost definitely lead to system issues (notably 0x80072F8F when updating)."
    write-host "  This tool may help in fixing the device: https://github.com/asheroto/UpdateRootCertificates"
    write-host "  (offered without guarantee or liability)"
} else {
    write-host "- Disallowed/AuthRoot certificates are being kept up-to-date."
}

#region DRMM Agent & WUA Interop ----------------------------------------------------------------------------------

write-host `r
write-host "----[WUA & Datto RMM Interop]--------------------------------------------------------------------------------------------------------------"
write-host `r

if ($varLOG_FinalContents) {
    #windows update agent version
    if ($varLOG_FinalContents | select-string 'Windows Update Agent version has\s.*$' -quiet) {
        write-host "! NOTICE: The Windows Update Agent has been updated. Please reboot this device to complete the process."
    } else {
        write-host "- Windows Update Agent version is working alongside Datto RMM Agent."
    }

    #audit failure
    if ($varLOG_FinalContents | select-string '- Audit failed' -quiet) {
        write-host "! NOTICE: An Audit failure has been detected. Please contact Support."
        $varAux+="[AuditFail]"
        $varScriptErrors++
    } else {
        write-host "- No failures performing Audits were discovered."
    }

    #common PM failure codes
    $arrHRESULT=@() ; $arrNull=@() ; $arrTLS=@() ; $arrHTTP=@() ; $arrTimeout=@()
    $varLOG_FinalContents | select-string 'CheckPatches audit\s.*$' | % {
        if ($_ -match 'Windows Update Toolkit') {
            #we're pulling output from previous script runs; abort
            return
        }
        
        if ($_ -match '0x[0-9a-fA-F]+\b') {
            $arrHRESULT+=$_
            $arrHRESULT+=". . . . . . . . . . . . . . . . . . . . . . . . ."
        }

        if ($_ -match 'ArgumentNullException') {
               $arrNull+=$_
               $arrNull+=". . . . . . . . . . . . . . . . . . . . . . . . ."
        }

        if ($_ -match 'Could not create SSL') {
                $arrTLS+=$_
                $arrTLS+=". . . . . . . . . . . . . . . . . . . . . . . . ."
        }

        if ($_ -match 'failed with HTTP status') {
               $arrHTTP+=$_
               $arrHTTP+=". . . . . . . . . . . . . . . . . . . . . . . . ."
        }

        if ($_ -match 'operation has timed out') {
            $arrTimeout+=$_
            $arrTimeout+=". . . . . . . . . . . . . . . . . . . . . . . . ."
        }
    }

    "HRESULT","Null","TLS","HTTP","Timeout" | % {
        if ((get-variable arr$_).value.count -gt 0) {
            $varPMError=$true
            $varScriptErrors++
            write-host "! NOTICE: $_-type errors were found in the Datto RMM Patch Management log."
            write-host "  Complete log of errors of this type is below."
            write-host ".................................................."
            (get-variable "arr$($_)").value | ? {$_.line} | % {$_ | select Line | format-table -wrap}

            if ($varAux -notmatch 'PatchFail') {
                $varAux+="[PatchFail]"
            }
        }
    }

    if (!$varPMError) {
        write-host "- No errors were found relating to Datto RMM Patch Management."
    }

    #automatic update issues
    $varLOG_FinalContents | select-string 'AutomaticUpdate\s.*$' | select-string '0x[0-9a-fA-F]+\b' | % {
        write-host "! NOTICE: Issues discovered with Automatic Updates:"
        $varScriptErrors++
        write-host "$_"
        write-host `r
    }

    #when did this audit occur
    write-host ": Date of last patch Audit: $($varLOG_FinalContents[-1].split('|')[1] | get-date)"
} else {
    write-host "- Datto RMM Logfile check skipped: Could not confirm device is using Patch Management."
}

#wua logs and agent
start-process powershell -argumentlist "Get-WindowsUpdateLog -LogPath `"$env:TEMP\WindowsUpdate.log`"" -wait #this is the only way to suppress output
move-item "$env:TEMP\WindowsUpdate.log" "$PWD\WindowsUpdate.log" -Force
write-host "- Complete Windows Update log saved at '$PWD\WindowsUpdate.log'."

#get the name of the agent from the branding keys file
try {
    $varProductShort=(($(Get-Content "$env:ProgramData\CentraStage\Brand\keys.xml" -ea 1) -as [xml]).bundles.bundle.entry | ? {$_.key -eq 'productShortNameText'}).'#text' -replace '[^a-zA-Z0-9]','.*'
} catch {
    $varProductShort="Datto RMM"
}

write-host "- Agent's branded name (in Regex) is: $varProductShort"

if ((Get-Content "$PWD\WindowsUpdate.log"| select-string -quiet "Id = $varProductShort,")) {
    write-host "- Last 10 Datto RMM-related entries from WindowsUpdate.log:"
    write-host `r
    (Get-Content "$PWD\WindowsUpdate.log" -ReadCount 1000).Split([string[]]"`r`n", [StringSplitOptions]::None) | ? {$_ -match "Id = $varProductShort,"} | select -last 10
} else {
    write-host "- No Datto RMM-related entries could be located from WindowsUpdate.log."
}

#region DRMM Patch Policies ---------------------------------------------------------------------------------------

write-host `r

if (test-path "$env:SystemDrive\ProgramData\CentraStage\Policy\Patch") {
    $varPatchPolicies=gci "$env:SystemDrive\ProgramData\CentraStage\Policy\Patch" | ? {!($_.PSIsContainer)}
    if ($varPatchPolicies.Count -gt 0) {
        $varPatchPolicies | % {
            write-host "- Patch Policy: (JSON) $($_.FullName) :: $($_.LastWriteTime)" 
        }
        $varAux+="[Policy]"
    } else {
        write-host "- No Datto RMM Patch Policies were detected on this device."
        $varAux+="[NoPolicy]"
    }
} else {
    write-host "- No Datto RMM Patch Policies (the Patch Policy directory does not exist)."
    $varAux+="[NoPolicy]"
} 

#region Windows Update History ------------------------------------------------------------------------------------

write-host `r
write-host "----[Windows Update History]---------------------------------------------------------------------------------------------------------------"
write-host `r

$arrUpdates=@{}
$varCounter=0

#el classico
$varUpdateSearcher=$(New-Object -ComObject Microsoft.Update.Session).CreateUpdateSearcher()
if ($($varUpdateSearcher.GetTotalHistoryCount()) -gt 0) {
    $varUpdateSearcher.QueryHistory(0, $($varUpdateSearcher.GetTotalHistoryCount())) | % {
        #commit
        $varCounter++
        $varUpdate=new-object PSObject
        $varUpdate | add-member -MemberType NoteProperty -Name "Update Title"  -Value $_.Title
        $varUpdate | add-member -MemberType NoteProperty -Name "Primary Source"  -Value "Update Query History"

        #what happened?
        switch ($_.resultcode) {
            1 {$varUpdate | add-member -MemberType NoteProperty -Name "Operation"  -Value "Installing"}
            2 {$varUpdate | add-member -MemberType NoteProperty -Name "Operation"  -Value "Installed"}
            3 {$varUpdate | add-member -MemberType NoteProperty -Name "Operation"  -Value "Installed"}
            4 {$varUpdate | add-member -MemberType NoteProperty -Name "Operation"  -Value "Failed"}
            5 {$varUpdate | add-member -MemberType NoteProperty -Name "Operation"  -Value "Aborted"}
        }
            
        $varUpdate | add-member -MemberType NoteProperty -Name "Date (YYYY/MM/DD)"  -Value $($_.Date | get-date -UFormat "%Y/%m/%d %R.%S")
        $varUpdate | add-member -MemberType NoteProperty -Name "Client"  -Value $($_.ClientApplicationID -replace "Acquisition","Acqn" -replace "DeviceScan" -replace "MoUpdateOrchestrator","UpdOrch" -replace "Update","Upd" -replace "ZDP","0Day" -replace "setup-Start" -replace "Product","Prod" -replace "With","W")
        $arrUpdates[$varCounter]=$varUpdate
        remove-variable varUpdate -force
    }
} else {
    write-host "- Skipping Update Query History search (no update history on this device)"
}

#qfe (it's get-hotfix, but for the whole family)
gwmi win32_quickfixengineering | % {
    $varCounter++
    $varUpdate=new-object PSObject
    #commit
    $varUpdate | add-member -MemberType NoteProperty -Name "Update Title"  -Value "Hotfix ($($_.Description) $($_.HotfixID))"
    $varUpdate | add-member -MemberType NoteProperty -Name "Primary Source"  -Value "Get-Hotfix"
    $varUpdate | add-member -MemberType NoteProperty -Name "Operation"  -Value "Installed"
    $varUpdate | add-member -MemberType NoteProperty -Name "Date (YYYY/MM/DD)"  -Value $($_.InstalledOn | get-date -UFormat "%Y/%m/%d %R.%S")
    $varUpdate | add-member -MemberType NoteProperty -Name "Client"  -Value "N/A"
    $arrUpdates[$varCounter]=$varUpdate
    remove-variable varUpdate -force
}

#get-windowspackage
if (get-command get-windowspackage -ea 0) {
    get-windowspackage -online | ? {$_.packagestate.value__ -eq 4} | ? {$_.releasetype.value__ -in $(0,(3..7),10 | write-output)} | % {
        #commit
        $varCounter++
        $varUpdate=new-object PSObject
        $varUpdate | add-member -MemberType NoteProperty -Name "Update Title"  -Value $_.packageName
        $varUpdate | add-member -MemberType NoteProperty -Name "Primary Source"  -Value "Get-WindowsPackage"
        $varUpdate | add-member -MemberType NoteProperty -Name "Operation"  -Value "Installed"
        $varUpdate | add-member -MemberType NoteProperty -Name "Date (YYYY/MM/DD)"  -Value $($_.InstallTime | get-date -UFormat "%Y/%m/%d %R.%S")
        $varUpdate | add-member -MemberType NoteProperty -Name "Client"  -Value "N/A"
        $arrUpdates[$varCounter]=$varUpdate
        remove-variable varUpdate -force
    }
}

#get-package (in my testing this gave no new information, but include it just in case)
if (get-command get-package -ea 0) {
    Get-Package -ProviderName msu -Force | ? {$_.name -notmatch 'KB2267602'} | % {
        #commit
        $varCounter++
        $varUpdate=new-object PSObject
        $varUpdate | add-member -MemberType NoteProperty -Name "Update Title"  -Value $_.name
        $varUpdate | add-member -MemberType NoteProperty -Name "Primary Source"  -Value "Get-Package:\MSU"
        $varUpdate | add-member -MemberType NoteProperty -Name "Operation"  -Value "Installed"
        $varUpdate | add-member -MemberType NoteProperty -Name "Date (YYYY/MM/DD)"  -Value "N/A"
        $varUpdate | add-member -MemberType NoteProperty -Name "Client"  -Value "N/A"
        $arrUpdates[$varCounter]=$varUpdate
        remove-variable varUpdate -force
    }
}

#de-dupe & shorten titles into a final super-table
$arrUpdatesFinal=@()

#split the table into 'articles with KBs' and 'articles lacking KBs'
$arrUpdatesWKB=($arrUpdates.values)."Update Title" | select-string "KB.*" | % {($_.Matches[0].Value).split(' ')[0] -replace '\)' -replace '~.*'} | select -unique
$arrUpdatesNKB=($arrUpdates.values)."Update Title" | ? {$_ -notmatch 'KB'}

#for each entry WITH a KB, since that's the key datapoint, show the LAST entry; this ensures that UQH gets priority since its queries have dates attached
$arrUpdatesWKB | % {
    $varKB=$_
    $arrUpdates.values | ? {$_."Update Title" -match $varKB} | select -last 1 | % {
        #reduce common words in title to shortened versions :: ENGLISH/GENERIC
        $_."Update Title"=$_."Update Title" -replace "Cumulative Update","Cmtv Upd" -replace "Framework","Fmwk" -replace "Windows","Win" -replace ", version "," ver " -replace "Microsoft","MS" -replace "for x64-based systems","x64" -replace "for x86-based systems","x86" -replace "and",'&' -replace "Update","Upd" -replace "Antivirus","AV" -replace "version","ver" -replace "for x","x" -replace "platform","ptfm" -replace "Intelligence","Intel" -replace "Security","Sec" -replace "Service Pack ","SP" -replace "Redistributable Package","Redist" -replace "preview","PREVIEW"
        
        #reduce common words in title to shortened versions :: GERMAN
        $_."Update Title"=$_."Update Title" -replace "Kumulatives","Kmtv" -replace "x64-basierte Systeme","x64" -replace "x86-basierte Systeme","x86" -replace "Vorschau","VORSCHAU"

        #reduce common words in title to shortened versions :: SPANISH
        $_."Update Title"=$_."Update Title" -replace "Actualizaci.n","Actn" -replace "acumulativa","acmt" -replace "sistemas basados en" -replace "opcional","OPCIONAL" -replace "preliminar","PRELIMINAR"

        #reduce common words in title to shortened versions :: FRENCH
        $_."Update Title"=$_."Update Title" -replace "Mise.*Jour","MaJ" -replace "sur syst.mes" -replace "Mettre.*Jour","MaJ" -replace "pr.version","PREVERSION"

        #if it's still too long, truncate it
        if (($_."Update Title").length -ge 85) {
            $_."Update Title"="$(($_."Update Title").Substring(0,85)).."
        }

        #finally, commit it to our super-table
        $arrUpdatesFinal+=$_
    }
}

#for each entry WITHOUT a KB, add it to the table verbatim
$arrUpdatesNKB | select -unique | % {
    $varTitle=$_
    $arrUpdates.values | ? {$_."Update Title" -match $varTitle} | select -last 1 | % {
        $arrUpdatesFinal+=$_
    }
}

#finally, output our table
@"
- Complete Update History is below.
  Update titles have been shortened to ensure KB number is displayed.
  The following data have been removed:
  - Duplicate entries (Update Query History is used as first-priority source)
  - Updates that were installed but which have since been superseded by newer iterations
  - Installed drivers and features (Feature Packs, Language Packs, On-Demand Packs, etc.)
"@

#i HATE that i have to do this, but format-table is just too broken to rely on solely
$arrUpdatesFinal | sort -property "Date (YYYY/MM/DD)" -Descending | ft -Property @{e="Update Title";Width=70}, @{e="Operation";Width=10}, @{e="Date (YYYY/MM/DD)";Width=19}, @{e="Primary Source";Width=20}, @{e="Client";Width=30} | out-file updatesFinal.txt -Width 9999
get-content updatesFinal.txt
remove-item updatesFinal.txt -Force

#region Device OS Update History ----------------------------------------------------------------------------------

write-host "----[Device Operating System History: Process]---------------------------------------------------------------------------------------------"
write-host `r

$arrIndicators=gci 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TargetVersionUpgradeExperienceIndicators' -ea 0 | % {
    $varChild=gp $_.PSPath -ea 0
    if ($varChild -and $_.PSPath -notmatch 'UNV$') {
        [pscustomobject]@{
            DestBuildNum=[int]$varChild.DestBuildNum
            UpgEx       =$varChild.UpgEx
            YellowReason=$varChild.YellowReason
            OrangeReason=$varChild.OrangeReason
            RedReason   =$varChild.RedReason
        }
    }
}

$varIndicator=$arrIndicators | ? {$_.destBuildNum -gt $varOS} | sort | select -last 1

if (!$varIndicator) {
    write-host ": Last OS upgrade path: None charted"
    $varStatus="GOOD: Windows has not recorded compatibility checks for a later OS version"
} else {
    write-host ": Last OS upgrade path: $varOS to $($varIndicator.destBuildNum)"
    #https://learn.microsoft.com/en-gb/intune/configmgr/osd/deploy-use/manage-windows-11-readiness-dashboard
    switch ($varIndicator.upgEx) {
        'Green'  {$varStatus="GOOD: Windows' last compatibility check for forthcoming updates returned without issues"}
        'Yellow' {$varStatus="CONCERN: Upgrade blocked by program"}
        'Orange' {$varStatus="CONCERN: Upgrade blocked by program/driver"}
        'Red'    {$varStatus="BAD: Upgrade blocked by hardware"}
        default  {$varStatus="GOOD: No compatibility check data found"}
    }
}

write-host ": Update compatibility check is $varStatus. If and when an OS Upgrade"
write-host "  becomes available, the system" -NoNewline

if ($varStatus -match "^GOOD:") {
    write-host " should be able to update to it without encountering issues."
} else {
    write-host " may encounter issues or refuse to upgrade entirely without manual intervention."
    write-host "  Listed reasons for this are given below; these are produced by Microsoft tools and not Datto RMM."
    $varScriptErrors++
}

if ($varIndicator.yellowReason) {
    write-host " : Yellow (program) concerns: $($varIndicator.yellowReason)"
    $varAux+="[YLW]"
}

if ($varIndicator.orangeReason) {
    write-host " : Orange (program/driver) concerns: $($varIndicator.orangeReason)"
    $varAux+="[ORG]"
}

if ($varIndicator.redReason) {
    write-host " : Red (hardware) concerns: $($varIndicator.redReason)"
    $varAux+="[RED]"
}

write-host `r

#region Device OS History -----------------------------------------------------------------------------------------

write-host "----[Device Operating System History: Results]---------------------------------------------------------------------------------------------"
write-host `r

write-host "- PLEASE NOTE: Given the nature of Windows Feature Updates, the below entries may not necessarily line up with their expected release"
write-host "  dates. This is often due to the manner in which the update in question was released - eg, via full upgrade or enablement package,"
write-host "  and whether the update recorded itself in the Registry's version history repository being checked here."
write-host `r

[int]$varCounter=0

$arrOS=@{}
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | % {
    $varOSEntry=New-Object PSObject
    $varOSEntry | Add-Member -MemberType NoteProperty -Name "Installed on" -Value $([timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($_.InstallDate)))
    $varOSEntry | Add-Member -MemberType NoteProperty -Name "Version" -Value "$(getWinVer $_.CurrentBuild) ($($_.CurrentBuild).$varUBR) [Current build]"

    #separator
    $varOSEntry | Add-Member -MemberType NoteProperty -Name "---" -Value "---"

    #commit & iterate
    $arrOS+=@{$varCounter=$varOSEntry}
    $varCounter++
}

gci HKLM:\System\Setup\Source* | % {
    $varOSEntry=New-Object PSObject
    $varOSEntry | Add-Member -MemberType NoteProperty -Name "Installed on" -Value $([timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($((get-itemproperty "registry::$_").installDate))))
    $varOSEntry | Add-Member -MemberType NoteProperty -Name "Version" -Value "$(getWinVer $((get-itemproperty "registry::$_").currentBuild)) ($((get-itemproperty "registry::$_").currentBuild).$((get-itemproperty "registry::$_").UBR))"

    #separator
    $varOSEntry | Add-Member -MemberType NoteProperty -Name "---" -Value "---"

    #commit & iterate
    $arrOS+=@{$varCounter=$varOSEntry}
    $varCounter++
}

($arrOS.values | sort "Installed on" -Descending | format-list | out-string).split([environment]::newline) | ? {$_} | % {if ($_ -match '^---') {write-host `r} else {$_}}

#region Elective Procedures ---------------------------------------------------------------------------------------

write-host `r
write-host "----[Elective Procedures]------------------------------------------------------------------------------------------------------------------"
write-host `r

#clear WSUS settings...............................................................................................
if ($env:usrClearWSUS -eq 'true') {
    write-host "- Clearing any WSUS settings..."
    stop-service -name wuauserv -Force -ea 0
    start-sleep -seconds 5

    "WuServer","WUStatusServer","AccountDomainSID","PingID","SusClientID" | % {
        write-host " - Removing $_ value from Registry..."

        remove-itemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" -Name $_ -Force -ea 0
        if ($?) {write-host "- Removed HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate!$_"}

        remove-itemProperty "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy\GPCache\CacheSet001\WindowsUpdate" -Name $_ -Force -ea 0
        if ($?) {write-host "- Removed HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy\GPCache\CacheSet001\WindowsUpdate!$_"}

        remove-itemProperty "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy\GPCache\CacheSet002\WindowsUpdate" -Name $_ -Force -ea 0
        if ($?) {write-host "- Removed HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy\GPCache\CacheSet002\WindowsUpdate!$_"}
    }

    remove-itemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Force -ea 0
    if ($?) {write-host " - Removed HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\AU!UseWUServer"}

    start-service -name wuauserv
    write-host `r
} else {
    write-host "- Not clearing WSUS settings (not instructed)."
}

#attempt to fix windows update services............................................................................
if ($env:usrResetWUA -eq 'True') {
    write-host "- Attempting to reset Windows Update Agent..."

    #stop services
    write-host " - Stopping BITS/WuauServ/AppIDSvc/CryptSvc services"
    "BITS","wuauserv","appidsvc","cryptsvc" | % {
        stop-service -Name $_ -Force -ea 0
    }
    start-sleep -seconds 5

    #remove qmgr file
    write-host " - Clearing out QMGR data files"
    remove-item "$env:ProgramData\Microsoft\Network\Downloader\qmgr*.dat" -Force -ea 0

    #clear softwaredistribution
    write-host " - Clearing SoftwareDistribution"
    gci "$env:systemroot\SoftwareDistribution" -recurse -ea 0 | ? {$_.Extension -notmatch 'log|txt|edb'} | ? {!$_.PSIsContainer} | % {
        remove-item $_.FullName -force -ea 0
    }

    #clear catroot2
    write-host " - Clearing CatRoot2"
    gci "$env:systemroot\System32\CatRoot2" -recurse -ea 0 | ? {$_.Extension -notmatch 'log|txt|edb'} | ? {!$_.PSIsContainer} | % {
        remove-item $_.FullName -force -ea 0
    }

    write-host ": The following files have been preserved from the above operations:"
    write-host " > Any file with the extension .LOG, .TXT, or .EDB"
    write-host " > Any file being used by the operating system, or for which write-access was denied at time of deletion"

    #reset BITS and WuauServ services to default settings
    write-host " - Resetting WuauServ and BITS services to default configuration"
    start-process sc.exe -argumentlist 'sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)' -Wait -NoNewWindow
    start-process sc.exe -argumentlist 'sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)' -Wait -NoNewWindow

    #remove BITS transfers
    start-process bitsadmin -ArgumentList '/reset /allusers' -nonewwindow -wait

    #stop services
    write-host " - Starting BITS/WuauServ/AppIDSvc/CryptSvc services"
    "BITS","wuauserv","appidsvc","cryptsvc" | % {
        start-service -Name $_ -ea 0
    }

    write-host `r
} else {
    write-host "- Not attempting to reset Windows Update Agent (not instructed)."
}

if ($env:usrUpdateScan -eq 'true') {
    if ($varAux -match 'BadWUA') {
        write-host "! NOTICE: usrUpdateScan was set to TRUE, but this device has a bad WUA version installed."
        write-host "  Patch scans will fail until this is fixed. Please, contact Support to address this issue."
    } else {
        try {
            $varUpdates=$varUpdateSearcher.Search('IsHidden=0 and IsInstalled=0')
            if ($varUpdates) {
                write-host "- Update scan: $($varUpdates.Updates.count) missing updates on this system:"
                $varUpdates.updates | % {
                    if ($_.title) {
                        write-host " - $($_.title)"
                    } else {
                        write-host " - [No Title]"
                    }
                }
            } else {
                write-host "- Update scan: System appears to be fully patched (zero missing updates)."
            }
        } catch {
            write-host "! ERROR: $_"
            write-host "  This system may require action to restore its patching functionality."
        }
    }
} else {
    write-host "- Not attempting to scan for updates (not instructed)."
}

#region Closeout --------------------------------------------------------------------------------------------------

write-host `r
write-host "----[Conclusion]---------------------------------------------------------------------------------------------------------------------------"
write-host `r

if (!$varAux) {
    $varAux="[OK]" #this is never seen; output is always either [Policy] or [NoPolicy]
}

if ($varScriptErrors) {
    write-host "- Potential patching issues were discovered on this Endpoint ($($varAux -replace '\[NoPolicy\]' -replace '\[Policy\]'))."
    writeUDF "PATCHBAD: Potential patching issues on this device | $varAux"
} else {
    write-host "- No patching issues were discovered on this endpoint ($varAux)."
    writeUDF "PATCHOK: No issues with patching were discovered on this device | $varAux"
}

@"

----[Issue legend (for filtering UDFs)]----------------------------------------------------------------------------------------------------

             [WSUS] Device has WSUS config     [TargetSet] OS version block applied
Status       [LTSC] Windows extended support    [DOptimis] Delivery optimisation in use
tags   [DEFQuality] Quality update deferrals      [Policy] DRMM P/Mgmt Policy set
       [DEFFeature] Feature update deferrals    [NoPolicy] DRMM P/Mgmt Policy absent
...................................................................................................
           [BadWUA] Known bad WUAgent version        [YLW] 'Yellow'-tier OS upgrade block set
Issues  [AuditFail] DRMM Patch Audit failure         [ORG] 'Orange'-tier OS upgrade block set
        [PatchFail] DRMM Patch run failure           [RED] 'Red'-tier OS upgrade block set


! If this Component left issues unresolved, please also check the Microsoft Windows Update Diagnostic Tool: https://aka.ms/wudiag
"@ | write-host
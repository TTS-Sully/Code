##########################################################################################################################
### Tech Team Solutions - Huntress Agent and Rio Install Monitor (currently seperated in RMM)
### Last Updated 2026.04.13
### Written by ESS
##########################################################################################################################

$paths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

$ChkSvc = (Get-service -name "HuntressAgent" -ErrorAction SilentlyContinue)

If ($ChkSvc.status -eq "Running"){
    write-host '<-Start Result->'
 	write-host "STATUS=Huntress Service Running"
 	write-host '<-End Result->'
 	#exit 0
} else {
    #checking install status takes some time so it's only done if the agent is detected to not be running.
    $AgentInstallStatus = Get-ItemProperty $paths | Where-Object { $_.DisplayName -like 'Huntress Agent' }
    if ($null -eq $AgentInstallStatus){
            write-host '<-Start Result->'
            write-host "Status=Huntress Agent is not Installed"
            write-host '<-End Result->'
            #exit 1
    }Else {
        write-host '<-Start Result->'
        write-host "Status=Huntress Agent is Installed but but the service is not running" #only would have gotten to this branch if agent wasn't running
        write-host '<-End Result->'
        #exit 1
    }
}

$ChkSvc = (Get-service -name "HuntressRio" -ErrorAction SilentlyContinue)

If ($ChkSvc.status -eq "Running"){
    write-host '<-Start Result->'
 	write-host "STATUS=Huntress Rio Service Running"
 	write-host '<-End Result->'
 	#exit 0
} else {
    #checking install status takes some time so it's only done if the agent is detected to not be running.
    $ReoInstallStatus = Get-ItemProperty $paths | Where-Object { $_.DisplayName -like 'Huntress Rio' }
    if ($null -eq $ReoInstallStatus){
            write-host '<-Start Result->'
            write-host "Status=Huntress Rio is not Installed"
            write-host '<-End Result->'
            #exit 1
    }Else {
        write-host '<-Start Result->'
        write-host "Status=Huntress Rio is Installed but but the service is not running" #only would have gotten to this branch if agent wasn't running
        write-host '<-End Result->'
        #exit 1
    }
}
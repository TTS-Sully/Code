##########################################################################################################################
### Tech Team Solutions HP Drivers and Software Updates Script
### Last Updated 2025.09.25
### Written by ESS
##########################################################################################################################
# Requires -RunAsAdministrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Script needs to be run as administrator."
    exit
}

#Requires -Version 5.1

##########################################################################################################################
### Prep and Run HP Drivers and Software Updates
##########################################################################################################################

$system = Get-CimInstance -ClassName Win32_ComputerSystem
if ($system.Manufacturer -eq "HP") {
    ##########################################################################################################################
    ### Install Required Modules
    ##########################################################################################################################

    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$False | Out-Null
    Install-PackageProvider -Name NuGet -Force -Confirm:$false -ForceBootstrap

    # List of modules to check and install if missing
    $modules = @(
        @{ Name = "PSWindowsUpdate"; Force = $true },
        # @{ Name = "PowerShellGet"; Force = $true; AllowClobber = $true },
        @{ Name = "HPCMSL"; Force = $true },
        @{ Name = "HPDrivers"; Force = $true }
    )

    foreach ($module in $modules) {
        $installed = Get-Module -ListAvailable -Name $module.Name
        if (-not $installed) {
            Write-Host "Installing module: $($module.Name)..."
            Install-Module -Name $module.Name -Force:$($module.Force) -Confirm:$False -AllowClobber:$($module.AllowClobber -or $false)
        } else {
            Write-Host "Module $($module.Name) is already installed."
        }
    }

    #Get-HPDrivers -NoPrompt -ShowSoftware -BIOS -DeleteInstallationFiles -SuspendBL
    Get-HPDrivers -NoPrompt -ShowSoftware -DeleteInstallationFiles -SuspendBL

    # Output the result
    Write-Output "HP Drivers and Software Updates completed." | Write-Log "HP Drivers and Software Updates completed."
} else {
    Write-Output "This system is not an HP device. Skipping HP Drivers and Software Updates." | Write-Log "This system is not an HP device. Skipping HP Drivers and Software Updates."
}
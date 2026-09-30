#################################################################################################
# This script sets the baseline advanced windows settings for non-domain joined windows endpoints.
#
# 1. Enables "Other Users" at login
# 2. Enables Fast User Switching
# 3. Optionally shows all local users
#
# Created by: Erik Sullivan (and Copilot)
# Date: 2026-03-13
#################################################################################################


[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$ShowAllUsers
)

# Ensure we are running as Administrator
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Error "This script must be run as Administrator (elevated PowerShell)."
    exit 1
}

$systemPoliciesPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'

function EDIT-RegistryValue {
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [ValidateSet('String','ExpandString','Binary','DWord','MultiString','QWord')]
        [string]$Type,
        [Parameter(Mandatory)]
        [Object]$Value
    )

    if (-not (Test-Path -Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }

    $current = $null
    try {
        $current = Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop | Select-Object -ExpandProperty $Name
    } catch {
        # Value does not exist
    }

    if ($null -eq $current -or $current -ne $Value) {
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
    } else {
        Write-Verbose "No change needed for $Path\$Name (already $Value)."
    }
}

Write-Verbose "Configuring Logon UI and Fast User Switching settings..."

# 1) Enable "Other User" (DontDisplayLastUsername = 0)
EDIT-RegistryValue -Path $systemPoliciesPath -Name 'DontDisplayLastUsername' -Type DWord -Value 0

# 2) Enable User Switching (HideFastUserSwitching = 0)
EDIT-RegistryValue -Path $systemPoliciesPath -Name 'HideFastUserSwitching' -Type DWord -Value 0

# 3) Optional: Show all local users (EnumerateLocalUsers = 1)
if ($ShowAllUsers.IsPresent) {
    EDIT-RegistryValue -Path $systemPoliciesPath -Name 'EnumerateLocalUsers' -Type DWord -Value 1
}

Write-Host "Configuration complete."
Write-Host "Note: You may need to sign out or reboot for the logon screen to reflect changes."

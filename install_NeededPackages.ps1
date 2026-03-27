##########################################################################################################################
### Tech Team Solutions PowerShell Package Installation Script
### Last Updated 2026.03.25
### Written by ESS with help from CoPilot
##########################################################################################################################

# Force TLS 1.2 (critical for older systems)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ---------- PSGallery ----------
if (-not (Get-PackageSource -Name PSGallery -ErrorAction SilentlyContinue)) {
    Register-PackageSource -Name PSGallery -ProviderName PowerShellGet -Location https://www.powershellgallery.com/api/v2 -Trusted -Force
} else {
    Set-PackageSource -Name PSGallery -Trusted -Force
}

# ---------- NuGet Provider ----------
if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
}

if (-not (Get-Module -ListAvailable -Name PendingReboot)) {
    Install-Module PendingReboot -Repository PSGallery -Force -SkipPublisherCheck
}

$RequiredVersion = '2.2.1.4'

$Installed = Get-Module -ListAvailable PSWindowsUpdate |
             Where-Object { $_.Version -eq $RequiredVersion }

if (-not $Installed) {
    Install-Module PSWindowsUpdate -Repository PSGallery -RequiredVersion $RequiredVersion -Force -SkipPublisherCheck -AllowClobber
}

Import-Module PSWindowsUpdate -Force
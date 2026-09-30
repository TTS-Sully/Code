##########################################################################################################################
### Tech Team Solutions PowerShell Package Installation Script
### Last Updated 2026.03.25
### Written by ESS with help from CoPilot
##########################################################################################################################

### Force TLS 1.2 (critical for older systems)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

### PSGallery
try {
    if (-not (Get-PackageSource -Name PSGallery -ErrorAction SilentlyContinue)) {
        Register-PackageSource `
            -Name PSGallery `
            -ProviderName PowerShellGet `
            -Location "https://www.powershellgallery.com/api/v2" `
            -Trusted `
            -Force `
            -ErrorAction Stop

        Write-Host "[SUCCESS] PSGallery package source registered." -ForegroundColor Green
    }
    else {
        Set-PackageSource -Name PSGallery -Trusted -Force -ErrorAction Stop
        Write-Host "[SUCCESS] PSGallery package source already present and trusted." -ForegroundColor Green
    }
} catch {
    Write-Host "[ERROR] Failed to configure PSGallery: $($_.Exception.Message)" -ForegroundColor Red
}

### Install PowerShellGet Module (if not already installed)
try {
    Install-Module `
        -Name PowerShellGet `
        -Force `
        -AllowClobber `
        -Scope AllUsers `
        -Confirm:$false `
        -ErrorAction Stop

    Write-Host "[SUCCESS] PowerShellGet installed." -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to install PowerShellGet: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

### PendingReboot Module
try {
    if (-not (Get-Module -ListAvailable -Name PendingReboot)) {
        Install-Module `
            -Name PendingReboot `
            -Repository PSGallery `
            -Force `
            -SkipPublisherCheck `
            -ErrorAction Stop

        Write-Host "[SUCCESS] PendingReboot module installed." -ForegroundColor Green
    }
    else {
        Write-Host "[SUCCESS] PendingReboot module already installed." -ForegroundColor Green
    }
} catch {
    Write-Host "[ERROR] Failed to install PendingReboot module: $($_.Exception.Message)" -ForegroundColor Red
}

### PSWindowsUpdate Module
try {
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Install-Module `
            -Name PSWindowsUpdate `
            -Repository PSGallery `
            -RequiredVersion 2.2.1.4 `
            -Force `
            -SkipPublisherCheck `
            -AllowClobber `
            -ErrorAction Stop

        Write-Host "[SUCCESS] PSWindowsUpdate module installed." -ForegroundColor Green
    }
    else {
        Write-Host "[SUCCESS] PSWindowsUpdate module already installed." -ForegroundColor Green
    }
} catch {
    Write-Host "[ERROR] Failed to install PSWindowsUpdate module: $($_.Exception.Message)" -ForegroundColor Red
}

### Import PSWindowsUpdate
try {
    Import-Module PSWindowsUpdate -Force -ErrorAction Stop
    Write-Host "[SUCCESS] PSWindowsUpdate module imported." -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to import PSWindowsUpdate module: $($_.Exception.Message)" -ForegroundColor Red
}
<#
.SYNOPSIS
    Deploys PowerShell 7 silently on Windows 11 endpoints via RMM.
.DESCRIPTION
    Checks if PowerShell 7 is already installed. If not, it detects the architecture,
    downloads the latest stable MSI package from GitHub, and performs a silent install.
#>

# 1. Check if PowerShell 7 is already installed
if (Get-Command pwsh.exe -ErrorAction SilentlyContinue) {
    Write-Output "PowerShell 7 is already installed on this machine. Exiting."
    exit 0
}

# 2. Determine system architecture and set download URL (Using stable v7.4+ LTS branch template)
\$arch = (Get-CimInstance Win32_ComputerSystem).OSArchitecture
if (\$arch -like "*64-bit*") {
    # Standard x64 Architecture
    \$url = "https://github.com"
    \$fileName = "PowerShell-7.4.6-win-x64.msi"
} elseif (\$arch -like "*ARM*") {
    # ARM64 Architecture (Supported on newer Windows 11 laptops)
    \$url = "https://github.com"
    \$fileName = "PowerShell-7.4.6-win-arm64.msi"
} else {
    Write-Error "Unsupported architecture: \$arch"
    exit 1
}

tempDir = Join-Path env:SystemRoot "Temp"
\$msiPath = Join-Path tempDir fileName

# 3. Download the MSI payload
try {
    Write-Output "Downloading PowerShell 7 installer from \$url..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri url -OutFile msiPath -UseBasicParsing
} catch {
    Write-Error "Failed to download the MSI installer. Error: \$_"
    exit 1
}

# 4. Perform the Silent MSI Installation
try {
    Write-Output "Starting silent installation..."
    # Arguments: /qn (Silent), ADD_PATH=1 (Adds to system environment variables)
    \$arguments = "/i `"$msiPath`" /qn /norestart ADD_PATH=1"
    
    pocess = Start-Process -FilePath "msiexec.exe" -ArgumentList arguments -Wait -NoNewWindow -PassThru
    
    if (\$pocess.ExitCode -eq 0) {
        Write-Output "PowerShell 7 successfully installed."
        # Clean up installer
        Remove-Item -Path \$msiPath -Force -ErrorAction SilentlyContinue
        exit 0
    } else {
        Write-Error "MSI installation failed with Exit Code: (pocess.ExitCode)"
        exit 1
    }
} catch {
    Write-Error "An unexpected error occurred during installation: \$_"
    exit 1
}
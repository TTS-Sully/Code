# Define the GitHub API URL for PowerShell releases
$apiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"

# Fetch the latest release information
$latestRelease = Invoke-RestMethod -Uri $apiUrl -Headers @{ "User-Agent" = "Mozilla/5.0" }

# Extract the download URL for the MSI installer
$installerUrl = $latestRelease.assets | Where-Object { $_.name -like "*win-x64.msi" } | Select-Object -ExpandProperty browser_download_url
# Define the path to save the installer
$installerPath = "$env:TEMP\PowerShell-latest-win-x64.msi"

# Download the installer
Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

# Install PowerShell 7
Start-Process -FilePath $installerPath -ArgumentList "/quiet" -Wait

# Verify installation
$installedVersion = & "C:\Program Files\PowerShell\7\pwsh.exe" -NoLogo -NoProfile -Command '$PSVersionTable.PSVersion'
Write-Output "PowerShell 7 installed successfully. Version: $installedVersion"

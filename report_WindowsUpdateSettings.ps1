# Define registry paths
$wuPaths = @(
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update"
)

# Function to read registry values
function Get-WindowsUpdateRegistrySettings {
    param (
        [string[]]$Paths
    )

    foreach ($path in $Paths) {
        Write-Host "`nChecking: $path" -ForegroundColor Cyan
        if (Test-Path $path) {
            Get-ItemProperty -Path $path | Select-Object * | Format-List
        } else {
            Write-Host "Path not found." -ForegroundColor DarkGray
        }
    }
}

# Run the function
Get-WindowsUpdateRegistrySettings -Paths $wuPaths
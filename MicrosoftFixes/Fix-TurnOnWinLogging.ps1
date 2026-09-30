# Define the registry path
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\GPExtensions\{827D319E-6EAC-11D2-A4EA-00C04F79F83A}"

# Create the registry key if it doesn't exist
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Set the ExtensionDebugLevel DWORD value
Set-ItemProperty -Path $regPath -Name "ExtensionDebugLevel" -Value 2 -Type DWord

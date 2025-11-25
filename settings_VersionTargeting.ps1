# Define the registry path
$regPath = "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate"

# Check if the path exists
if (-not (Test-Path $regPath)) {
    # Create the path
    New-Item -Path $regPath -Force
    Write-Host "Registry path created: $regPath"
} else {
    Write-Host "Registry path already exists: $regPath"
}

Write-Host "Attempting Version Targeting..."
try{
  #Windows Version Targeting
  Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate -Name TargetReleaseVersion -Value 1
  Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate -Name ProductVersion -Value "Windows 10"
  # Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate -Name TargetReleaseVersionInfo -Value "23H2"
  Write-Host "Version Targeting Has Been Applied"
  exit 0
} catch {
  Write-Host "Version Targeting Has Encountered Error"
  exit 1
}
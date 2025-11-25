cls

# Load CredentialManager module (install if not present)
if (-not (Get-Module -ListAvailable -Name CredentialManager)) {
    Install-Module -Name CredentialManager -Force -Scope CurrentUser
}

Import-Module CredentialManager
# Get all credentials stored in Windows Credential Manager
$credentials = Get-StoredCredential -Type Generic

# Display each credential's target and username
foreach ($cred in $credentials) {
    Write-Output "Target: $($cred.TargetName)"
    Write-Output "Username: $($cred.UserName)"
    Write-Output "-----------------------------------"
}
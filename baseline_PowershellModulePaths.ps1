##########################################################################################################################
### Tech Team Solutions Powershell Enviromental Variable Baseline Script
### Last Updated 2026.08.12
### Written by ESS
##########################################################################################################################

$goodtorun = $true

# Required Windows PowerShell module directories
$requiredEntries = @(
    (Join-Path $env:ProgramFiles 'WindowsPowerShell\Modules'),
    (Join-Path $env:SystemRoot 'system32\WindowsPowerShell\v1.0\Modules')
)

Write-Host "Checking required directories..."

foreach ($directory in $requiredEntries) {
    if (Test-Path -LiteralPath $directory -PathType Container) {
        Write-Host "Exists:  $directory" -ForegroundColor Green
    }
    else {
        Write-Host "Missing: $directory" -ForegroundColor Yellow
        $goodtorun = $false
    }
}

# Stop the script if any required directories are missing.
if (-not $goodtorun) {
    Write-Host "One or more required directories are missing. " -ForegroundColor Red
    exit 1
}

# Read the existing machine-level PSModulePath.
$existingMachineValue = [System.Environment]::GetEnvironmentVariable(
    'PSModulePath',
    'Machine'
)

if ($null -eq $existingMachineValue) {
    $existingMachineValue = ''
}

# The remainder of the script can then merge the required directories
# into the existing PSModulePath without removing anything.

$requiredEntries = @(
    (Join-Path $env:ProgramFiles 'WindowsPowerShell\Modules'),
    (Join-Path $env:SystemRoot 'system32\WindowsPowerShell\v1.0\Modules')
)

# Read the existing machine-level value. Treat an unset value as empty.
$existingMachineValue = [System.Environment]::GetEnvironmentVariable('PSModulePath','Machine')

if ($null -eq $existingMachineValue) {
    $existingMachineValue = ''
}

$existingEntries = @(
    $existingMachineValue -split ';' |
        ForEach-Object { $_.Trim() } |
        Where-Object { -not [System.String]::IsNullOrWhiteSpace($_) }
)
`

# Create missing directories without modifying existing contents.
foreach ($entry in $requiredEntries) {
    if (-not (Test-Path -LiteralPath $entry -PathType Container)) {
        try {
            New-Item -ItemType Directory -Path $entry -Force -ErrorAction Stop |
                Out-Null
            Write-Host "Created: $entry"
        }
        catch {
            Write-Error "Unable to create '$entry': $($_.Exception.Message)"
        }
    }
    else {
        Write-Host "Exists:  $entry"
    }
}

# Add required items only when they are not already present.
$mergedEntries = [System.Collections.Generic.List[string]]::new()

$alreadyPresent = $false

foreach ($existing in $mergedEntries) {
    if ([System.String]::Equals(
            [System.Environment]::ExpandEnvironmentVariables($existing),
            $expandedEntry,
            [System.StringComparison]::OrdinalIgnoreCase
        )) {
        $alreadyPresent = $true
        break
    }
}

if (-not $alreadyPresent) {
    [void]$mergedEntries.Add($entry)
}

$newMachineValue = $mergedEntries -join ';'

if ($newMachineValue -ne $existingMachineValue) {
    [System.Environment]::SetEnvironmentVariable('PSModulePath', $newMachineValue, 'Machine')

    Write-Host 'Updated the machine-level PSModulePath.'
}
else {
    Write-Host 'Machine-level PSModulePath already contains all required entries.'
}

# Refresh the environment of the current PowerShell process.
[System.Environment]::SetEnvironmentVariable('PSModulePath', $newMachineValue, 'Process')

Write-Host ''
Write-Host 'Effective PSModulePath:'
$env:PSModulePath -split ';' |
    ForEach-Object { "  $_" }
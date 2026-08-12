##########################################################################################################################
### Tech Team Solutions Powershell Enviromental Variable Baseline Script
### Last Updated 2026.08.12
### Written by ESS
##########################################################################################################################
write-Host "v5"

$requiredPaths = @(
    (Join-Path $env:ProgramFiles 'WindowsPowerShell\Modules'),
    (Join-Path $env:SystemRoot 'system32\WindowsPowerShell\v1.0\Modules')
)

# Create missing directories.
foreach ($path in $requiredPaths) {
    if (Test-Path -LiteralPath $path -PathType Container) {
        Write-Host "Exists:  $path" -ForegroundColor Green
    }
    else {
        try {
            New-Item -ItemType Directory -Path $path -Force -ErrorAction Stop | Out-Null
            Write-Host "Created: $path" -ForegroundColor Green
        }
        catch {
            Write-Error "Unable to create '$path': $($_.Exception.Message)"
            exit 1
        }
    }
}

# Retrieve the existing machine-level PSModulePath.
$currentPath = [System.Environment]::GetEnvironmentVariable('PSModulePath', 'Machine')

if ([System.String]::IsNullOrWhiteSpace($currentPath)) {
    $currentEntries = @()
}
else {
    $currentEntries = @(
        $currentPath -split ';' |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_ }
    )
}

# Add required paths, preserving existing entries and order.
foreach ($path in $requiredPaths) {
    $pathExists = $currentEntries | Where-Object {
        $_.TrimEnd('\') -ieq $path.TrimEnd('\')
    }

    if (-not $pathExists) {
        $currentEntries += $path
        Write-Host "Added to PSModulePath: $path" -ForegroundColor Cyan
    }
}

$badEntries = @(
    'C:\Program Files\WindowsPowerShell\ModulesC:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules'
)

$newPathEntries = [System.Collections.Generic.List[string]]::new()

foreach ($path in @($currentEntries + $requiredPaths)) {
    if ([System.String]::IsNullOrWhiteSpace($path)) {
        continue
    }

    $cleanPath = $path.Trim().TrimEnd('\')

    # Remove known bad concatenated entries.
    if ($badEntries -contains $cleanPath) {
        Write-Host "Removing malformed entry: $cleanPath" -ForegroundColor Yellow
        continue
    }

    # Add only unique, valid entries.
    if (-not ($newPathEntries | Where-Object { $_ -ieq $cleanPath })) {
        [void]$newPathEntries.Add($cleanPath)
    }
}

$newPath = $newPathEntries -join ';'

# Update only if the value has changed.
if ($newPath -ne $currentPath) {
    [System.Environment]::SetEnvironmentVariable('PSModulePath', $newPath, 'Machine')
    Write-Host 'Machine-level PSModulePath updated.' -ForegroundColor Green
}
else {
    Write-Host 'Machine-level PSModulePath is already configured.' -ForegroundColor Green
}

# Update this PowerShell session.
$env:PSModulePath = $newPath

Write-Host "Current PSModulePath:"
$env:PSModulePath -split ';' | ForEach-Object {
    Write-Host "  $_"
}
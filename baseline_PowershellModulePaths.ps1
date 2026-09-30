##########################################################################################################################
### Tech Team Solutions Powershell Enviromental Variable Baseline Script
### Last Updated 2026.08.12
### Written by ESS
##########################################################################################################################
write-Host "v9"

# Keep variables in their original form.
$requiredPaths = @(
    '%ProgramFiles%\WindowsPowerShell\Modules'
    '%SystemRoot%\system32\WindowsPowerShell\v1.0\Modules'
)

$currentPath = [System.Environment]::GetEnvironmentVariable('PSModulePath', 'Machine')

$newPathEntries = [System.Collections.Generic.List[string]]::new()

foreach ($path in @($currentPath.Split(';') + $requiredPaths)) {
    if ([System.String]::IsNullOrWhiteSpace($path)) {
        continue
    }

    # Preserve the original environment-variable notation.
    $originalPath = $path.Trim().TrimEnd('\')

    # Expand only for comparison.
    $expandedPath = [System.Environment]::ExpandEnvironmentVariables($originalPath).TrimEnd('\')

    # Remove the known malformed concatenated entry.
    $malformedPaths = @(
        'C:\Program Files\WindowsPowerShell\Modules'
        'C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules'
        'C:\Program Files\WindowsPowerShell\ModulesC:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules'
    )

    if ($expandedPath -ieq $malformedPaths) {
        Write-Host "Removing malformed entry: $originalPath" -ForegroundColor Yellow
        continue
    }

    # Prevent duplicates while preserving the first entry's original format.
    $alreadyExists = $newPathEntries | Where-Object {
        ([System.Environment]::ExpandEnvironmentVariables($_)).TrimEnd('\') -ieq $expandedPath
    }

    if (-not $alreadyExists) {
        [void]$newPathEntries.Add($originalPath)
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
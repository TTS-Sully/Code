#################################################################################################
# This script removes duplicate files in a folder based on their base name.
# It normalizes the filenames by removing numbers in parentheses and includes the file size in the comparison.
# It keeps the first file found and removes the rest.
# Created by: Erik Sullivan
# Date: 2025-04-23
#################################################################################################

# Get all files in the folder
$files = Get-ChildItem -File

# Normalize filenames by removing numbers in parentheses and include file size
$normalizedFiles = $files | Select-Object @{Name='NormalizedName';Expression={ $_.BaseName -replace '\(\d+\)', '' }}, FullName, Length

# Group files by their normalized name and file size
$groupedFiles = $normalizedFiles | Group-Object -Property @{Expression={ "$($_.NormalizedName.TrimEnd(" "))-$($_.Length)" }}

foreach ($group in $groupedFiles) {
    # If there are duplicates, keep the first one and remove the rest
    if ($group.Group.Count -gt 1) {
        Write-Host "Removing duplicates for: $($group.Name)"
        $filesToRemove = $group.Group | Select-Object
        foreach ($file in $filesToRemove) {
            Remove-Item -Path $file.FullName -Force
            Write-Host "Removed: $($file.FullName)"
        }
    } else {
        Write-Host "No duplicates found for: $($group.Name)"
    }
}
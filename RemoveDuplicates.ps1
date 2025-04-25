#################################################################################################
# This script removes duplicate files in a folder based on their base name.
# It normalizes the filenames by removing numbers in parentheses and includes the file size in the comparison.
# It keeps the first file found and removes the rest.
# Created by: Erik Sullivan
# Date: 2025-04-23
#################################################################################################

# Get all files in the folder
$files = Get-ChildItem -File

$testhash = Get-FileHash -Algorithm MD5 -Path $files.FullName | Select-Object -Property Hash, Path, FullName
$testhash | Sort-Object -Property Hash | Group-Object -Property Hash | ForEach-Object {
    if($_.Count -gt 1) {
        Write-Host "Duplicate files found:" -ForegroundColor Yellow
        $_.Group | ForEach-Object { Write-Host $_.Path -ForegroundColor Red }
    } else {
        Write-Host "No duplicates found for: $($_.FullName)" -ForegroundColor Green
    }
}
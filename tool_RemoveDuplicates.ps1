#################################################################################################
# This script removes duplicate files in a folder based on their base name.
# It normalizes the filenames by removing numbers in parentheses and includes the file size in the comparison.
# It keeps the first file found and removes the rest.
# Created by: Erik Sullivan
# Date: 2025-04-23
#################################################################################################

# Get all files in the folder
$files = Get-ChildItem -File
$totalremoved = 0

# Create a hash table to store the base names and their corresponding file objects
$dataFORMATTED = $files | ForEach-Object {
    $hash = Get-FileHash -Algorithm MD5 -Path $_.FullName
    [PSCustomObject]@{
        Path = $_.FullName
        Hash = $hash.Hash
        CreationTime = $_.CreationTime
    }
}

# Format the data sort by CreatuionTime and group by Hash
$dataFORMATTED | Sort-Object -Property CreationTime | Group-Object -Property Hash | ForEach-Object {
    # Check if there are duplicates (more than one file with the same hash)
    if($_.Count -gt 1){
        # Write-Host "Duplicate files found:" -ForegroundColor Yellow
        # Find the earliest file based on CreationTime and remove the rest
        $earliestFile = $_.Group | Sort-Object -Property CreationTime | Select-Object -First 1

        # Take the group of files keep the earliest file and remove the rest
        $_.Group | ForEach-Object {
            if ($_.Path -ne $earliestFile.Path){
                # Write-Host $_.CreationTime  $_.Path -ForegroundColor Red
                $_ | Remove-Item -Force -ErrorAction SilentlyContinue
                $totalremoved++
            } else {
                # Write-Host $_.CreationTime  $_.Path -ForegroundColor Green
            }
        }
    } else {
        #$_.Group | ForEach-Object { Write-Host "No duplicates found for: " $_.Path -ForegroundColor Green }
    }
}

Write-Host "Total files removed: $totalremoved" -ForegroundColor Green
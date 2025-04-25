#################################################################################################
# This script removes duplicate files in a folder based on their base name.
# It normalizes the filenames by removing numbers in parentheses and includes the file size in the comparison.
# It keeps the first file found and removes the rest.
# Created by: Erik Sullivan
# Date: 2025-04-23
#################################################################################################

# Get all files in the folder
$files = Get-ChildItem -File

$dataFORMATTED = $files | ForEach-Object {
    $hash = Get-FileHash -Algorithm MD5 -Path $_.FullName
    [PSCustomObject]@{
        Path = $_.FullName
        Hash = $hash.Hash
        CreationTime = $_.CreationTime
    }
}
    
$dataFORMATTED | Sort-Object -Property CreationTime | Group-Object -Property Hash | ForEach-Object {
    if($_.Count -gt 1){
        Write-Host "Duplicate files found:" -ForegroundColor Yellow

        #$_.Group | Format-List *
        $_.Group | ForEach-Object {
            if ($_.Path -ne $earliestFile.Path){
                $local = Get-Item $_.Path #| Format-List -Property Name, CreationTimeUtc
                Write-Host $local.CreationTimeUtc  $local.Name -ForegroundColor Red
            } else {
                Write-Host $earliestFile.CreationTimeUtc $earliestFile.Path -ForegroundColor Green
            }
        }
    } else {
        $_.Group | ForEach-Object { Write-Host "No duplicates found for: " $_.Path -ForegroundColor Green }
    }
}
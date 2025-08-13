# Set the folder path
$folderPath = (Get-Location).Path
#$folderPath = "C:\example\folder"

# Get the current date
$currentDate = Get-Date

# Define the age threshold (6 months ago)
$thresholdDate = $currentDate.AddMonths(-6)

# Get all files in the folder
$files = Get-ChildItem -Path $folderPath -File

# Loop through each file and delete if older than threshold
foreach ($file in $files) {
    if ($file.LastWriteTime -lt $thresholdDate) {
        Remove-Item $file.FullName -Force
        Write-Host "Deleted: $($file.FullName)"
    }
}
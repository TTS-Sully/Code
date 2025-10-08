# Define the folder name you're searching for
$targetUserFolder = $env:TargetUserFolder

# Define the base path where user folders are typically located
$basePath = "C:\Users"

# Construct the full path
$fullPath = Join-Path -Path $basePath -ChildPath $targetUserFolder

# Check if the folder exists
if (Test-Path -Path $fullPath -PathType Container) {
    Write-Host "Folder found: $fullPath"
    exit 0
} else {
    Write-Host "Folder not found: $fullPath"
    exit 1
}
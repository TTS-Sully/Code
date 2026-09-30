$pattern = "*akira*"  # Change this to your desired wildcard pattern
# $pattern = $env:PatternToHunt

# Get all drives with a drive letter
$drives = Get-PSDrive -PSProvider 'FileSystem' | Where-Object { $_.Root -match '^[A-Z]:\\$' }

foreach ($drive in $drives) {
    Write-Host "Searching in $($drive.Root)..."
    try {
        $results = Get-ChildItem -Path $drive.Root -Recurse -Filter $pattern -ErrorAction SilentlyContinue | Select-Object FullName
           
    } catch {
        Write-Host "Error accessing $($drive.Root): $_"
        Exit 0
    }

    if ($results) {
        foreach ($result in $results) {
            Write-Host "Found: $($result.FullName)" -ForegroundColor Yellow
        }
        exit 1
    } else {
        Write-Host "No files found matching pattern '$pattern' in $($drive.Root)." -ForegroundColor Gray
        Exit 0
    }
}
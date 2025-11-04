# Define the path to the folder
$folderPath = (Get-Location).Path

# Get the root-level children (files and folders)
$children = Get-ChildItem -Path $folderPath -Depth 0 -Force

# Initialize total size variable
$totalSize = 0

# Loop through each child item
foreach ($child in $children) {
    if ($child.PSIsContainer) {
        # If the child is a folder, get the size of all files within it
        #$folderSize = (Get-ChildItem -Path $child.FullName -Recurse -ErrorAction SilentlyContinue| Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        $folderSize = (Get-ChildItem -Path $child.FullName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum

        
        $totalSize += $folderSize
        $fileSizeInGB = [Math]::Round($folderSize / 1GB, 2)
        
        $gb_formatted = "{0:N2}" -f $fileSizeInGB # Formats to 2 decimal places
        Write-Output "$child : $gb_formatted GB"
    } else {
        # If the child is a file, add its size directly
        $totalSize += $child.Length
        $fileSizeInGB = [Math]::Round($child.Length / 1GB, 5)
        $gb_formatted = "{0:N2}" -f $fileSizeInGB # Formats to 2 decimal places
        Write-Output "$child : $gb_formatted GB"
    }

}
# Here to for copy/paste run

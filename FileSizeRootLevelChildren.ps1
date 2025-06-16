# Define the path to the folder
$folderPath = (Get-Location).Path

# Get the root-level children (files and folders)
$children = Get-ChildItem -Path $folderPath -Depth 0

# Initialize total size variable
$totalSize = 0

# Loop through each child item
foreach ($child in $children) {
    if ($child.PSIsContainer) {
        # If the child is a folder, get the size of all files within it
        $folderSize = (Get-ChildItem -Path $child.FullName -Recurse -ErrorAction SilentlyContinue| Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        
        $totalSize += $folderSize
        $fileSizeInGB = [Math]::Round($folderSize / 1GB, 2)
        $gb_formatted = "{0:N2}" -f $fileSizeInGB # Formats to 2 decimal places
        Write-Output "$child : $gb_formatted GB"
    } else {
        # If the child is a file, add its size directly
        $totalSize += $child.Length
        $fileSizeInGB = [Math]::Round($child.Length / 1GB, 2)
        $gb_formatted = "{0:N2}" -f $fileSizeInGB # Formats to 2 decimal places
        Write-Output "$child : $gb_formatted GB"
    }

}

#$totalSizeInGB = [Math]::Round($totalSize / 1GB, 2)
#$totalgb_formatted = "{0:N2}" -f $totalSizeInGB # Formats to 2 decimal places
#Write-Output "Total size of root-level children: $totalgb_formatted GB"
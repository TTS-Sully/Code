$rootPath = "E:\Share\Horticulture"
$permissionsCsv = "C:\Temp\FolderPermissions.csv"
$groupMembersCsv = "C:\Temp\GroupMemberships.csv"

$permissionReport = @()
$groupMemberships = @()
$groupsToResolve = @{}

# Get all directories safely
$folders = Get-ChildItem -Path $rootPath -Directory -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -and (Test-Path -LiteralPath $_.FullName) } -ErrorAction SilentlyContinue

foreach ($folder in $folders) {
    try {
        if ($folder.FullName -and (Test-Path -LiteralPath $folder.FullName)) {
            $acl = Get-Acl -Path $folder.FullName -ErrorAction SilentlyContinue
            $nonInherited = $acl.Access | Where-Object { -not $_.IsInherited }
            foreach ($entry in $nonInherited) {
                $identity = $entry.IdentityReference.Value
                $permissionReport += [PSCustomObject]@{
                    Identity   = $identity
                    FolderPath = $folder.FullName
                }

                if ($identity -match "^(?:(?!\\).)*$" -or $identity -match ".*\\.*") {
                    $groupsToResolve[$identity] = $true
                }
            }
        }
    } catch {
        # Skip folders that cause errors
        continue
    }
}

# Export folder permissions
$permissionReport | Export-Csv -Path $permissionsCsv -NoTypeInformation -Encoding UTF8

# Resolve group members
foreach ($group in $groupsToResolve.Keys) {
    try {
        $members = Get-ADGroupMember -Identity $group -Recursive | Select-Object -ExpandProperty SamAccountName
        foreach ($member in $members) {
            $groupMemberships += [PSCustomObject]@{
                Group  = $group
                Member = $member
            }
        }
    } catch {
        $groupMemberships += [PSCustomObject]@{
            Group  = $group
            Member = "(Failed to resolve or not a group)"
        }
    }
}

# Export group memberships
$groupMemberships | Export-Csv -Path $groupMembersCsv -NoTypeInformation -Encoding UTF8

Write-Host "✅ CSV reports saved to:"
Write-Host $permissionsCsv
Write-Host $groupMembersCsv

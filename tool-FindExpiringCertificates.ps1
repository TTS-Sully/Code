
# Set time window (6 months from now)
$threshold = (Get-Date).AddMonths(6)

# Stores to check
$stores = @(
    "Cert:\LocalMachine\My",
    "Cert:\LocalMachine\Root",
    "Cert:\LocalMachine\CA",
    "Cert:\CurrentUser\My",
    "Cert:\CurrentUser\Root",
    "Cert:\CurrentUser\CA"
)

$results = @()

foreach ($store in $stores) {
    try {
        Get-ChildItem -Path $store -Recurse -ErrorAction Stop | ForEach-Object {
            if ($_.NotAfter -le $threshold) {
                $results += [PSCustomObject]@{
                    Store        = $store
                    Subject      = $_.Subject
                    Issuer       = $_.Issuer
                    Thumbprint   = $_.Thumbprint
                    Expiration   = $_.NotAfter
                    DaysRemaining = ($_.NotAfter - (Get-Date)).Days
                }
            }
        }
    } catch {
        Write-Verbose "Could not access $store"
    }
}

# Output results
if ($results.Count -gt 0) {
    $results | Sort-Object Expiration | Format-Table -AutoSize
} else {
    Write-Host "No certificates expiring within the next 6 months."
}

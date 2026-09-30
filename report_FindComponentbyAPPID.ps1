# .\Search-DCOMAppId.ps1 -AppId "12345678-1234-1234-1234-123456789ABC"

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\{?[0-9a-fA-F-]{36}\}?$')]
    [string]$AppId
)

$normalizedAppId = $AppId.Trim('{}').ToUpperInvariant()
$registryPaths = @(
    'HKLM:\SOFTWARE\Classes\AppID',
    'HKLM:\SOFTWARE\WOW6432Node\Classes\AppID',
    'HKCU:\SOFTWARE\Classes\AppID'
)

$results = foreach ($basePath in $registryPaths) {
    $keyPath = Join-Path $basePath "{$normalizedAppId}"

    if (Test-Path $keyPath) {
        $key = Get-ItemProperty -Path $keyPath -ErrorAction SilentlyContinue

        $clsids = Get-ChildItem -Path $basePath -ErrorAction SilentlyContinue |
            Where-Object {
                $_.Name -match '-Classes\\AppID\\\{[0-9A-Fa-f-]{36}\}$' -and
                $_.GetValue('AppID') -replace '[{}]', '' -eq $normalizedAppId
            } |
            ForEach-Object {
                Split-Path $_.Name -Leaf
            }

        [PSCustomObject]@{
            AppID             = "{$normalizedAppId}"
            Name              = $key.'(default)'
            DllSurrogate      = $key.DllSurrogate
            LocalService      = $key.LocalService
            LocalServer32     = $key.LocalServer32
            ServiceParameters = $key.ServiceParameters
            AssociatedCLSID   = ($clsids -join ', ')
            RegistryPath      = $keyPath
        }
    }
}

if ($results) {
    $results | Format-List
}
else {
    Write-Warning "No DCOM registration was found for AppID {$normalizedAppId}."
}
<#
Detect:
 - Any USB Fax Modem (PnP class "Modem" whose PNPDeviceID begins with "USB\")
 - Agere/Lucent softmodem drivers agrsm.sys / agrsm64.sys (file presence, loaded driver, or PnP signed driver)

Exit codes:
 - 1 => Found (USB modem and/or agrsm driver)
 - 0 => None found

Optional "strict mode" (commented at bottom) to require the USB modem to be using agrsm*.sys.
#>

$found = $false
$usbModems = @()
$agrDriversFound = @()

# --- Helper: Safe CIM/WMI query ---
function Invoke-DeviceQuery {
    param(
        [Parameter(Mandatory)] [string] $ClassName,
        [string] $Filter
    )
    try {
        if ($PSVersionTable.PSEdition -eq 'Desktop' -or $PSVersionTable.PSVersion.Major -lt 6) {
            # Windows PowerShell (fallback-friendly)
            if ($Filter) { Get-WmiObject -Class $ClassName -Filter $Filter -ErrorAction Stop }
            else { Get-WmiObject -Class $ClassName -ErrorAction Stop }
        } else {
            # PowerShell Core (CIM)
            if ($Filter) { Get-CimInstance -ClassName $ClassName -Filter $Filter -ErrorAction Stop }
            else { Get-CimInstance -ClassName $ClassName -ErrorAction Stop }
        }
    }
    catch {
        @()
    }
}

# --- 1) Detect USB Fax Modems ---
# Strategy: Win32_PnPEntity with PNPClass 'Modem' and PNPDeviceID like 'USB\%'
try {
    $usbModems = Invoke-DeviceQuery -ClassName Win32_PnPEntity | Where-Object {
        ($_.PNPClass -eq 'Modem' -or $_.ClassGuid -eq '{4D36E96D-E325-11CE-BFC1-08002BE10318}') -and
        ($_.PNPDeviceID -like 'USB\%')
    } | Select-Object Name, Manufacturer, PNPDeviceID, ClassGuid, Status
}
catch { }

if ($usbModems.Count -gt 0) {
    $found = $true
}

# --- 2) Detect agrsm*.sys (Agere/Lucent softmodem) drivers ---
# a) Files present in System32\drivers
$driverDir = Join-Path $env:SystemRoot 'System32\drivers'
$driverFiles = @('agrsm.sys','agrsm64.sys') | ForEach-Object {
    $p = Join-Path $driverDir $_
    if (Test-Path -LiteralPath $p -PathType Leaf) { Get-Item -LiteralPath $p }
}
if ($driverFiles) {
    $agrDriversFound += $driverFiles
    $found = $true
}

# b) Loaded system drivers referencing those filenames
try {
    $loadedDrivers = Invoke-DeviceQuery -ClassName Win32_SystemDriver | Where-Object {
        $_.PathName -match '(?i)agrsm64\.sys' -or $_.PathName -match '(?i)agrsm\.sys'
    }
    if ($loadedDrivers) {
        $agrDriversFound += $loadedDrivers
        $found = $true
    }
}
catch { }

# c) PnP Signed Drivers referring to Agere/agrsm (additional signal)
try {
    $pnpSigned = Invoke-DeviceQuery -ClassName Win32_PnPSignedDriver | Where-Object {
        ($_.DriverName -match '(?i)agere|lucent|soft.?modem') -or
        ($_.InfName -match '(?i)agrsm') -or
        ($_.DriverProviderName -match '(?i)agere|lucent') -or
        ($_.DriverVersion -and $_.DriverVersion -match '(?i)agrsm')
    }
    if ($pnpSigned) {
        # Note: This is heuristic; include for visibility but not necessarily required
        $agrDriversFound += $pnpSigned
        $found = $true
    }
}
catch { }

# --- Optional: Strict mode (require USB modem USING agrsm*.sys) ---
# Uncomment this section to ONLY return 1 when a USB modem is present AND it uses agrsm*.sys.
# This correlates each USB modem to its signed driver package.
# try {
#     $usbModemDrivers = Invoke-DeviceQuery -ClassName Win32_PnPSignedDriver | Where-Object {
#         $_.DeviceClass -eq 'Modem' -and $_.HardwareID -match 'USB\\'
#     }
#     $matches = $usbModemDrivers | Where-Object {
#         ($_.DriverName -match '(?i)agere|lucent|soft.?modem') -or
#         ($_.InfName -match '(?i)agrsm') -or
#         ($_.DriverProviderName -match '(?i)agere|lucent')
#     }
#     if ($matches) {
#         $found = $true
#     } else {
#         $found = $false
#     }
# }
# catch { }

# --- Diagnostic output (to StdOut) ---
Write-Host "=== USB Fax Modems (PnP class 'Modem' via USB) ==="
if ($usbModems) {
    $usbModems | Format-Table Name, Manufacturer, Status, PNPDeviceID -AutoSize
} else {
    Write-Host "(none)"
}

Write-Host "`n=== agrsm*.sys Indicators ==="
if ($driverFiles) {
    Write-Host "Driver files present:"
    $driverFiles | ForEach-Object { Write-Host " - $($_.FullName)" }
} else {
    Write-Host "Driver files: (none)"
}

if ($loadedDrivers) {
    Write-Host "Loaded system drivers referencing agrsm*.sys:"
    $loadedDrivers | Select-Object Name, State, PathName | Format-Table -AutoSize
} else {
    Write-Host "Loaded drivers: (none)"
}

if ($pnpSigned) {
    Write-Host "PnP signed driver hints (Agere/Lucent/agrsm):"
    $pnpSigned | Select-Object DeviceName, DriverName, DriverProviderName, InfName | Format-Table -AutoSize
} else {
    Write-Host "PnP signed driver hints: (none)"
}

# --- Exit code as requested ---
if ($found) { exit 1 } else { exit 0 }
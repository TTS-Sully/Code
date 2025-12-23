
<# 
Monitor Liongard Agent service and installation status
Rewritten to use Get-Service and registry checks instead of Win32_Product.

Exit codes:
  0 = Service running
  1 = Installed but service NOT running
  2 = Not installed
  3 = Error/unknown
#>

[CmdletBinding()]
param(
    # Provide either the Service Name (e.g., 'LiongardAgent') or the Display Name (e.g., 'Liongard Agent')
    [string]$ServiceName,
    [string]$DisplayName = 'Liongard Agent',   # default matches your original intent
    [string]$ProductNamePattern = 'Liongard Agent' # used to detect install via registry
)

function Write-Result {
    param(
        [string]$Status
    )
    Write-Host '<-Start Result->'
    Write-Host ("STATUS={0}" -f $Status)
    Write-Host '<-End Result->'
}

function Get-ServiceSafe {
    param(
        [string]$ServiceName,
        [string]$DisplayName
    )
    # Try by service name first (if provided), then by display name
    try {
        if ($ServiceName) {
            Write-Verbose "Trying Get-Service by ServiceName '$ServiceName'."
            $svc = Get-Service -Name $ServiceName -ErrorAction Stop
            return $svc
        }
    } catch {
        Write-Verbose "Service not found by name '$ServiceName': $($_.Exception.Message)"
    }

    try {
        if ($DisplayName) {
            Write-Verbose "Trying Get-Service by DisplayName '$DisplayName'."
            # Get-Service does not support -DisplayName filter directly; fetch all and filter
            $svc = Get-Service | Where-Object { $_.DisplayName -eq $DisplayName }
            if ($svc) { return $svc }
        }
    } catch {
        Write-Verbose "Service lookup by DisplayName failed: $($_.Exception.Message)"
    }

    return $null
}

function Test-ProductInstalledViaRegistry {
    param(
        [string]$NamePattern
    )
    # Checks common uninstall locations for both 64-bit and 32-bit views
    $paths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )

    foreach ($path in $paths) {
        try {
            Write-Verbose "Scanning $path for product name like '$NamePattern'."
            $items = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
            foreach ($item in $items) {
                $name = $item.DisplayName
                if ([string]::IsNullOrWhiteSpace($name)) { continue }
                if ($name -like "*$NamePattern*") {
                    Write-Verbose "Found installed product: $name (Publisher: $($item.Publisher))"
                    return $true
                }
            }
        } catch {
            Write-Verbose "Failed reading $path $($_.Exception.Message)"
        }
    }
    return $false
}

# --- Main logic ---
try {
    $service = Get-ServiceSafe -ServiceName $ServiceName -DisplayName $DisplayName

    if ($null -ne $service) {
        if ($service.Status -eq 'Running') {
            Write-Result -Status 'Liongard Service Running'
            exit 0
        } else {
            # Service exists but not running; confirm installation
            $installed = Test-ProductInstalledViaRegistry -NamePattern $ProductNamePattern
            if ($installed) {
                Write-Result -Status 'Liongard is Installed but the service is NOT running'
                exit 1
            } else {
                # Rare case: service object exists but uninstall keys not present
                Write-Result -Status 'Liongard service detected but product install not confirmed (check deployment)'
                exit 3
            }
        }
    } else {
        # Service not found; check install status
        $installed = Test-ProductInstalledViaRegistry -NamePattern $ProductNamePattern
        if ($installed) {
            Write-Result -Status 'Liongard is Installed but the service is NOT present or not detected'
            exit 1
        } else {
            Write-Result -Status 'Liongard Agent is NOT Installed'
            exit 2
        }
    }
}
catch {
    Write-Result -Status ("Unexpected error: {0}" -f $_.Exception.Message)
    exit 3
}

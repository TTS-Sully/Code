
# Sets IPV4 as the default
Get-NetIPInterface -AddressFamily IPv4 |
    Where-Object {
        (Get-NetAdapter -InterfaceIndex $_.InterfaceIndex).NdisPhysicalMedium -ne "WirelessLan"
    } |
    Set-NetIPInterface -InterfaceMetric 10
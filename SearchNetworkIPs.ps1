
# Define the IP address
$ipSTART = "192.168.1.1"
$ipEND = "192.168.1.255"

# Split the IP address into an array
$ipArrayStart = $ipSTART -split "\."
$ipArrayEnd = $ipEND -split "\."

# Display the array
$ipArrayStart
$ipArrayEnd

# Nested loops to iterate through the IP range
for ($i = [int]$ipArrayStart[0]; $i -le [int]$ipArrayEnd[0]; $i++) {
        for ($j = [int]$ipArrayStart[1]; $j -le [int]$ipArrayEnd[1]; $j++) {
            for ($k = [int]$ipArrayStart[2]; $k -le [int]$ipArrayEnd[2]; $k++) {
                for ($l = $startLastOctet; $l -le $endLastOctet; $l++) {
                    $currentIP = "$i.$j.$k.$l"
                    Write-Host "Pinging IP: $currentIP"
                    $ping = Test-Connection -ComputerName $currentIP -Count 1 -Quiet
                    if ($ping) {
                        Write-Host "$currentIP is reachable"
                    } else {
                        Write-Host "$currentIP is not reachable"
                    }
                }
            }
        }
    
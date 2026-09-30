# --- CONFIGURATION VARIABLES ---
$DriverPath = "C:\Drivers\HP_Universal\hpcu196u.inf" # Path to your driver .inf file
$DriverName = "HP Universal Printing PCL 6"        # EXACT name from the .inf file
$PortName   = "IP_192.168.1.50"                    # Name for the TCP Port
$PrinterIP  = "192.168.1.50"                       # The printer's IP address
$PrinterName= "Office-HP-LaserJet"                 # Desired display name

# Step 1: Stage the driver files into the Windows Driver Store
# This allows Windows to trust and recognize the raw driver files.
pnputil.exe /add-driver $DriverPath /install

# Step 2: Register the driver with the Print Management subsystem
Add-PrinterDriver -Name $DriverName

# Step 3: Create the Standard TCP/IP Printer Port
Add-PrinterPort -Name $PortName -PrinterHostAddress $PrinterIP

# Step 4: Install and map the Printer using the port and driver
Add-Printer -Name $PrinterName -DriverName $DriverName -PortName $PortName
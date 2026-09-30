##########################################################################################################################
### Tech Team Solutions - Rebuild Microsoft Print to PDF Printer
### Last Updated 2025.09.04
### Written by ESS
##########################################################################################################################

Disable-WindowsOptionalFeature -online -FeatureName Printing-PrintToPDFServices-Features -NoRestart

Stop-Service spooler
Remove-Item -Path "C:\Windows\System32\spool\PRINTERS\*" -Recurse -Force
Start-Service spooler

Enable-WindowsOptionalFeature -online -FeatureName Printing-PrintToPDFServices-Features -NoRestart

$test = Get-Printer | Where-Object Name -eq "Microsoft Print to PDF"
if ($test) {
    Write-Output "Printer 'Microsoft Print to PDF' already exists. Exiting script."
} else {
    Write-Output "Printer 'Microsoft Print to PDF' does not exist. Proceeding to add it."
    Add-Printer -Name "Microsoft Print to PDF" -DriverName "Microsoft Print To PDF" -PortName "PORTPROMPT:"
    Write-Output "Printer 'Microsoft Print to PDF' has been added."
}

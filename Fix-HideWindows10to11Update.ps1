if (Test-Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\UX') {
if (Test-Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\UX\Settings') {

Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\UX\Settings' -Name "TrayIconVisibility" -Value 0

} else {
    New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\UX' -Name 'Settings'
    Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\UX\Settings' -Name "TrayIconVisibility" -Value 0
}

} else {
    New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'UX'
    New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\UX' -Name 'Settings'
    Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\UX\Settings' -Name "TrayIconVisibility" -Value 0

}
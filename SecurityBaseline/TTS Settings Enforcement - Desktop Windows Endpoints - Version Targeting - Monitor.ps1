Write-Host 'Setting Version Targeting for all Desktop Endpoints'
$exitcode = 2
$totalerrors = 0;
Try {
  #Windows Version Targeting
  $testkey = Get-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate
  if($testkey -ne $null){
    if ($testkey.ProductVersion -ne "Windows 11"){
      Write-Host "Product Version Not Set"
      $totalerrors = $totalerrors + 1
    }
    if ($testkey.TargetReleaseVersion -ne "1"){
      Write-Host "Target Release Not Set"
      $totalerrors = $totalerrors + 1 
    }
    if ($testkey.TargetReleaseVersionInfo -ne "23H2"){
      Write-Host "Version Info Not Set"
      $totalerrors = $totalerrors + 1 
    }
    if($totalerrors -gt 0){
      WRite-Host "Trigger Policy Enforcement"
      exit 1
    } else {
      Write-Host "No Enforcement Needed"
      exit 0
    }
  } else {
    Write-Host "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate Does not Exist"
    exit 1
  }
} Catch {
  Write-Host "Unknown Error Occured"
  exit 2
}
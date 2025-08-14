try {  
   $tmaMsiPath = "{0}\MicrosoftTeamsMeetingAddinInstaller.msi" -f (get-appxpackage -name MSTeams).InstallLocation  
   $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/x `"$tmaMsiPath`" InstallerVersion=v3 /quiet /l `"$env:USERPROFILE\Downloads\tma-uninstall.log`"" -PassThru -Wait -ErrorAction Stop

if ($process.ExitCode -ne 0) {  
      throw "msiexec.exe exited with code $($process.ExitCode)"  
   }  
   else  
   {  
      Write-Host "Successfully uninstalled teams meeting addin." -ForegroundColor Green  
   }  
}  
catch {  
   Write-Error "Failed to uninstall: $_. We'll try repairing MSI"   
   $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/fav `"$tmaMsiPath`" /quiet /l `"$env:USERPROFILE\Downloads\tma-uninstall-repair.log`"" -PassThru -Wait -ErrorAction Stop

if ($process.ExitCode -ne 0) {    
      Write-Error "Repair failed with code $($process.ExitCode)"  
   }  
   else  
   {  
      Write-Output "Repair succeeded! We'll try to uninstall again"          
      $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/x `"$tmaMsiPath`" /quiet InstallerVersion=v3 /l `"$env:USERPROFILE\Downloads\tma-uninstall-retry.log`"" -PassThru -Wait -ErrorAction Stop

if ($process.ExitCode -eq 0) {  
         Write-Host "Successfully uninstalled teams meeting addin." -ForegroundColor Green  
      }
      else  
      {  
         Write-Error "Could not uninstall teams meeting addin"  
      }  
   } 
}
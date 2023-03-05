if (Get-AppxPackage -Name MicrosoftCorporationII.WindowsSubsystemForLinux) {
  Write-Host "---"
  Write-Host "Installing NixOS-WSL"
  Write-Host "---"
  Invoke-WebRequest -Uri "https://github.com/nix-community/NixOS-WSL/releases/download/22.05-5c211b47/nixos-wsl-x86_64-linux.tar.gz" -OutFile "nixos-wsl-installer.tar.gz"
  wsl.exe --import NixOS-nixified-ai $HOME\.NixOS-nixified-ai nixos-wsl-installer.tar.gz --version 2
  rm nixos-wsl-installer.tar.gz
  sleep 5
}

if (!(Get-AppxPackage -Name MicrosoftCorporationII.WindowsSubsystemForLinux)) {
    try {
        Write-Warning "---"
        Write-Warning "Windows tells us that WSL is not enabled, trying wsl.exe --install --no-distribution"
        Write-Warning "This will work on a fresh Windows machine, otherwise it's up to you to install the WSL"
        Write-Warning "---"
        wsl.exe --install --no-distribution | Out-Null
        if(!$?) {
            $error=1
        }
        else {
          Write-Warning "Successfully installed the WSL, you now need to reboot and run this script again!"
          sleep 5
          exit
        };
    }
    catch {
        Write-Warning 'Unable to install the WSL (Microsoft-Windows-Subsystem-Linux) feature via wsl.exe --install --no-distribution'
        Write-Warning 'Try to install WSL manually, such as via the Windows Store, or by following'
        Write-Warning 'https://learn.microsoft.com/en-us/windows/wsl/install'
        sleep 5
        exit
    }
}

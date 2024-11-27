# Remote Desktop "Server"
$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
Set-ItemProperty -Path $RegistryPath -Name "fEnableVirtualizedGraphics" -Value 1 -Type DWord
Set-ItemProperty -Path $RegistryPath -Name "fDisablePNPRedir" -Value 0 -Type DWord
GPUpdate /force
Start-Sleep -s 10
Restart-Computer -Force
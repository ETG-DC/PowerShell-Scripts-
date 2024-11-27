
# Ask for elevated permissions if required
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
	Exit
}

# Determine the DeviceID of a drive
Get-PhysicalDisk | Select -Prop DeviceId,FriendlyName,SerialNumber
Write-Host "The DeviceId corresponds to the N in the \Device\HardDiskN path." -ForegroundColor Yellow
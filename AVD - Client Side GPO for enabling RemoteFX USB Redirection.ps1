<# Ask for elevated permissions if required
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
	Exit
} #>

# Remote Desktop "Client"
$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client"
Set-ItemProperty -Path $RegistryPath -Name "fUsbRedirectionEnableMode" -Value 2 -Type DWord # Sets the GPO for Computer Configuration\Administrative Templates\Windows Components\Remote Desktop Services\Remote Desktop Connection Client\RemoteFX USB Redirection\Allow RDP redirection of other supported RemoteFX USB devices and sets the access rights to Administrators and Users
gpupdate /force 
start-sleep -s 10

<# Prompt the user to restart the computer
$restartResponse = Read-Host "Do you want to restart the computer now? (yes/no)"

if ($restartResponse -eq "yes") {
    Restart-Computer -Force
} else {
    Write-Host "The computer will not be restarted."
}#>

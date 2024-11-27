

# Ask for elevated permissions if required
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
	Exit
}

# Change the DNS to Google DNS
Set-DNSClientServerAddress -InterfaceAlias Ethernet -serveraddress "8.8.8.8"

ipconfig /release
ipconfig /renew
ipconfig /flushdns



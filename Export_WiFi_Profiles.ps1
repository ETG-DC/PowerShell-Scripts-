
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
	Exit
}

$tempWifiDir = "c:\wifi"
$wifiTestPath = test-path -path $tempWifiDir -PathType Container

if (!($wifiTestPath))
    { 
        New-Item -Path $tempWifiDir  -ItemType directory 
    }

netsh wlan export profile interface=* key=clear folder=c:\wifi
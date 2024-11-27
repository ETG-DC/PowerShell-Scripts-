# Specify the registry key path
$RegistryKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

# Specify the name of the registry value you want to set
$RegistryValueName = "DontDisplayUserName"
$RegistryValueName2 = "dontdisplaylastusername"

# Specify the value data for disabling the setting (usually 0 for disabled)
$RegistryValueData = 0

# Create the registry key if it doesn't exist
if (!(Test-Path $RegistryKeyPath)) {
    New-Item -Path $RegistryKeyPath -Force
}

# Set the registry value
Set-ItemProperty -Path $RegistryKeyPath -Name $RegistryValueName -Value $RegistryValueData -Type DWORD
Set-ItemProperty -Path $RegistryKeyPath -Name $RegistryValueName2 -Value $RegistryValueData -Type DWORD

# Create user account
net user "username" /add
wmic useraccount set passwordexpires=false
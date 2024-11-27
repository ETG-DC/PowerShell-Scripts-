# Define the registry path for Folder Options
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Streams"

# Define the registry value for the default view (Details view)
$defaultValue = 5

# Set the default view for all folders to Details
Set-ItemProperty -Path $registryPath -Name "DefaultView" -Value $defaultValue

# Define the registry path for the saved view settings
$saveViewRegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Modules\GlobalSettings\Sizer"

# Set the saved view settings for all folders to Details
Set-ItemProperty -Path $saveViewRegistryPath -Name "FFlags" -Value 0x28

# Display a message indicating success
Write-Host "Default folder view is set to 'Details'."

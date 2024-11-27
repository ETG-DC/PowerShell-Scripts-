# Define the name of the Dell Digital Delivery Windows Store app
$DellDigitalDeliveryAppxName = "*DellDigitalDelivery*"

# Check if the Dell Digital Delivery Windows Store app is installed
$DellDigitalDeliveryAppx = Get-AppxPackage -Name $DellDigitalDeliveryAppxName -AllUsers

# Define the name of the Dell Digital Delivery Win32 application
$DellDigitalDeliveryWin32Name = "Dell Digital Delivery"

# Check if the Dell Digital Delivery Win32 application is installed
$DellDigitalDeliveryWin32 = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq $DellDigitalDeliveryWin32Name } -WarningAction SilentlyContinue

# Uninstall the Dell Digital Delivery Windows Store app if found
if ($DellDigitalDeliveryAppx) {
    Write-Output "Uninstalling $($DellDigitalDeliveryAppx.Name) Windows Store app..."
   # Get-AppxPackage $DellDigitalDeliveryAppx.PackageFullName -AllUsers | Remove-AppxPackage  ### Doesn't work
    Get-AppxPackage -Name $DellDigitalDeliveryAppxName -AllUsers | Remove-AppPackage
    Write-Output "Dell Digital Delivery Windows Store app has been uninstalled."
} else {
    Write-Output "Dell Digital Delivery Windows Store app is not installed."
}

# Uninstall the Dell Digital Delivery Win32 application if found
if ($DellDigitalDeliveryWin32) {
    Write-Output "Uninstalling $($DellDigitalDeliveryWin32.Name) Win32 application..."
    $DellDigitalDeliveryWin32.Uninstall()
    Write-Output "Dell Digital Delivery Win32 application has been uninstalled."
} else {
    Write-Output "Dell Digital Delivery Win32 application is not installed."
}

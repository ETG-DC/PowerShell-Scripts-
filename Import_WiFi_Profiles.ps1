# Check for administrative privileges and elevate if necessary
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Elevating to Administrator permissions..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# Define the directory path for Wi-Fi profiles
$tempWifiDir = "C:\wifi"

# Check if the directory exists
if (Test-Path -Path $tempWifiDir -PathType Container) {
    Write-Host "Wi-Fi directory found. Processing profiles..." -ForegroundColor Green

    # Change to the Wi-Fi directory
    Set-Location -Path $tempWifiDir

    # Get the list of Wi-Fi profile files in the directory
    $WiFiProfileList = Get-ChildItem -Path $tempWifiDir -Filter "*.xml"

    # Loop through each file and add the profile
    foreach ($profile in $WiFiProfileList) {
        Write-Host "Adding Wi-Fi profile: $($profile.Name)" -ForegroundColor Yellow
        netsh wlan add profile filename="$($profile.FullName)" user=all
    }

    Write-Host "All Wi-Fi profiles have been processed." -ForegroundColor Green
} else {
    Write-Host "Wi-Fi directory not found at $tempWifiDir. Exiting script." -ForegroundColor Red
}
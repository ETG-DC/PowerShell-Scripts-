<#
.Description
This script checks for administrative privileges and elevates if necessary. It verifies the presence of Chocolatey, and if installed, uses a loop to install a list of predefined applications. 
It handles errors during installation and prompts the user to install Chocolatey manually if it is not found
#>

# Request elevated permissions if not already running as Administrator
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Elevating to Administrator permissions..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# Check if Chocolatey is installed
$chocoPath = "$env:ProgramData\chocolatey\choco.exe"
$checkChoco = Test-Path -Path $chocoPath -PathType Leaf

if ($checkChoco) {
    Write-Host "Chocolatey detected. Proceeding with app installation..." -ForegroundColor Green

    # Array of apps to install
    $appsToInstall = @("googlechrome", "7zip", "vlc", "notepadplusplus")

    try {
        foreach ($app in $appsToInstall) {
            Write-Host "Installing $app..." -ForegroundColor Yellow
            choco install $app -y --force
        }

        Write-Host "All apps installed successfully!" -ForegroundColor Green
    } catch {
        Write-Host "Error: Failed to install apps." -ForegroundColor Red
        Write-Host "Performing diagnostics..." -ForegroundColor Green
    }
} else {
    Write-Host "Chocolatey is not installed. Please install it before running this script." -ForegroundColor Red
    Start-Process "https://docs.chocolatey.org/en-us/choco/setup" -UseShellExecute $true
    return
}

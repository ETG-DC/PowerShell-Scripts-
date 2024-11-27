# List of Office apps to check
$officeApps = @("WINWORD", "EXCEL", "POWERPNT", "OUTLOOK", "ONENOTE", "MSACCESS", "VISIO", "LYNC")

# Check for running Office processes and terminate them
foreach ($app in $officeApps) {
    $process = Get-Process -Name $app -ErrorAction SilentlyContinue
    if ($process) {
        Write-Host "Closing $app..."
        Stop-Process -Name $app -Force
    }
}

# Change directory to the ClickToRun folder
Set-Location "C:\Program Files\Common Files\Microsoft Shared\ClickToRun"

# Run the Office update command using the call operator &
& .\OfficeC2RClient.exe /update user
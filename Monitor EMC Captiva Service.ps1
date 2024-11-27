Import-Module $env:SyncroModule

$service = "EMC.Captiva.WebCaptureService"

# Query the service startup mode
$queryServiceStartupMode = Get-WmiObject -Class Win32_Service -Filter "Name='$service'" | Select-Object Name, StartMode
$startMode = $queryServiceStartupMode.StartMode

# Confirm the service is disabled
if ($startMode -eq 'Disabled') {
    Write-Host "$service is already disabled. Stopping the script..."
    Exit
} else {
    Write-Host "The startup mode value is set to $startMode...attempting to disable it."

    # Set the service startup type to Disabled
    $disableService = Get-WmiObject -Class Win32_Service -Filter "Name='$service'"
    $disableService.ChangeStartMode("Disabled")
    
    Write-Host "$service has been disabled."

    # Check if the service is running and stop it if it is
    $serviceStatus = Get-Service -Name $service
    if ($serviceStatus.Status -eq 'Running') {
        Stop-Service -Name $service -Force
        Write-Host "$service was running and has been stopped."
    }
}
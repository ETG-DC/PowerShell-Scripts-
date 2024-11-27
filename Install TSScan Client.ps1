<#
.Description
Install TSScan Client using the .exe installer (ran into issues with TSScan after deployment using msi file for version 3.5.4.5)
#>

# Define variables
$InstallerPath = "C:\temp\TSScan_Client.exe"  # Path to the TSScan installer
$LogPath = "C:\temp\TSScanInstallation.log"            # Path to the installation log file
$Timeout = 300                                         # Timeout in seconds


# Verify the installer file exists
if (!(Test-Path $InstallerPath)) {
    Write-Error "TSScan installer not found at path: $InstallerPath"
    Exit 1
}

# Log start of installation
Write-Output "Starting TSScan installation at $(Get-Date)" | Out-File $LogPath -Append

# Silent installation command
$Arguments = "/SILENT /SUPPRESSMSGBOXES /NORESTART"

try {
    # Start the installer process
    Write-Output "Launching installer: $InstallerPath" | Out-File $LogPath -Append
    $Process = Start-Process -FilePath $InstallerPath -ArgumentList $Arguments -PassThru -Wait -NoNewWindow -ErrorAction Stop

    # Wait for process to complete
    $Process.WaitForExit($Timeout)

    # Check exit code
    if ($Process.ExitCode -eq 0) {
        Write-Output "TSScan installed successfully at $(Get-Date)" | Out-File $LogPath -Append
        Write-Output "Installation completed successfully."
    } else {
        Write-Error "TSScan installation failed with exit code $($Process.ExitCode)."
        Write-Output "TSScan installation failed with exit code $($Process.ExitCode) at $(Get-Date)" | Out-File $LogPath -Append
    }
} catch {
    Write-Error "An error occurred during the TSScan installation: $_"
    Write-Output "Error during installation: $_ at $(Get-Date)" | Out-File $LogPath -Append
}

# Log end of installation
Write-Output "TSScan installation process ended at $(Get-Date)" | Out-File $LogPath -Append

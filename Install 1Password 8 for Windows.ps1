# Define paths
$path = "C:\temp"
$exePath = "$env:LocalAppData\1Password\app\8\1Password.exe"
$appPath = "C:\Program Files\1Password\apps\8"
$backupWildcard = "C:\Program Files\1Password\apps\8.bak*"

# Ensure the temp directory exists
if (!(Test-Path $path)) {
    New-Item -ItemType Directory -Force -Path $path | Out-Null
}

# Remove all backup directories matching the wildcard
$backupPaths = Get-ChildItem -Path $backupWildcard -ErrorAction SilentlyContinue
foreach ($backup in $backupPaths) {
    try {
        Remove-Item -Path $backup.FullName -Recurse -Force
        Write-Host "Removed $($backup.FullName)"
    } catch {
        Write-Host "Failed to remove $($backup.FullName): $_"
    }
}

# Check if 1Password executable exists
if (Test-Path $exePath) {
    try {
        # Attempt to uninstall 1Password
        Start-Process -FilePath $exePath -ArgumentList "--uninstall" -Wait
        Write-Host "1Password uninstallation initiated."

        # Check if it's uninstalled
        if (-not (Test-Path $exePath)) {
            Write-Host "1Password successfully uninstalled."
        } else {
            Write-Host "1Password still present after uninstall attempt."
        }
    } catch {
        Write-Host "Error attempting to uninstall 1Password: $_"
    }
} else {
    Write-Host "1Password not found at the specified path."
}

# Process actions
switch -Wildcard ($appPath) {
    { Test-Path $appPath } {
        try {
            $processes = Get-Process -Name "*1password*" -ErrorAction SilentlyContinue
            if ($processes) {
                Stop-Process -Name $processes.ProcessName -Force -ErrorAction SilentlyContinue
            }
            Start-Process -FilePath "msiexec.exe" -ArgumentList '/qn /norestart /x c:\temp\1PasswordSetup-latest.msi' -Wait
            Start-Sleep -Seconds 10
            Rename-Item -Path $appPath -NewName "8.bak" -Force
            Write-Host "Renamed $appPath to 8.bak"
        } catch {
            Write-Host "Error handling process or renaming files: $_"
        }
    }
}

# Install the latest version of 1Password
try {
    Start-Process -FilePath "msiexec.exe" -ArgumentList '/qn /norestart /i c:\temp\1PasswordSetup-latest.msi' -Wait
    Write-Host "1Password Setup completed successfully."
} catch {
    Write-Host "Failed to start 1Password Setup: $_"
}


# Install 1Password Extension for Edge
reg add "HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Edge\Extensions\dppgmdbiimibapkepcbdbmkaabgiofem" /v "update_url" /t REG_SZ /d "https://edge.microsoft.com/extensionwebstorebase/v1/crx" /f

# Install 1Password Extenstion for Chrome
reg add "HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist" /v 1 /t REG_SZ /d "aeblfdkhhhdcdjpifhhbdiojplfjncoa" /f

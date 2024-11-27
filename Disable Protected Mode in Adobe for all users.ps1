$regPath = "HKLM:\SOFTWARE\WOW6432Node\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown"
$valueName = "bProtectedMode"

# Ensure the registry path exists
if (!(Test-Path -Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Set the value to disable Protected Mode
Set-ItemProperty -Path $regPath -Name $valueName -Value 0 -Force

# Confirm the change
if ((Get-ItemProperty -Path $regPath -Name $valueName).$valueName -eq 0) {
    Write-Output "Protected Mode has been disabled successfully for all users."
} else {
    Write-Error "Failed to disable Protected Mode for all users."
}
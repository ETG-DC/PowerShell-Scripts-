Import-Module $env:SyncroModule

# Define the folder path
$folderPath = "$env:ProgramData\bdlogging"

# Get the total size of the folder in bytes
$folderSizeBytes = (Get-ChildItem -Recurse -File -Path $folderPath | Measure-Object -Property Length -Sum).Sum

# Convert the size to gigabytes
$folderSizeGB = [math]::Round($folderSizeBytes / 1GB, 2)

# Output the folder size in GB
Write-Output "The size of $folderPath is $folderSizeGB GB"

# Check if the folder size exceeds 10GB
if ($folderSizeGB -gt 10) {
    Rmm-Alert -Category 'Bitdefender Logs' -Body "The bdlogging folder in %programdata% is currently $($folderSizeGB) GB. Attempting to delete the folder..."
    Write-Output "The folder size exceeds 10 GB. Deleting the folder..."
    Remove-Item -Path $folderPath -Recurse -Force
    Write-Output "Folder deleted successfully."
} else {
    Write-Output "The folder size does not exceed 10 GB. No action taken."
}


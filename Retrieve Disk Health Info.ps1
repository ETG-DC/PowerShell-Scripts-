if (!(Test-Path -path c:\temp -PathType Container)){
    New-Item -Path c:\temp -ItemType directory
}

#Output disk health info to a txt file
Get-Disk -number 0 | Get-StorageReliabilityCounter | Format-List | Out-File "c:\temp\diskhealth.txt"


# Get disk health info
$diskHealth = Get-Disk -number 0 | Get-StorageReliabilityCounter

# Check the ReadErrorsTotal value
if ($diskhealth.ReadErrorsTotal -gt 1){
    Rmm-Alert -Category 'Disk Health' -Body 'Possible disk issues. Read errors found. Review the DiskHealth.txt file in C:\temp and run drive diagnostics'
    Write-Host "Possible disk failure. Read errors found. Review the DiskHealth.txt file in C:\temp and run drive diagnostics"
    Upload-File -FilePath "C:\temp\DiskHealth.txt"
    }
else{
    Write-Host "No issues found on $asset_name. The full disk health report can be found in c:\temp"
}
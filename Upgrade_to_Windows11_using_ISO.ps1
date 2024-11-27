<# 
.Description
This script upgrades a Windows 10 device to Windows 11 23H2 using an ISO file stored in an Azure Storage blob container. 
The Az.Storage PowerShell module is required for accessing the storage account. The script attempts to install the module but continues execution even if Get-Module -Name Az.Storage incorrectly reports the module as not installed.

Once the module is confirmed installed, the script connects to the Azure blob storage using New-AzStorageContext and authenticates with the $storageAccountName and $storageAccountKey. 
The Windows 11 ISO is downloaded to C:\temp\Windows11Upgrade via the Get-AzStorageBlobContent cmdlet. After the download, the ISO is mounted, and the script determines the drive letter, assigning it to the $mountedPath variable.

Finally, setup.exe is executed with the arguments /auto upgrade /eula accept /quiet /showoobe none. The script waits for the upgrade process to finish, then dismounts the ISO. The computer restarts automatically to complete the upgrade.
#>

# Install the required modules
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name Az.Storage -Force -AllowClobber
Import-Module Az.Storage

# This check seems to break things so I moved the installation of the modules to outside this check for now 
$AzStorageModuleCheck = Get-Module -Name Az.Storage
if (!($AzStorageModuleCheck)) {
     Write-Host "$AzStorageModuleCheck"
    <# Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module -Name Az.Storage -Force -AllowClobber
    Import-Module Az.Storage #>
} else {
    Write-Host "$AzStorageModuleCheck"
} 

# Set Azure Blob storage credentials
$storageAccountName = "yourStorageAccountNameHere" 
$storageAccountKey = "yourStorageAccountKeyHere" 
$containerName = "yourContainerNameHere" 
$blobName = "Win11_23H2_English_x64v2.iso" # If version 24H2 is  being installed - update the name

# Set local paths
$downloadPath = "C:\temp\Windows11Upgrade"
$isoMountPath = "C:\temp\Windows11ISO"

# Create directories if they don't exist
if (!(Test-Path -Path $downloadPath -PathType Container)) {
    New-Item -Path $downloadPath -ItemType Directory | Out-Null
    Write-Host "Created $downloadPath"
}
if (!(Test-Path -Path $isoMountPath -PathType Container)) {
    New-Item -Path $isoMountPath -ItemType Directory | Out-Null
    Write-Host "Created $isoMountPath"
}

# Connect to Azure Blob storage
$context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

if (!(Test-Path -Path $downloadPath\$blobName -PathType Leaf)) {
    # Download Windows 11 ISO from Azure Blob storage
    Write-Host "Downloading the ISO...This might take awhile."
    $blob = Get-AzStorageBlobContent -Blob $blobName -Container $containerName -Context $context -Destination $downloadPath -Force
} else {
    Write-Host "The Windows 11 ISO already exists..continuing..."
}

# Mount the ISO
Write-Host "Mounting the ISO..."
$mountResult = Mount-DiskImage -ImagePath (Join-Path -Path $downloadPath -ChildPath $blob.Name) -StorageType ISO -PassThru 
$driveLetter = ($mountResult | Get-Volume).DriveLetter
$mountedPath = "$driveLetter`:\"

# Run setup.exe for upgrade
Write-Host "Attempting to run $($mountedpath)setup.exe"
$setupExePath = Join-Path -Path $mountedPath -ChildPath "setup.exe"
$arguments = "/auto upgrade /eula accept /quiet /showoobe none"

Start-Process -FilePath $setupExePath -ArgumentList $arguments -Wait


# Dismount the ISO
Get-DiskImage -ImagePath (Join-Path -Path $downloadPath -ChildPath $blob.Name) | Dismount-DiskImage




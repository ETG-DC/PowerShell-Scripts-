<#
.SYNOPSIS
    A more consistent and reliable method for removing AppxPackages

.DESCRIPTION
    The Remove-ProvisionedPackage function removes a provisioned Appx package from the system image. Provisioned packages are installed for new user profiles by default.
    The Remove-InstalledPackage function removes an installed Appx package for all users on the system. It targets packages that have already been installed in user profiles.

.NOTES
# To get all AppPackages, run
    Get-AppxPackage -AllUsers # This spits out ALL appxpackages installed - not ideal
# To find info on a specific app package:
    Get-AppxPackage -AllUsers | Where-Object { $_.PackageFullName -like "*Microsoft.Paint*" } # Yes, leave the * *

.EXAMPLE
    $AppPackageName = "Microsoft.Paint" # grab the name from the previous command and put it in the "". Remove the <>. Example name would be something like  "Microsoft.OutlookForWindows"  
    Remove-InstalledPackage -PackageName $AppPackageName # Just copy and paste both of these AFTER the $AppPackageName variable is stored in the PowerShell session 
    Remove-ProvisionedPackage -PackageName $AppPackageName
#>
function Remove-ProvisionedPackage {
    param (
        [string]$PackageName
    )
    $ProvisionedPackage = Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -match $PackageName}
    if ($ProvisionedPackage) {
        Write-Host "Removing provisioned package: $PackageName"
        $ProvisionedPackage | ForEach-Object {
            Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue
        }
    } else {
        Write-Host "Provisioned package $PackageName not found."
    }
}

# Function to remove an installed package for all users
function Remove-InstalledPackage {
    param (
        [string]$PackageName
    )
    $InstalledPackage = Get-AppxPackage -AllUsers | Where-Object {$_.Name -like "*$PackageName*"}
    if ($InstalledPackage) {
        Write-Host "Removing installed package: $PackageName"
        $InstalledPackage | ForEach-Object {
            Remove-AppxPackage -AllUsers -Package $_.PackageFullName -ErrorAction SilentlyContinue
        }
    } else {
        Write-Host "Installed package $PackageName not found."
    }
}


# How to use the functions
$AppPackageName = "<packagename>" # grab the name from the "Name" field output by the Get-AppxPackage* cmdlet and put it between the "". Remove the <>.
                                  # *example provided in the NOTES section at the top of the page
Remove-InstalledPackage -PackageName $AppPackageName
Remove-ProvisionedPackage -PackageName $AppPackageName
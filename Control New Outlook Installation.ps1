<#
.Description
    This PowerShell script manages the installation and usage of the new Outlook app 
    It checks for and removes the new Outlook app, along with its provisioned package, to prevent reinstallation. 
    The script also modifies the Windows registry to block updates and hide the "Try the New Outlook" toggle*s*ee notes in step 3**, preventing users from switching to the new version. 
    Additionally, it uninstalls the legacy Mail and Calendar apps to block the new Outlook's installation as part of the deprecation process.
#>

# Function to remove a provisioned package
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

# Check if the new Outlook app is installed and remove it if present
$OutlookPackageName = "Microsoft.OutlookForWindows"
Remove-InstalledPackage -PackageName $OutlookPackageName
Remove-ProvisionedPackage -PackageName $OutlookPackageName

#Remove the Windows orchestrator registry value to prevent reinstallation
$RegistryPath = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe"
$RegistryValue = "OutlookUpdate"
if (Test-Path $RegistryPath) {
    if (Get-ItemProperty -Path $RegistryPath -Name $RegistryValue -ErrorAction SilentlyContinue) {
        Write-Host "Removing registry value: $RegistryValue"
        Remove-ItemProperty -Path $RegistryPath -Name $RegistryValue -ErrorAction SilentlyContinue
    } else {
        Write-Host "Registry value $RegistryValue not found."
    }
} else {
    Write-Host "Registry path $RegistryPath not found."
}

<# Prevent users from switching to the new Outlook by hiding the toggle
 Step 3 was moved to a separate script since it needs to be ran as the logged in user
 alternatively, hiding new Outlook is available as a cloud policy in the Microsoft 365 Apps admin center. 
 To set up the policy:

        Sign in to the Microsoft 365 Apps admin center.
        Under Customization, select Policy Management.
        Select Create to create a new cloud policy.
        Search for the Hide the "Try the new Outlook" toggle in Outlook policy and enable it.
#>

# Uninstall the Mail and Calendar apps to block new Outlook installation as part of their deprecation
$MailAndCalendarPackageName = "microsoft.windowscommunicationsapps"
Remove-InstalledPackage -PackageName $MailAndCalendarPackageName
Remove-ProvisionedPackage -PackageName $MailAndCalendarPackageName

Write-Host "Script execution completed."

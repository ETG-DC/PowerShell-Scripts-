<#
.VERSION 1.1

.Description
This script gets the members of the local administrators group and if there are any AAD user accounts in the group, it attempts to remove them. 
It then checks to see if any AAD accounts still exist and if any are found, it sends an RMM alert.
#>
Import-Module $env:SyncroModule

if (!(Test-Path "C:\temp")) {
    New-Item -ItemType Directory -Force -Path "C:\temp"
}

# Get the local Administrators group
foreach ($group in Get-LocalGroup -Name Administrators) {
    $group = [ADSI]"WinNT://$env:COMPUTERNAME/$group"
    $group_members = @($group.Invoke('Members') | ForEach-Object { ([adsi]$_).path })
}

try {
    # Remove Azure AD users from the local administrators group
    foreach ($member in $group_members) {
        if ($member -like "*AzureAD/*") { # Has to be a / not a \
            Write-Host "Removing Azure AD user: $member"

            # Remove the Azure AD user from the local administrators group
            $userName = $member.Substring($member.LastIndexOf("/") + 1)
            $group.Remove("WinNT://AzureAD/$userName")
        }
    }

    # Check if any Azure AD accounts still exist
    $remainingAzureADMembers = @($group.Invoke('Members') | ForEach-Object { ([adsi]$_).path }) |
                               Where-Object { $_ -like "*AzureAD/*" }

    if ($remainingAzureADMembers.Count -gt 0) {
        Write-Output "Checking to see if any AAD accounts weren't removed:"
        Write-Output "The following Azure AD accounts still exist in the local administrators group:"
        $remainingAzureADMembers | ForEach-Object { Write-Output $_ }
    } else {
        Write-Output "Checking to see if any AAD accounts weren't removed:"
        Write-Output "No Azure AD accounts remain in the local administrators group."
    }
}
catch {
    Write-Host "An error occurred: $_"
}


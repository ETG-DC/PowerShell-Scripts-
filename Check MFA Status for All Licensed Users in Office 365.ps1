<# 
.Description
Run this script to get the MFA status of licensed users in O365

.Notes
    Required modules:
     AzureAD module needs to be installed: Install-Module -Name AzureAD   
     MSOL module needs to be installed: Install-Module -Name MSOnline

    Required connections in PowerShell:
        Connect-AzureAD
        Connect-MsolService  
    Yes, connect to both services in the same PowerShell session
#>

if (!(test-path $path)) {
	New-Item -ItemType Directory -Force -Path $path
}

# Get all licensed users
$licensedUsers = Get-MsolUser -All | Where-Object { $_.isLicensed -eq $true }

# Initialize an array to store the results
$results = @()

# Check MFA status for each licensed user mailbox
foreach ($user in $licensedUsers) {
    # Check the StrongAuthenticationMethods property
    $mfaStatus = if ($user.StrongAuthenticationMethods.Count -gt 0) { "Enabled" } else { "Not Enabled" }
    
    # Create a custom object to store the user's UPN and MFA status
    $results += [pscustomobject]@{
        UserPrincipalName = $user.UserPrincipalName
        MFAStatus         = $mfaStatus
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path "C:\Temp\MFA_Status_Report.csv" -NoTypeInformation

# Output a message indicating completion
Write-Output "MFA status report has been exported to C:\temp\MFA_Status_Report.csv"
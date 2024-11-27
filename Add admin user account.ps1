# Access the computer's ADSI interface
$adsi = [ADSI]"WinNT://$env:COMPUTERNAME"

# Define the PTS user
$PTS = "PTS"
$CheckPTS = $adsi.Children | Where-Object { $_.SchemaClassName -eq 'user' -and $_.Name -eq $PTS }

# If PTS user exists, delete it
if ($CheckPTS) {
    Write-Host "Deleting user $PTS."
    net user $PTS /delete
}

# Define the admin username and group
$Username = "admin"
$Group = "Administrators"

# Check if the admin user already exists
$ExistingUser = $adsi.Children | Where-Object { $_.SchemaClassName -eq 'user' -and $_.Name -eq $Username }

if ($null -eq $ExistingUser) {
    Write-Host "Creating new local user $Username."
    net user $Username $Password /add /y /expires:never

    Write-Host "Adding $Username to the $Group group."
    net localgroup $Group $Username /add

    # Requires specific RMM Module: Write-Host "Setting asset field for $Username."
    # Requires specific RMM Module: Set-Asset-Field -Subdomain $SubDomain -Name "LocalAdminAccount" -Value $Username
} else {
    Write-Host "User $Username already exists. Setting new password."
    $ExistingUser.SetPassword($Password)
}

# Ensure the admin password never expires
Write-Host "Ensuring password for $Username does not expire."
wmic useraccount where "Name='$Username'" set PasswordExpires=FALSE
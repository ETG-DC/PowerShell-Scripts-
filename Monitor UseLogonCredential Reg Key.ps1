<#
.Synopsis
Monitor for changes to HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest and send an alert if changes are made 
.Description
When the 'UseLogonCredential' reg key is added (or modified) and set to 1, WDigest will store password in clear-text, in memory. If a malicious user gains access to a system
and enables this key, they could use a tool like Mimikatz to grab the hashes stored in memory as well as the clear-text password for the accounts
#>

# Verify if the registry key exists
$verifyKey = Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest'

# If the key doesn't exist, no need to proceed further
if (-not $verifyKey) {
    Write-Output "Registry key does not exist"
    Break
}

Write-Output "Key exists. Checking the value..."

# Retrieve the value of the key
$getValue = Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest' -Name 'UseLogonCredential'

# Evaluate the value of the key
switch ($getValue) {
    0 {
        $result = "The value 0 is the expected value for this key."
    }
    1 {
        # RMM SPECIFIC MODULE REQUIRED $result = Rmm-Alert -Category 'Security Monitoring' -Body 'The UseLogonCredential value has been changed to 1. Investigate immediately! USE BACKGROUNDING TOOLS FIRST - DO NOT LOGIN WITH ADMIN CREDENTIALS'
    }
    default {
        $result = "Unexpected value detected: $getValue. Further investigation is required."
    }
}

# Output the result
$result
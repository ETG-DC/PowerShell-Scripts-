<#
.Description
This script checks if Network Discovery is enabled for the Private network profile. If the script finds Network Discovery is disabled, it enables it for the Private network profile only 
#>

function Test-NetworkDiscoveryRules {
    # Get all Network Discovery rules
    $rules = Get-NetFirewallRule -DisplayGroup "Network Discovery"

    # Filter rules for the Private profile
    $privateProfileRules = $rules | Where-Object { $_.Profile -like "Private" }

    # If no rules were found, return $false
    if ($privateProfileRules.Count -eq 0) {
        return $false
    }

    # Check if all Private profile rules are enabled
    foreach ($rule in $privateProfileRules) {
        if ($rule.Enabled -eq "false") {
            return $false
        }
    }

    # If all rules are enabled, return $true
    return $true
}
$allEnabled = Test-NetworkDiscoveryRules
Write-Host "Are Network Discovery enabled?: $allEnabled"

if(!($allEnabled)){
    Write-Host "Enabling Network Discovery for the Private profile only..." -Foregroundcolor Red
    # Enable Network Discovery for the PuPrivate profile
    Set-NetFirewallRule -DisplayGroup "Network Discovery" -Enabled true -Profile Private
}

<# Disable Network Discovery for the Public profile
Set-NetFirewallRule -DisplayGroup "Network Discovery" -Enabled False -Profile Public


# Get the status of Network Discovery rules
Get-NetFirewallRule -DisplayGroup "Network Discovery" | Select-Object Name, Enabled, Profile #>
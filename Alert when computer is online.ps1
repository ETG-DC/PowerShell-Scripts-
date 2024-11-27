Import-Module $env:SyncroModule

$computerName = $env:COMPUTERNAME

# Function to check if a computer is online
function Test-ComputerOnline {
    Param(
        [Parameter(Mandatory=$true)]
        [String]$ComputerName
    )
    
    $ping = New-Object System.Net.NetworkInformation.Ping
    $result = $ping.Send($ComputerName)
    
    if ($result.Status -eq 'Success') {
        return $true
    }
    
    return $false
}

# Main script
while ($true) {
    if (Test-ComputerOnline -ComputerName $computerName) {
        $alertCategory = "Decommissioned Computer Online Status"
        $alertBody = "The decommissioned computer '$computerName' is now online."
        
        Rmm-Alert -Category $alertCategory -Body $alertBody
        
        break  # Remove this line if you want to continue checking for online status
    }
    
    Start-Sleep -Seconds 10  # Adjust the sleep interval as needed
}

<#
Reset a DNS client to use the default DNS server addresses
#>

try{
    Stop-Service -Name "DNSFilter Agent" -Force
    $upNetworkAdapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
    $name = $upNetworkAdapters.name
    Set-DNSClientServerAddress -InterfaceAlias $Name -ResetServerAddresses
    Start-Service -Name "DNSFilter Agent" -Force
}
catch{
    Write-Host "Unable to stop DNSFilter Agent Service"
}


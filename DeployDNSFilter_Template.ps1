<#
.NAME
ETG - DeployDNSFilterTemplate.ps1

.Synopsis 
Scripted installation of the DNSFilter Roaming Client
#>

$tempDir = "c:\temp\DNSFilter"
$testPath = Test-Path -Path $tempDir -PathType Container
$outFile = "DNSFilter_Agent_Setup.msi"

$DNSFilterURI = "https://download.dnsfilter.com/User_Agent/Windows/DNSFilter_Agent_Setup.msi"

# Check if the direcotry exists
if (!(test-path $testPath)) {
    New-Item -ItemType Directory -Force -Path $tempDir
}

Invoke-WebRequest -Uri $DNSFilterURI -OutFile $tempdir\$outFile # Download the MSI and save it to C:\temp\DNSFilter\ and name it DNSFilter_Agent_Setup.msi
msiexec /qn /i $tempdir\$outFile NKEY="SITE SECRET KEY GOES HERE" #install DNSFilter_Agent_Setup.msi 
                                                                 # NKEY=Site Secret Key

Start-Sleep -s 15

$AgentName = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -ilike "*DNSFilter*"}


if ($AgentName) {
    # RMM SPECIFIC MODULE REQUIRED Rmm-Alert -Category 'DNSFilter' -Body 'DNSFilter Roaming Client was successfully installed' 
    Write-Host 'DNSFilter Roaming Client was successfully installed' -ForegroundColor Green
    
}
else {
    # # RMM SPECIFIC MODULE REQUIRED Rmm-Alert -Category 'DNSFilter' -Body 'DnsFilter Roaming Client installation failed'
    Write-Host "DnsFilter Roaming Client installation failed" -ForegroundColor Red
}
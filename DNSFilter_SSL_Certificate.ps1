<#
.Description
If browsing to an HTTPS-based website that is blocked by a Filtering Policy, the browser will display a certificate mismatch error if this Root CA certificate is not installed on the computer.
Downloading and installing this certificate allows block pages to display over HTTPS, subsequently allowing Proxy Bypass option and the contact form to be used. 

For more information see: https://help.dnsfilter.com/hc/en-us/articles/1500008110241-installing-ssl-certificates

#>

$certDownload = "https://app.dnsfilter.com/certs/NetAlerts.cer"
$webClient = New-Object System.Net.WebClient
$tempPath = "C:\temp"
$certDownloadFile = "$TempPath\NetAlerts.cer"
$T = Test-Path -Path $TemmpPath -PathType Container


if (!($T))
{ 
   New-Item -Path $TempPath  -ItemType directory
}

$webClient.DownloadFile($certDownload,$certDownloadFile)

certutil -addstore -enterprise -f "Root" "C:\temp\NetAlerts.cer"
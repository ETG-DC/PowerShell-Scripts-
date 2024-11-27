


# Ask for elevated permissions. This bypasses the execution policy (unless it's set to AllSigned) 
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
	Exit
}

<#$netConnCheck = Test-Connection google.com -Quiet -Count 1
if (!$netConnCheck) # if the network connection check returns false (ping google.com failed), advise user to check network connection
{
    Write-Host "Please check your network connection and try again" -ForegroundColor Red
    Start-Sleep -s 60
    return
    
}
else 
{
    Write-Host "Network connection good?: $netConnCheck" -ForegroundColor Yellow
    Write-Host "Confirmed network connection. Proceeding..." -ForegroundColor Green
}#>

# check if choco is installed
$checkChoco = Test-Path -Path "$env:ProgramData\chocolatey\choco.exe" -PathType Any
$checkExecPol = Get-ExecutionPolicy

# if for some reason the Execution Policy is set to All Signed, PowerShell just closes which isn't helpful
if ($checkExecPol -eq 'AllSigned') { 
    Write-Host "The execution policy is set to $checkExecPol which is preventing Choco from being installed" -ForegroundColor Red
    Write-Host "Please run the following cmdlet: Set-ExecutionPolicy Restricted  and then run the script again" -ForegroundColor Yellow
}

if(!$checkChoco){ 
    try{
        Write-Host "Chocolatey isn't installed, installing now" -ForegroundColor Green
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
    catch{
        Write-Host "Chocolatey is already installed" -ForegroundColor Green
    }
    
}
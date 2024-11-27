<#
.Name
    Download&Run Media Creation Tool.ps1

.Synopsis
    Download the Media Creation Tool and start it

.Description
    The Download&Run Media Creation Tool.ps1 script downloads the Media Creation tool to a custom directory and runs it
    In this version, it only starts the MCT for you, it will not autoinstall. The arguments list doesn't work reliably for MCT in PowerShell
    If you're looking for automating a Windows 10 feature update, please use the Install_Win10_21H2.ps1 script 
#>

##########
#Variables
##########
# Link for Media Creation Tool
$mctURL = "https://go.microsoft.com/fwlink/?LinkId=691209"

$mctDownloadDir = "C:\MCT"

# Location of MediaCreationTool21H2.exe
$mctDownloadFile = "C:\MCT\MediaCreationTool21H2.exe"

# Method for receiving data from a resource identidfied by URI
$webClient = New-Object System.Net.WebClient 

# Used later to confirm whether or not the paths exist
$mctPathTest = Test-Path -Path $mctDownloadFile -PathType Any
$mctPathDir = Test-Path -Path $mctDownloadDir -PathType Container

$netConnCheck = Test-Connection google.com -Quiet -Count 1

########################
#Network connection check
#########################

if (!$netConnCheck) # if the network connection check returns false (ping google.com failed), advise user to check network connection
{
    Write-Host "Please check your network connection and try again" -ForegroundColor Red
    
}
else 
{
    Write-Host "Network connection good?: $netConnCheck" -ForegroundColor Yellow
    Write-Host "Confirmed network connection. Proceeding..." -ForegroundColor Green
}

<###########################################################################################################################################
Confirm whether or not C:\MCT\MediaCreationTool21H2.exe exists; if true then start MediaCreationTool21H2.exe; if false then create the directory
C:\MCT then download the Media Creation Tool.  
###########################################################################################################################################>

if ($mctPathTest) # if C:\MCT\MediaCreationTool21H2.exe exists, run it
{
    Write-Host "All checks passed! Proceeding..." -ForegroundColor Green
    Start-Sleep 10

    try
        {
            
            Start-Process -FilePath $mctDownloadFile
            Start-Sleep 10
            Exit
        }

    catch 
        {
            Write-Host "MCT failed to start even though all tests passed" -ForegroundColor Red
            Write-Host "Please confirm network connectivity and that $mctDownloadFile actually exists"
            
        }
    }

elseif (!$mctPathTest) # If C:\MCT\MediaCreationTool21H2.exe doesn't exist, check a few things
{
    

        if (!$mctPathDir) # if c:\MCT doesn't exist then confirm, report and create
        {
            Write-Host "Does the MCT directory exist?: $mctPathDir" -ForegroundColor Yellow
            Write-Host "C:\MCT does not exist" -ForegroundColor Yellow
            Write-Host "Creating C:\MCT" -ForegroundColor Green
            New-Item -Path $mctDownloadDir -ItemType directory
            Write-Host "Downloading the Media Creation Tool..." -ForegroundColor Green
            $webClient.DownloadFile($mctURL,$mctDownloadFile) # The WebClient.DownloadFile Method Downloads the resource with the specified URI to a local file. Syntax: Webclient.DownloadFile(uri, string). 
            Start-Sleep -s 5 
            Start-Process -FilePath $mctDownloadFile # Run C:\MCT\MediaCreationTool21H2.exe
            Start-Sleep 10
            Exit # Close powershell
        }
        else
        {
            Write-Host "Either the download failed or the directory creation failed" -ForegroundColor Red
            Write-Host "Does the directory exist?: $mctDownloadDir"
            Write-Host "If false, directory creation failed for some reason. It'll be faster to manually download and run MCT at this point" -ForegroundColor Red
            Write-Host "Download can be found here: $mctURL"
            
        }

    }



else 
{ 
     Write-Host "Something went wrong. The Media Creation Tool couldn't be downloaded or found. Try downloading it manually by going to $mctURL" -ForegroundColor Red
}
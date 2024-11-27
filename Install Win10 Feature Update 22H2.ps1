<#  Install_Win10_FU_22H2

.Synopsis
    Installs the latest Windows 10 feature update 

.Description
    This script checks the build version of Windows 10 running on a computer; If the build value is less than Windows 10 22H2 (Build 19045), the FU will be installed;
    If the build value returned is equal to Windows 10 22H2 (Build 19045), the user will be advised the FU is not needed and the script will close

#>

<#_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
  _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ #>

Import-Module $env:SyncroModule

# Directory WUA will be saved in
$wuaDir = "C:\WUA\packages"

# Link for downloading WUA
$wuaDownload= "https://go.microsoft.com/fwlink/?LinkID=799445"

# Location of WUA
$wuaDownloadFile = "$($wuaDir)\Win10Upgrade.exe"

# Locations of Win 10 Update Assistant Shortcuts
$WinAssDel = "$Env:UserProfile\Desktop\Windows 10 Update Assistant.lnk"
$WinAssStartMenuDel = "$Env:Programdata\Microsoft\Windows\Start Menu\Programs\Windows 10 Update Assistant.lnk"

# Method for receiving data from a resource identified by URI
$webClient = New-Object System.Net.WebClient

$t = Test-Path -Path $wuaDir -PathType Container

# Get the build number
$winVer = [System.Environment]::OSVersion.Version.Build

$b19044orLess = "This PC is running Windows 10 build $winVer. Updates are needed. Proceeding with feature update 22H2!"
$b19045 = "This PC is running Windows 10 version 22H2. This is the latest version. No updates were installed"

#_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _#

# Check if the $wuaDir exists and create it if it doesn't
if (!($t)) { 
        New-Item -Path $wuaDir  -ItemType directory
    }

#_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _#


 # Check the value returned by $winVer to determine if the FU is needed and install it if true
if ($winVer -le 19044)
    {   
        Rmm-Alert -Category 'Win 10 22H2 Update' -Body $b19044orLess
        Write-Host "Installing feature update 22H2..." -ForegroundColor Green
        $webClient.DownloadFile($wuaDownload,$wuaDownloadFile)
        Start-Process -FilePath $wuaDownloadFile -WindowStyle Hidden -ArgumentList "/QuietInstall /SkipEULA /NoRestartUI" -Wait  
        Remove-Item -path $WinAssStartMenuDel -Force
        Remove-Item -path $WinAssDel -Force
    }
        
 # If the returned value is equal to the latest version of Windows then don't do anything 
else
    {
        Rmm-Alert -Category 'Win 10 22H2 Update' -Body $b19045 
        start-sleep -s 15
        Exit
    }

    



<#
.Description
	The Windows Update Assistant will fail to run if the Windows Installation Assistant folder still exists after a previous upgrade. Use this script to remove left over WUA components
#>

$wiaCheck = Test-Path -Path "C:\Program Files (x86)\WindowsInstallationAssistant"
$wuaDir = Test-Path -Path "C:\WUA"
$esd = Test-Path -Path "C:\ESD"

if($wiaCheck){
    Remove-Item -Path "C:\Program Files (x86)\WindowsInstallationAssistant" -Recurse -Force
}
else{
    Write-Host "Windows Installation Assistant was not found"
}

if($wuaDir){
    Remove-Item -Path "C:\WUA" -Recurse -Force
}
else{
    Write-Host "WUA directory was not found"
}
if($esd){
    Remove-Item -Path "C:\ESD" -Recurse -Force
}
else{
    Write-Host "ESD directory was not found"
}
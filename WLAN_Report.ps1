Import-Module $env:SyncroModule

$reportDir = "$env:ProgramData\Microsoft\Windows\WlanReport"
$report = "$env:ProgramData\Microsoft\Windows\WlanReport\wlan-report-latest.html"
$tempDir = "c:\temp"
$newReportLocation = "C:\temp\wlan-report-latest.html"
$i = [ref]1

$reportPathTest = Test-Path -Path "$env:ProgramData\Microsoft\Windows\WlanReport\wlan-report-latest.html" -PathType leaf
$tempPathTest = Test-Path -Path $tempDir -PathType container

if(!($tempPathTest)){
      New-Item -ItemType Directory -Force -Path $tempDir
}

set-location $reportDir

if ($reportPathTest){
    Get-ChildItem "wlan-report-latest.html" | rename-item -NewName {'wlan-report-latest.html.bak{0}' -f $i.value++, $_.Name}
    netsh wlan show wlanreport
    start-sleep 30
    copy-item -Path $report -Destination $tempDir -Recurse -Force
    upload-file -FilePath $newReportLocation
}

else{
    netsh wlan show wlanreport
    start-sleep 30
    copy-item -Path $report -Destination $tempDir -Recurse -Force
    upload-file -filePath $newReportLocation
}
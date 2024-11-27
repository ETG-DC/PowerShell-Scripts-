<#. Description
This script reads and parses the newest chkdsk results (-source wininit) then writes the parsed output 
to a txt file and uploads it to attachments section on the asset page in RMM (chkdsk.txt) #>

$path = "C:\temp\" 
# check if c:\temp exists. If it doesn't, create it
if (!(test-path $path)) {
    New-Item -ItemType Directory -Force -Path $path
}

$computerName = $env:COMPUTERNAME
$LastDay = (Get-Date) - (New-TimeSpan -Day 30)
$chkdskFile = "C:\temp\${computerName}_chkdskResults.txt"

 
 $events = Get-WinEvent -FilterHashtable @{
    LogName='Application'
    Id = 1001
    StartTime=$LastDay
    } | Where-Object { $_.Message -like '*checking file system*' } 

# Export the events to txt file
$events.Message | Out-File $chkdskFile
$lines = Get-Content -Path $chkdskFile 
$lines = $lines.count
Write-Host "Lines contains $($lines) lines." #Should be around 83 lines

if($lines -ge 100) {
    Write-Host "Chkdsk results may not get parsed correctly due to high line count...uploading the entire chkdsk results file"
    #Upload-File -FilePath $chkdskFile #RMM specific module required 
}
elseif ($lines -le 100) {
    $readResults = Get-Content $chkdskFile
    $readResults | Select-Object -Last 25 | Out-File $chkdskFile
    #Upload-File -FilePath $chkdskFile #RMM specific module required 
}
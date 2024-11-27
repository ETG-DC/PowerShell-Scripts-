## I think there was something wrong with the conversions - IIRC they might be outputting the incorrect results or not working at all. I have several variants of this script so it's possible I'm thinking of a different scrupt. 
## A portion of this script needs to overhauled and simplified. Haven't had time - will revisit 

if (!(test-path C:\temp\Speedtest)) {
    New-Item -ItemType Directory -Force -Path C:\temp\Speedtest
}
# Change directory 
Set-Location C:\temp\Speedtest

$outputfile = ".\internetspeed.json" #JSON file where the test results are stored
$testduration = 1 
$interval = 1 #wait and restart after $interval seconds
$numberoftests = $testduration*3/$interval #calculated based on $testduration and the $interval

Write-Host "Running test every " $interval "seconds"
Write-Host "Tests to run:" $numberoftests
Write-Host "Writing test results to a file:"$outputfile

Write-Host ""
# If the JSON exists but it's blank, delete it
if (Test-Path -Path $outputfile -PathType Leaf) {
  $content = Get-Content $outputfile -Raw
  if ($content.count -eq 0) {
    Remove-Item -Path $outputfile -Recurse -Force
    Write-Host "Deleted empty JSON file"
  }
}

Start-Sleep -s 5
# Create the JSON file
if (!(Test-Path -Path $outputfile -PathType Leaf)) {
  "[]" | Out-File -FilePath $outputfile -Append -Encoding utf8
}

$failed = 0
for($i = 0; $i -lt $numberoftests; $i++){ # run the test until $numberoftests is met
    Write-Host "---"
    Write-Host "Running speed test #"$($i+1)

    #running speedtest
    $response = .\speedtest.exe --accept-license --format=json-pretty --unit=Mbps
    $responseObj = $response | ConvertFrom-Json

    if ("result" -eq $responseObj.type) {
      # appending result to the output file
      $content = Get-Content $outputfile -Raw
      
      $separator = ""
      if($content.Length -gt 4) {
        $separator = ","
      }
      
      $content = $content.Substring(0,$content.Length-3)+$separator+"`r`n"+$response+"]"
      $content | Set-Content $outputfile
      
      Write-Host "Download:"$($responseObj.download.bandwidth*8/1000000)"Mbps"
      Write-Host "Upload:"$($responseObj.upload.bandwidth*8/1000000)"Mbps"
      Write-Host "Test #"$($i+1)"completed"
      
    }

    # Read the JSON file
    $prevResults = Get-Content $outputfile -Raw | ConvertFrom-Json

    # if the JSON file contains no data, stop the script 
    if ($prevResults.count -eq 0) {
      Write-Host "Hmm there doesn't seem to be any data in the JSON file. Something went wrong"
      Write-Host "Stopping script..."
      Rmm-Alert -Category 'Speedtest Failed' -Body 'Something went wrong with the speedtest'
      Exit
    } else {
      Write-Host "There are previous results present...continuing..."
    }

    if ($prevResults.count -gt 1) {
          $prevDownload = $prevResults[-2].download.bandwidth # Get download bandwidth from last test
          $currentDownload = $responseObj.download.bandwidth # Get download bandwidth from current test
          $percentageDifference = [Math]::Abs(($currentDownload - $prevDownload) / $prevDownload * 100) # [Math]::Abs() is used to calculate the absolute difference between two values: $prevDownload and $currentDownload
          Write-Host "Percentage Difference (download):" $percentageDifference

          if ($percentageDifference -gt 15) {
              Write-Host "ALERT: Difference in download bandwidth is greater than 15%."
              Rmm-Alert -Category 'Possible Download Speed Issues' -Body 'Difference in download bandwidth speed is greater than 15%'
          }
            
          $prevUpload = $prevResults[-2].upload.bandwidth # Get upload bandwidth from last test
          $currentUpload = $($responseObj.upload.bandwidth*8/1000000) # Get upload bandwidth from current test and convert it to a readable value 
          $percentageDifferenceUpload = [Math]::Abs(($currentUpload - $prevUpload) / $prevUpload * 100) # [Math]::Abs() is used to calculate the absolute difference between two values: $prevDownload and $currentDownload
          Write-Host "Percentage Difference (upload):" $percentageDifferenceUpload
          
          if ($percentageDifferenceUpload -gt 15) {
              Write-Host "Upload:"$($responseObj.upload.bandwidth*8/1000000)"Mbps"
              Rmm-Alert -Category 'Possible Upload Speed Issues' -Body 'Difference in upload bandwidth speed is greater than 15%'
          } else {
            Write-Host "Upload:"$($responseObj.upload.bandwidth*8/1000000)"Mbps"
          }
    } else {
      Write-Error "Error"
      $failed+=1
    }

    Write-Host "Total tests:" $($i+1) "(failed" $failed")"
    Write-Host "---"
    Write-Host ""

    Start-Sleep -Seconds $interval
}
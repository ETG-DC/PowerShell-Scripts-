$disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object Size, FreeSpace # Get disk size and free space

Write-Host ("{0}GB total" -f [math]::truncate($disk.Size / 1GB)) # Convert the Size object from Bytes to Gigibytes and output the value in a readable format
Write-Host ("{0}GB free" -f [math]::truncate($disk.FreeSpace / 1GB)) # Convert the FreeSpace object from Bytes to Gigibytes and output the value in a readable format

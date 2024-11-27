<#
.Description
Run this script to find out which video outputs are being used. It will not list video outputs that are NOT in use. 
#>

# Define the mapping of VideoOutputTechnology values to their names
$videoOutputTechnologyMap = @{
    (-2) = "D3DKMDT_VOT_UNINITIALIZED"
    (-1) = "D3DKMDT_VOT_OTHER"
    0  = "D3DKMDT_VOT_HD15 (VGA)" #VGA
    1  = "D3DKMDT_VOT_SVIDEO"
    2  = "D3DKMDT_VOT_COMPOSITE_VIDEO"
    3  = "D3DKMDT_VOT_COMPONENT_VIDEO"
    4  = "D3DKMDT_VOT_DVI"
    5  = "D3DKMDT_VOT_HDMI"
    6  = "D3DKMDT_VOT_LVDS"
    8  = "D3DKMDT_VOT_D_JPN"
    9  = "D3DKMDT_VOT_SDI"
    10 = "D3DKMDT_VOT_DISPLAYPORT_EXTERNAL"
    11 = "D3DKMDT_VOT_DISPLAYPORT_EMBEDDED"
    12 = "D3DKMDT_VOT_UDI_EXTERNAL"
    13 = "D3DKMDT_VOT_UDI_EMBEDDED"
    14 = "D3DKMDT_VOT_SDTVDONGLE"
    15 = "D3DKMDT_VOT_MIRACAST"
    2147483648 = "D3DKMDT_VOT_INTERNAL"  # 0x80000000
}

# Get WMI object
$objWMi = Get-WmiObject -Namespace root\WMI -ComputerName localhost -Query "Select * from WmiMonitorConnectionParams"

# Iterate over the results and print the details
foreach ($obj in $objWMi)
{
    # Debugging: Print raw VideoOutputTechnology value
    Write-Host "Raw VideoOutputTechnology:" $obj.VideoOutputTechnology
    
    # Cast to integer
    $videoOutputTechValue = [int]$obj.VideoOutputTechnology
    
    # Try to get the friendly name from the map
    $videoOutputTechName = $videoOutputTechnologyMap[$videoOutputTechValue]
    
    if ($null -eq $videoOutputTechName) {
        $videoOutputTechName = "Unknown"
    }

    Write-Host "Active:" $obj.Active
    Write-Host "InstanceName:" $obj.InstanceName
    Write-Host "VideoOutputTechnology:" $videoOutputTechName
    Write-Host
    Write-Host "########"
    Write-Host
    
    Log-Activity -Message "Video output(s) in use: $($videoOutputTechName)" -EventName "Video Output(s) In Use"
}

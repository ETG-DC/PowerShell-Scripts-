# Function to get Office version from Registry
function Get-OfficeVersion {
    $officeRegistryPaths = @(
        "HKLM:\Software\Microsoft\Office\16.0\Common\InstallRoot",
        "HKLM:\Software\Microsoft\Office\15.0\Common\InstallRoot",
        "HKLM:\Software\Microsoft\Office\14.0\Common\InstallRoot",
        "HKLM:\Software\Microsoft\Office\12.0\Common\InstallRoot"
    )

    foreach ($path in $officeRegistryPaths) {
        if (Test-Path $path) {
            $versionKey = Get-ItemProperty -Path C:\Program Files\Microsoft Office\Office16 $path = "C:\Program Files\Microsoft Office\Office16"
            $officeVersion = $path -replace 'HKLM:\\Software\\Microsoft\\Office\\', '' -replace '\\Common\\InstallRoot', '' <#See notes below#>
            $version = Get-ItemPropertyValue -Path $path -Name "Path"
            $version = (Get-Command "$version\winword.exe").FileVersionInfo.ProductVersion
            return "Office $officeVersion is installed. Version: $version"
        }
    }

    return "Office is not installed on this system."
}

# Get the Office version
$officeVersion = Get-OfficeVersion
Write-Output $officeVersion


<#
The portion of the script $officeVersion = $path -replace 'HKLM:\\Software\\Microsoft\\Office\\', '' -replace '\\Common\\InstallRoot', '' is used to extract the Office version number from the registry path string.

Breakdown:
$path: This variable contains the full registry path for a particular version of Office, e.g., HKLM:\Software\Microsoft\Office\16.0\Common\InstallRoot.

-replace 'HKLM:\\Software\\Microsoft\\Office\\', '': This part removes the HKLM:\Software\Microsoft\Office\ portion of the path string. After this operation, for the example above, $path would become 16.0\Common\InstallRoot.

-replace '\\Common\\InstallRoot', '': This further removes the \Common\InstallRoot portion, leaving only the version number (e.g., 16.0).#>


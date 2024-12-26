<#
.Synopsis
This script runs based off the automated remediation we have configured in Syncro called "Automated Bitdefender Installation"

.Description
The "Confirm Bitdefender Installation.ps1" script checks if Bitdefender is installed. If it's not, it triggers an RMM alert with the message:
"Bitdefender wasn't found. Attempting automated remediations."
This alert initiates the automated remediation process called "Automated Bitdefender Installation," which runs this script. 
Upon confirming that Bitdefender is not installed, the script identifies the full file path of the Bitdefender installer executable and assigns it to $getBDInstallerWithHash. 
This step is crucial because the installer’s filename includes a company-specific hash.
Once the file path is resolved, the script executes the installer and pauses until the installation process is complete. 
Afterward, the script verifies that Bitdefender has been successfully installed and sends a confirmation alert.


.Notes
The command "$getBDInstallerWithHash = Get-ChildItem -path $installerLocation -Recurse | Where-Object {$_.Name -ilike 'setupdownloader*'} | Select-Object FullName" results in PowerShell complaining that the file doesn’t exist because 
the value assigned to $getBDInstallerWithHash is an array containing a single file object, not a string with the file’s full path. 
This happens because Get-ChildItem returns file objects, and the Where-Object and Select-Object cmdlets filter and select properties without flattening the output. 
The fix for this was using the -ExpandProperty parameter with Select-Object to extract the FullName property directly as a string. Doing it this $getBDInstallerWithHash contains the exact file path as a string, which can be passed directly to Start-Process.

Known issues:
- Will fail if Acronis is installed (even if Acronis endpoint protection isn't installed). Acronis has to be removed before installation will complete
- Will fail if any competing AV products are installed. Confirm Malwarebytes, Avast,AVG, Mcafee, and Trusteer are removed prior to installation
#>


$isBDInstalled = [bool]((Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | 
Where-Object { $_.DisplayName -eq "Bitdefender Endpoint Security Tools" }))

if ($isBDInstalled) {
    Write-Host "Bitdefender is already installed"
    Rmm-Alert -Category 'Automated Bitdefender Installation' -Body 'Bitdefender is already installed'
    Exit 0
}


$installerLocation = "C:\ProgramData\Syncro\bin"
$getBDInstallerWithHash = Get-ChildItem -path $installerLocation -Recurse | Where-Object {$_.Name -ilike 'setupdownloader*'} | Select-Object -ExpandProperty FullName

try {
    Start-Process $getBDInstallerWithHash -ArgumentList '/bdparams /silent' -Wait -NoNewWindow
    
    $isBDInstalled = [bool]((Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | 
    Where-Object { $_.DisplayName -eq "Bitdefender Endpoint Security Tools" }))

        if (!($isBDInstalled)) {
            Write-Host "Bitdefender tried installing but failed"
            Rmm-Alert -Category 'Automated BD Installation' -Body "Bitdefender installation failed. The installer ran but it timed out. Confirm all competitor AVs are removed (Avast, Trusteer, Malwarebytes, etc.) and also remove Acronis if it's installed"
            Exit 0
        }
        else {
            Rmm-Alert -Category 'Automated BD Installation' -Body 'Bitdefender installation succeeded'
        }
}
catch {
    Rmm-Alert -Category 'Automated BD Installation' -Body 'Bitdefender installer failed to run. This can happen if there are two Bitdefender installers with the same name in %programdata%\syncro\bin. Please review'
    Write-Host "The BD installer failed to run"
}
    





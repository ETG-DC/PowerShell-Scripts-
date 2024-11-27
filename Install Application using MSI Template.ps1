Import-Module $env:SyncroModule

$tempDir = "c:\temp\"
$installer = "Installername.msi" 
$testPath = Test-Path -Path $tempDir -PathType Container

# Check if the direcotry exists
if (!(test-path $testPath)) {
    New-Item -ItemType Directory -Force -Path $tempdir
}

msiexec /qn /i $tempdir\$installer 
$computer = Get-WmiObject Win32_ComputerSystem 
$computer.JoinDomainOrWorkGroup("titties.local", "PASSWORD", "Administrator", $null, 3) 
Restart-Computer -Force
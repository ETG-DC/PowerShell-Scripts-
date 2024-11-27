$d = "$env:localappdata\Microsoft\OneDrive\onedrive.exe"
$e = "$env:programfiles\Microsoft OneDrive\onedrive.exe"
$f = "${env:ProgramFiles(x86)}\Microsoft OneDrive\onedrive.exe"

$a = Test-Path -Path $d -PathType Any
$b = Test-Path -Path $e -PathType Any
$c = Test-Path -Path $f -PathType Any

if(($a) -and ($b)) {
    #Do nothing 
    write-host "OneDrive.exe found in two locations: $d and $e"
    exit
}

if(($a) -and ($c)) {
    #Do nothing 
    write-host "OneDrive.exe found in two locations: $d and $f"
    exit
}

if($a){
    start-process $d /reset -Wait
    start-process $d
}
elseif($b){
    start-process $e /reset -Wait
    start-process $e
}
elseif($c){
    start-process $f /reset -Wait
    start-process $f 
}
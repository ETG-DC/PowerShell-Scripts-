

$remoteTools = @(
    @{
        Name = "TeamViewer"
    },
    @{
        Name = "UltraViewer"
    },
    @{
        Name = "ScreenConnect"
    },
    @{
        Name = "LogMeIn"
    },
    @{
        Name = "GoToMyPC"
    },
    @{
        Name = "Supremo"
    },
    @{
        Name = "AnyDesk"
    }
)

foreach ($tool in $remoteTools) {
    $toolName = $tool.Name
    $installed = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*$toolName*" }
    if ($installed) {
        Write-Host "$toolName is installed."
    } else {
        Write-Host "$toolName is not installed."
    }
}

Write-Host "Clearing Recent Files and Folders from Quick Access..."

# Remove recent files
Get-ChildItem $env:APPDATA\Microsoft\Windows\Recent\* -File -Force -Exclude desktop.ini | 
    Remove-Item -Force -ErrorAction SilentlyContinue

# Remove automatic destinations, excluding key files
Get-ChildItem $env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations\* -File -Force -Exclude desktop.ini, f01b4d95cf55d32a.automaticDestinations-ms | 
    Remove-Item -Force -ErrorAction SilentlyContinue

# Remove custom destinations
Get-ChildItem $env:APPDATA\Microsoft\Windows\Recent\CustomDestinations\* -File -Force -Exclude desktop.ini | 
    Remove-Item -Force -ErrorAction SilentlyContinue

# Remove unpinned folders from Quick Access
Write-Host "Clearing unpinned folders from Quick Access..."
$UnpinnedQAFolders = $true
while ($UnpinnedQAFolders) {
    # Retrieve the items from the Quick Access namespace
    $QuickAccessNamespace = (New-Object -ComObject Shell.Application).Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}")
    $QuickAccessItems = $QuickAccessNamespace.Items() | Where-Object { $_.IsFolder -eq $true }

    # Filter items with the "Remove from Quick access" verb
    $UnpinnedQAFolders = @(
        foreach ($item in $QuickAccessItems) {
            $item.Verbs() | Where-Object { $_.Name -match "Remove from Quick access" }
        }
    )

    # Execute the "Remove from Quick access" action
    if ($UnpinnedQAFolders.Count -gt 0) {
        foreach ($verb in $UnpinnedQAFolders) {
            $verb.DoIt()
        }
    }
}

# Restart File Explorer
Write-Host "Restarting Explorer..."
Stop-Process -Name explorer -Force

# Clean up variables
Remove-Variable UnpinnedQAFolders -ErrorAction SilentlyContinue

Write-Host "Done!"

# Paths
$Cs2Cfg = "C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg"
$Dotfiles = "C:\Users\phili\Documents\REPO\dotfiles\config\cs2"

Write-Host "Creating CS2 symlinks..."

Set-Location $Cs2Cfg

# Links to create
$Links = @{
    "autoexec.cfg" = "$Dotfiles\autoexec.cfg"
    "demoexec.cfg" = "$Dotfiles\demoexec.cfg"
    "cfgdeps"       = "$Dotfiles\cfgdeps"
}

foreach ($Link in $Links.GetEnumerator()) {
    $Path = Join-Path $Cs2Cfg $Link.Key
    $Target = $Link.Value

    # Remove existing file/folder/link
    if (Test-Path $Path) {
        Remove-Item $Path -Force -Recurse
    }

    New-Item `
        -ItemType SymbolicLink `
        -Path $Path `
        -Target $Target | Out-Null

    Write-Host "✓ $($Link.Key) -> $Target"
}

Write-Host ""
Write-Host "Done!"

# Loaded by the dedicated Dotfiles PowerShell terminal profile.
function global:repo { Set-Location -LiteralPath (Join-Path $HOME 'REPO') }
function global:dl { Set-Location -LiteralPath (Join-Path $HOME 'Downloads') }
$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (& starship init powershell | Out-String)
}
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& zoxide init powershell | Out-String)
}
function global:termhelp {
    @'
repo             Go to ~/REPO
dl               Go to ~/Downloads
nvim             Open Neovim
z <name>         Jump to a previously visited directory
Neovim :Overview Show setup actions and shortcuts
Caps+A / Caps+D  Beginning / end of line in the terminal
Caps+W / Caps+S  Top / bottom of file in Neovim
'@
}

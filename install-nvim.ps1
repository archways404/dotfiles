param(
    [ValidateSet('us', 'se')][string]$Keyboard,
    [switch]$SkipDeps,
    [switch]$NoSync,
    [switch]$Copy
)
$ErrorActionPreference = 'Stop'
# Resolve a real Python; Windows App Execution Alias stubs may not be installed Python.
$Python = $null
foreach ($Candidate in @('python', 'python3', 'py')) {
    if (Get-Command $Candidate -ErrorAction SilentlyContinue) {
        $Version = & $Candidate -c 'import sys; print(sys.executable)'
        if ($LASTEXITCODE -eq 0 -and $Version) { $Python = $Version.Trim(); break }
    }
}
if (-not $Python) {
    if ($SkipDeps) { throw 'Python 3.9+ is required.' }
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { throw 'Install Microsoft App Installer (winget), then rerun.' }
    & winget install --id Python.Python.3.13 --exact --source winget --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) { throw 'Python installation failed.' }
    $Python = Join-Path $env:LOCALAPPDATA 'Programs\Python\Python313\python.exe'
    if (-not (Test-Path $Python)) { throw 'Python installed. Open a fresh terminal and rerun this script.' }
}
$InstallerArgs = @((Join-Path $PSScriptRoot 'scripts\install_nvim.py'))
if ($Keyboard) { $InstallerArgs += @('--keyboard', $Keyboard) }
if ($SkipDeps) { $InstallerArgs += '--skip-deps' }
if ($NoSync) { $InstallerArgs += '--no-sync' }
if ($Copy) { $InstallerArgs += '--copy' }
& $Python @InstallerArgs
exit $LASTEXITCODE

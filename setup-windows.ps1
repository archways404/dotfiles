param(
    [ValidateSet('us', 'se')][string]$Keyboard,
    [switch]$SkipDeps,
    [switch]$NoSync,
    [switch]$SkipFont,
    [switch]$SkipRemap,
    [switch]$SkipShell,
    [switch]$Copy,
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$LogDirectory = Join-Path $env:LOCALAPPDATA 'dotfiles'
New-Item -ItemType Directory -Force -Path $LogDirectory | Out-Null
Start-Transcript -Path (Join-Path $LogDirectory 'install.log') -Append | Out-Null
try {
    function Refresh-SetupPath {
        $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
            [Environment]::GetEnvironmentVariable('Path', 'User') + ';' + $env:Path
    }
    if (-not $SkipDeps -and -not $DryRun -and -not (Get-Command winget -ErrorAction SilentlyContinue)) {
        # Microsoft's documented bootstrap, using its module from PSGallery.
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Install-PackageProvider -Name NuGet -Force -Scope CurrentUser | Out-Null
        Install-Module -Name Microsoft.WinGet.Client -Scope CurrentUser -Force -Repository PSGallery | Out-Null
        Import-Module Microsoft.WinGet.Client
        Repair-WinGetPackageManager
        Refresh-SetupPath
        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            throw 'WinGet could not be bootstrapped. Install Microsoft App Installer and rerun.'
        }
    }
    $Python = $null
    $Candidates = @('python', 'python3', 'py')
    $Candidates += @(Get-ChildItem (Join-Path $env:LOCALAPPDATA 'Programs\Python\Python*\python.exe') -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName)
    foreach ($Candidate in $Candidates) {
        $CandidateCommand = Get-Command $Candidate -ErrorAction SilentlyContinue
        if ($CandidateCommand) {
            # Skip the Windows Store launcher stub on a fresh machine.
            if ($CandidateCommand.Source -match '\\Microsoft\\WindowsApps\\python[0-9]*\.exe$') { continue }
            $Executable = & $Candidate -c 'import sys; print(sys.executable if sys.version_info >= (3, 9) else "")' 2>$null
            if ($LASTEXITCODE -eq 0 -and $Executable) { $Python = $Executable.Trim(); break }
        }
    }
    if (-not $Python) {
        if ($SkipDeps -or $DryRun) { throw 'Python 3.9+ is required for this option.' }
        & winget install --id Python.Python.3.13 --exact --source winget --silent --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -ne 0) { throw 'Python installation failed.' }
        Refresh-SetupPath
        $Python = Join-Path $env:LOCALAPPDATA 'Programs\Python\Python313\python.exe'
        if (-not (Test-Path $Python)) {
            $Python = (Get-Command python.exe -ErrorAction Stop).Source
        }
    }
    $SetupArgs = @((Join-Path $PSScriptRoot 'scripts\setup.py'))
    if ($Keyboard) { $SetupArgs += @('--keyboard', $Keyboard) }
    foreach ($Option in @(
        @($SkipDeps, '--skip-deps'), @($NoSync, '--no-sync'), @($SkipFont, '--skip-font'),
        @($SkipRemap, '--skip-remap'), @($SkipShell, '--skip-shell'), @($Copy, '--copy'), @($DryRun, '--dry-run')
    )) {
        if ($Option[0]) { $SetupArgs += $Option[1] }
    }
    & $Python @SetupArgs
    if ($LASTEXITCODE -ne 0) { throw "Setup exited with code $LASTEXITCODE" }
} catch {
    Write-Host $_ -ForegroundColor Red
    exit 1
} finally {
    Stop-Transcript | Out-Null
}

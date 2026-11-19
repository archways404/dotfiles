param([Parameter(ValueFromRemainingArguments = $true)][string[]]$MenuArgs)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
# No transcript: PINs and authorization interactions stay in the local terminal.
function Refresh-SshSetupPath {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
        [Environment]::GetEnvironmentVariable('Path', 'User') + ';' + $env:Path
}
try {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Install-PackageProvider -Name NuGet -Force -Scope CurrentUser | Out-Null
        Install-Module -Name Microsoft.WinGet.Client -Scope CurrentUser -Force -Repository PSGallery
        Import-Module Microsoft.WinGet.Client
        Repair-WinGetPackageManager
        Refresh-SshSetupPath
        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            throw 'WinGet is unavailable. Install Microsoft App Installer, then rerun.'
        }
    }
    $SshSetupPython = $null
    $Candidates = @('python', 'python3', 'py')
    $Candidates += @(Get-ChildItem (Join-Path $env:LOCALAPPDATA 'Programs\Python\Python*\python.exe') -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName)
    foreach ($Candidate in $Candidates) {
        $Command = Get-Command $Candidate -ErrorAction SilentlyContinue
        if ($Command -and $Command.Source -notmatch '\\Microsoft\\WindowsApps\\python[0-9]*\.exe$') {
            $Executable = & $Candidate -c 'import sys; print(sys.executable if sys.version_info >= (3, 9) else "")' 2>$null
            if ($LASTEXITCODE -eq 0 -and $Executable) { $SshSetupPython = $Executable.Trim(); break }
        }
    }
    if (-not $SshSetupPython) {
        & winget install --id Python.Python.3.13 --exact --source winget --silent --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -ne 0) { throw 'Python installation failed.' }
        Refresh-SshSetupPath
        $SshSetupPython = Join-Path $env:LOCALAPPDATA 'Programs\Python\Python313\python.exe'
        if (-not (Test-Path $SshSetupPython)) {
            $SshSetupPython = (Get-Command python.exe -ErrorAction Stop).Source
        }
    }
    & $SshSetupPython (Join-Path $PSScriptRoot 'scripts\ssh_setup.py') @MenuArgs
    exit $LASTEXITCODE
} catch {
    Write-Host $_ -ForegroundColor Red
    exit 1
}

#!/usr/bin/env python3
"""Portable YubiKey SSH setup. Only public keys/certificates are exported."""
import argparse
import base64
import datetime
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import sys
import tempfile
import webbrowser

REPO = Path(__file__).resolve().parents[1]
BEGIN, END = '# BEGIN dotfiles YubiKey SSH', '# END dotfiles YubiKey SSH'
IDENTITY = 'yubikey-piv-9a.pub'


def run(*args, capture=False, **kwargs):
    kwargs.setdefault('stdout', subprocess.PIPE if capture else None)
    result = subprocess.run([str(a) for a in args], check=True, text=True, **kwargs)
    return result.stdout if capture else result.returncode


def public_fields(text):
    fields = text.strip().split()
    if len(fields) < 2 or fields[0] not in ('ecdsa-sha2-nistp256', 'ecdsa-sha2-nistp384', 'ssh-rsa'):
        raise ValueError('Expected an RSA or ECDSA SSH public key.')
    try:
        blob = base64.b64decode(fields[1], validate=True)
        size = int.from_bytes(blob[:4], 'big')
        if blob[4:4 + size].decode('ascii') != fields[0]:
            raise ValueError('Key type does not match its encoded data.')
    except (ValueError, UnicodeError) as error:
        raise ValueError('Invalid SSH public-key encoding.') from error
    return fields[:2]


def fingerprint(text):
    digest = hashlib.sha256(base64.b64decode(public_fields(text)[1])).digest()
    return 'SHA256:' + base64.b64encode(digest).decode().rstrip('=')


def find_tools(provider=None):
    system = platform.system()
    if system == 'Windows':
        roots = [Path(os.environ.get('ProgramW6432', 'C:/Program Files')),
                 Path(os.environ.get('ProgramFiles', 'C:/Program Files'))]
        bins = [root / 'OpenSSH' for root in roots]
        bins += [Path(os.environ.get('WINDIR', 'C:/Windows')) / 'System32/OpenSSH']
        providers = [root / 'Yubico/Yubico PIV Tool/bin/libykcs11.dll' for root in roots]
        names = ('ssh.exe', 'ssh-keygen.exe', 'yubico-piv-tool.exe')
    else:
        bins = [Path('/opt/homebrew/bin'), Path('/usr/local/bin'), Path('/usr/bin')]
        providers = [Path(p) for p in ('/opt/homebrew/lib/libykcs11.dylib',
                     '/usr/local/lib/libykcs11.dylib', '/usr/lib/x86_64-linux-gnu/libykcs11.so',
                     '/usr/lib/aarch64-linux-gnu/libykcs11.so', '/usr/lib/libykcs11.so')]
        names = ('ssh', 'ssh-keygen', 'yubico-piv-tool')
    library = Path(provider) if provider else next((p for p in providers if p.is_file()), None)
    if not library or not library.is_absolute() or not library.is_file():
        raise RuntimeError('PIV provider not found. Run Install tools, or pass --provider with its absolute path.')
    if any(c in str(library) for c in ('\n', '\r', '"')):
        raise RuntimeError('Unsupported provider path.')
    if system == 'Windows':
        bins.insert(0, library.parent)
        os.environ['PATH'] = str(library.parent) + os.pathsep + os.environ.get('PATH', '')
    found = {}
    for label, name in zip(('ssh', 'keygen', 'piv'), names):
        found[label] = next((str(d / name) for d in bins if (d / name).is_file()), shutil.which(name))
        if not found[label]:
            raise RuntimeError(f'{name} not found. Run Install tools first.')
    found['provider'] = str(library.resolve())
    os.environ['PATH'] = str(Path(found['ssh']).parent) + os.pathsep + os.environ.get('PATH', '')
    return found


def install_tools():
    system = platform.system()
    if system == 'Darwin':
        brew = shutil.which('brew') or next((str(p) for p in
               (Path('/opt/homebrew/bin/brew'), Path('/usr/local/bin/brew')) if p.is_file()), None)
        if not brew:
            raise RuntimeError('Run ssh-macos.command to bootstrap Homebrew and Python first.')
        run(brew, 'install', 'git', 'openssh', 'yubico-piv-tool', 'ykman', 'gh')
    elif system == 'Windows':
        if not shutil.which('winget'):
            raise RuntimeError('Run ssh-windows.cmd to bootstrap WinGet and Python first.')
        architecture = ('--architecture', 'x64') if platform.machine().lower() in ('arm64', 'aarch64') else ()
        packages = [('Microsoft.OpenSSH.Preview', (*architecture, '--override', 'ADDLOCAL=Client /qn /norestart')),
                    ('Yubico.PIVTool', architecture), ('Yubico.YubiKeyManagerCLI', ()), ('GitHub.cli', ()), ('Git.Git', ())]
        for name, extra in packages:
            # winget reports an already-installed/current package as a nonzero result.
            installed = subprocess.run(['winget', 'list', '--id', name, '--exact', '--source', 'winget',
                                        '--accept-source-agreements'], stdout=subprocess.DEVNULL)
            if installed.returncode == 0:
                continue
            run('winget', 'install', '--id', name, '--exact', '--source', 'winget', '--silent',
                '--accept-source-agreements', '--accept-package-agreements', *extra)
        # Refresh this process after installers update the persistent PATH.
        import winreg
        paths = []
        for hive, key in ((winreg.HKEY_LOCAL_MACHINE, r'SYSTEM\CurrentControlSet\Control\Session Manager\Environment'),
                          (winreg.HKEY_CURRENT_USER, 'Environment')):
            with winreg.OpenKey(hive, key) as handle:
                try:
                    paths.append(os.path.expandvars(winreg.QueryValueEx(handle, 'Path')[0]))
                except FileNotFoundError:
                    pass
        os.environ['PATH'] = os.pathsep.join(paths + [os.environ.get('PATH', '')])
    else:
        raise RuntimeError('Automatic installation targets macOS/Windows. Install OpenSSH, libykcs11 and yubico-piv-tool with your package manager.')
    tools = find_tools()
    print('Tools installed. SSH client:', tools['ssh'])
    print('Provider:', tools['provider'])
    return tools


def read_public(tools):
    # This capability check also rejects Windows clients without working PKCS#11 support.
    output = run(tools['keygen'], '-D', tools['provider'], capture=True)
    candidates = [line for line in output.splitlines() if line.endswith('Public key for PIV Authentication')]
    if len(candidates) != 1:
        raise RuntimeError('Expected exactly one PIV Authentication (9a) key. Check the connected YubiKey in Authenticator.')
    fields = public_fields(candidates[0])
    return ' '.join(fields) + ' archways404 PIV 9a\n'


def managed_config(original, provider):
    normalized = str(provider).replace('\\', '/')
    if any(c in normalized for c in ('\n', '\r', '"')):
        raise ValueError('Unsupported provider path.')
    block = f'''{BEGIN}
Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_sk_yubikey_work
    IdentitiesOnly yes
    IdentityAgent none

Host github-personal
    HostName github.com
    User git

Host * !github-work
    PKCS11Provider "{normalized}"
    IdentityFile ~/.ssh/{IDENTITY}
    IdentitiesOnly yes
    IdentityAgent none
{END}'''
    if BEGIN in original or END in original:
        if original.count(BEGIN) != 1 or original.count(END) != 1:
            raise ValueError('Malformed managed SSH block; inspect ~/.ssh/config.')
        start, stop = original.index(BEGIN), original.index(END) + len(END)
        if stop <= start:
            raise ValueError('Malformed managed SSH block.')
        return original[:start] + block + original[stop:]
    lines = original.splitlines(keepends=True)
    index = next((i for i, line in enumerate(lines) if line.strip().lower() == 'host *'), len(lines))
    before = ''.join(lines[:index])
    if before and not before.endswith('\n'):
        before += '\n'
    return before + block + '\n\n' + ''.join(lines[index:])


def configure(tools, home=None):
    directory = (Path(home) if home else Path.home()) / '.ssh'
    public = read_public(tools)
    expected = REPO / 'config/ssh/yubikey-piv-9a.pub'
    if expected.exists() and public_fields(expected.read_text()) != public_fields(public):
        raise RuntimeError('Connected PIV key differs from the public key saved in dotfiles. No settings changed.')
    local = directory / IDENTITY
    if local.exists() and public_fields(local.read_text()) != public_fields(public):
        raise RuntimeError('Saved local PIV public key differs. No settings changed.')
    config = directory / 'config'
    original = config.read_text() if config.exists() else ''
    updated = managed_config(original, tools['provider'])
    # Close the temporary file before OpenSSH opens it (required on Windows).
    with tempfile.TemporaryDirectory() as temporary:
        proposed = Path(temporary) / 'config'
        proposed.write_text(updated)
        for host in ('github-personal', 'github-work', 'orb'):
            run(tools['ssh'], '-G', '-F', proposed, host,
                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    directory.mkdir(mode=0o700, exist_ok=True)
    local.write_text(public)
    local.chmod(0o644)
    if updated != original:
        backup = directory / ('config.backup-piv-' + datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f'))
        if config.exists():
            shutil.copy2(config, backup)
            print('SSH config backup:', backup)
        config.write_text(updated)
        config.chmod(0o600)
    print('Configured PIV personal/default identity:', fingerprint(public))
    print('Work alias retains its separate FIDO2 identity. Test login using the menu.')


def export_public(tools, destination):
    public = read_public(tools)
    certificate = run(tools['piv'], '-a', 'read-certificate', '-s', '9a', capture=True)
    if '-----BEGIN CERTIFICATE-----' not in certificate:
        raise RuntimeError('Provider did not return a public X.509 certificate.')
    destination = Path(destination).expanduser()
    files = {'archways404-ssh.pub': public, 'archways404-piv-certificate.pem': certificate,
             'README.txt': 'PUBLIC FILES ONLY — no private key, PIN or management key.\n\n'
             'SSH fingerprint: ' + fingerprint(public) + '\n\n'
             'GitHub: Settings > SSH and GPG keys > New SSH key > Authentication key.\n'
             'Paste the complete single line from archways404-ssh.pub.\n'
             'Server: add that same line to the intended user account authorized_keys.\n'
             'A server GUI must accept OpenSSH public keys, not require a private key.\n'
             'The PEM file is a public X.509 certificate, not the SSH public-key format.\n'
             'This personal key cannot also be registered on your other GitHub account.\n'}
    for name, content in files.items():
        path = destination / name
        if path.exists() and path.read_text() != content:
            raise RuntimeError(f'Refusing to overwrite different export: {path}. Choose an empty folder.')
    destination.mkdir(parents=True, exist_ok=True)
    for name, content in files.items():
        (destination / name).write_text(content)
    print('Exported public files to:', destination)
    print('SSH fingerprint:', fingerprint(public))
    return public


def copy_public(tools, signing=False):
    public = read_public(tools)
    if platform.system() == 'Darwin':
        command = ['pbcopy']
    elif platform.system() == 'Windows':
        command = ['clip.exe']
    else:
        raise RuntimeError('Use Export public files, then copy the .pub line from the file.')
    subprocess.run(command, input=public, text=True, check=True)
    print('Public SSH key copied. Paste into GitHub Settings > SSH and GPG keys > New SSH key.')
    print('Key type:', 'Signing key' if signing else 'Authentication key')


def select_git_client(tools):
    if not shutil.which('git'):
        raise RuntimeError('Install Git first, then select this option again.')
    directory = Path.home() / '.ssh'
    directory.mkdir(mode=0o700, exist_ok=True)
    backup = directory / 'dotfiles-git-ssh-backup.json'
    previous = subprocess.run(['git', 'config', '--global', '--get-all', 'core.sshCommand'],
                              text=True, stdout=subprocess.PIPE)
    if previous.returncode not in (0, 1):
        raise RuntimeError('Unable to read Git SSH configuration.')
    if not backup.exists():
        backup.write_text(json.dumps(previous.stdout.splitlines()))
    command = '"' + tools['ssh'].replace('\\', '/') + '"'
    run('git', 'config', '--global', '--replace-all', 'core.sshCommand', command)
    print('Git now uses:', command)
    print('Existing HTTPS remote URLs are unchanged. GIT_SSH_COMMAND/repo-local settings can override this.')


SIGNING_SETTINGS = ('gpg.format', 'user.signingkey', 'gpg.ssh.program', 'commit.gpgsign',
                    'gpg.ssh.allowedSignersFile')


def enable_signing(tools):
    if not shutil.which('git'):
        raise RuntimeError('Install Git before enabling commit signing.')
    directory = Path.home() / '.ssh'
    public = directory / IDENTITY
    if not public.exists():
        raise RuntimeError('Apply the PIV SSH default first.')
    if public_fields(public.read_text()) != public_fields(read_public(tools)):
        raise RuntimeError('Connected PIV key does not match the saved signing public key.')
    backup = directory / 'dotfiles-signing-backup.json'
    if not backup.exists():
        previous = {}
        for key in SIGNING_SETTINGS:
            result = subprocess.run(['git', 'config', '--global', '--get-all', key],
                                    text=True, stdout=subprocess.PIPE)
            if result.returncode not in (0, 1):
                raise RuntimeError('Unable to read Git signing settings.')
            previous[key] = result.stdout.splitlines()
        backup.write_text(json.dumps(previous, indent=2))
    installed = directory / 'dotfiles-signing'
    installed.mkdir(mode=0o700, exist_ok=True)
    shutil.copyfile(REPO / 'scripts/yubikey_signing.py', installed / 'yubikey_signing.py')
    metadata = directory / 'dotfiles-signing.json'
    metadata.write_text(json.dumps({'ssh': tools['ssh'], 'provider': tools['provider'],
                                   'public': str(public)}, indent=2))
    metadata.chmod(0o600)
    if platform.system() == 'Windows':
        wrapper = installed / 'sign.cmd'
        wrapper.write_text('@echo off\n"' + sys.executable + '" "' + str(installed / 'yubikey_signing.py') + '" %*\n')
    else:
        import shlex
        wrapper = installed / 'sign'
        wrapper.write_text('#!/bin/sh\nexec ' + shlex.quote(sys.executable) + ' ' +
                           shlex.quote(str(installed / 'yubikey_signing.py')) + ' "$@"\n')
        wrapper.chmod(0o700)
    signers = directory / 'dotfiles-allowed-signers'
    signers.write_text('* ' + ' '.join(public_fields(public.read_text())) + '\n')
    values = {'gpg.format': 'ssh', 'user.signingkey': public.as_posix(),
              'gpg.ssh.program': wrapper.as_posix(), 'commit.gpgsign': 'true',
              'gpg.ssh.allowedSignersFile': signers.as_posix()}
    for key, value in values.items():
        run('git', 'config', '--global', '--replace-all', key, value)
    print('Automatic SSH commit signing enabled for Git and GitHub Desktop (global settings backed up).')
    print('Run Unlock commit signing before committing, including after restarting the agent/computer.')
    print('Register this public key on GitHub AGAIN as a Signing key; use a verified commit email.')
    print('Your author name/email were not changed. Repository-local Git settings can override these defaults.')


def unlock_signing():
    installed = Path.home() / '.ssh/dotfiles-signing/yubikey_signing.py'
    if not installed.exists():
        raise RuntimeError('Choose Enable automatic commit signing first.')
    if platform.system() == 'Windows':
        print('Windows may request administrator approval to start the local SSH agent service (not an SSH server).')
        command = "Set-Service ssh-agent -StartupType Manual; Start-Service ssh-agent"
        run('powershell.exe', '-NoProfile', '-Command',
            "$p = Start-Process powershell.exe -Verb RunAs -Wait -PassThru -ArgumentList "
            "'-NoProfile -Command \"" + command + "\"'; exit $p.ExitCode")
    run(sys.executable, installed, 'unlock')


def test_signing():
    if not shutil.which('git'):
        raise RuntimeError('Git is required.')
    # An isolated repository proves signing without changing the user's projects/history.
    with tempfile.TemporaryDirectory(prefix='dotfiles-signing-test-') as temporary:
        run('git', 'init', '--quiet', temporary)
        run('git', '-C', temporary, '-c', 'user.name=Dotfiles signing test',
            '-c', 'user.email=ssh-test@example.invalid', 'commit', '--quiet', '--allow-empty',
            '-S', '-m', 'Verify YubiKey SSH signing')
        run('git', '-C', temporary, 'verify-commit', 'HEAD')
    print('Signed and verified a temporary commit. Your project history was not modified.')


def restore():
    directory = Path.home() / '.ssh'
    config = directory / 'config'
    if config.exists():
        text = config.read_text()
        if BEGIN in text or END in text:
            if text.count(BEGIN) != 1 or text.count(END) != 1 or text.index(END) < text.index(BEGIN):
                raise RuntimeError('Malformed managed config block; inspect manually.')
            backup = directory / ('config.backup-restore-' + datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f'))
            shutil.copy2(config, backup)
            config.write_text(text[:text.index(BEGIN)] + text[text.index(END) + len(END):])
    backup = directory / 'dotfiles-git-ssh-backup.json'
    if backup.exists():
        previous = json.loads(backup.read_text())
        result = subprocess.run(['git', 'config', '--global', '--unset-all', 'core.sshCommand'])
        if result.returncode not in (0, 5):
            raise RuntimeError('Unable to restore Git SSH configuration.')
        for value in previous:
            run('git', 'config', '--global', '--add', 'core.sshCommand', value)
        backup.unlink()
    signing = directory / 'dotfiles-signing-backup.json'
    if signing.exists():
        for key, values in json.loads(signing.read_text()).items():
            result = subprocess.run(['git', 'config', '--global', '--unset-all', key])
            if result.returncode not in (0, 5):
                raise RuntimeError('Unable to restore Git signing configuration.')
            for value in values:
                run('git', 'config', '--global', '--add', key, value)
        signing.unlink()
    print('Removed the managed SSH default and restored any saved Git client setting. Public files and token keys retained.')


def test_login(tools, host):
    result = subprocess.run([tools['ssh'], '-T', 'git@' + host], text=True)
    print('GitHub normally exits 1 even on success. Confirm the greeting names the expected account.')
    return result.returncode


def recover_work():
    # Existing helper keeps PIN entry local and matches the saved work public key.
    run(sys.executable, REPO / 'scripts/yubikey_ssh.py', 'recover', '--profile', 'work',
        '--public-key', REPO / 'config/ssh/yubikey-work.pub')
    print('Work handle recovered. Reapplying the PIV default next.')


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', nargs='?', default='menu', choices=(
        'menu', 'install', 'setup', 'configure', 'export', 'copy', 'status', 'git-client',
        'test-personal', 'test-work', 'recover-work', 'restore', 'signing', 'unlock-signing', 'test-signing', 'copy-signing', 'install-desktop'))
    parser.add_argument('--provider', type=Path)
    parser.add_argument('--export-dir', type=Path, default=Path.home() / 'Downloads/yubikey-ssh-export')
    args = parser.parse_args(argv)

    def perform(action):
        if action == 'restore':
            return restore()
        if action == 'unlock-signing':
            return unlock_signing()
        if action == 'test-signing':
            return test_signing()
        if action == 'install-desktop':
            if platform.system() == 'Darwin':
                return run('brew', 'install', '--cask', 'github')
            if platform.system() == 'Windows':
                return run('winget', 'install', '--id', 'GitHub.GitHubDesktop', '--exact', '--source',
                           'winget', '--accept-source-agreements', '--accept-package-agreements')
            raise RuntimeError('GitHub Desktop is available for macOS and Windows.')
        if action == 'install':
            return install_tools()
        if action == 'setup':
            install_tools()
        tools = find_tools(args.provider)
        if action in ('setup', 'configure'):
            configure(tools)
            if action == 'setup':
                export_public(tools, args.export_dir)
                select_git_client(tools)
        elif action == 'export':
            export_public(tools, args.export_dir)
        elif action == 'copy':
            copy_public(tools)
            webbrowser.open('https://github.com/settings/ssh/new')
        elif action == 'status':
            print('SSH:', tools['ssh'], '\nProvider:', tools['provider'])
            run(tools['ssh'], '-V')
            run(tools['piv'], '-a', 'status')
            print('PIV 9a SSH fingerprint:', fingerprint(read_public(tools)))
        elif action == 'git-client':
            select_git_client(tools)
        elif action == 'signing':
            enable_signing(tools)
        elif action == 'copy-signing':
            copy_public(tools, signing=True)
            print('Select Signing key (not Authentication key) in GitHub. Use your personal account for this PIV identity.')
            webbrowser.open('https://github.com/settings/ssh/new')
        elif action.startswith('test-'):
            test_login(tools, 'github-' + action[5:])
        elif action == 'recover-work':
            try:
                recover_work()
            finally:
                configure(tools)

    if args.action != 'menu':
        perform(args.action)
        return
    options = [('Set up this computer (install, configure, export)', 'setup'),
               ('Install tools only', 'install'), ('Apply PIV SSH default', 'configure'),
               ('Export public key + certificate for manual import', 'export'),
               ('Copy public SSH key and open GitHub settings', 'copy'),
               ('Test personal GitHub login', 'test-personal'), ('Test work GitHub login', 'test-work'),
               ('Recover resident work key from YubiKey', 'recover-work'),
               ('Select this SSH client for Git', 'git-client'), ('Show device/client status', 'status'),
               ('Enable automatic commit signing (Git + GitHub Desktop)', 'signing'),
               ('Unlock commit signing with PIV PIN', 'unlock-signing'),
               ('Test signing with a temporary commit', 'test-signing'),
               ('Copy public key for GitHub Signing key registration', 'copy-signing'),
               ('Install GitHub Desktop (optional)', 'install-desktop'),
               ('Restore previous SSH/Git settings', 'restore')]
    while True:
        print('\nYubiKey SSH — dotfiles\nUse your existing YubiKey; PINs are entered locally when requested.')
        for i, (label, _) in enumerate(options, 1):
            print(f'  {i}. {label}')
        print('  0. Exit')
        choice = input('Choose: ').strip()
        if choice == '0':
            return
        try:
            index = int(choice) - 1
            if index < 0 or index >= len(options):
                raise ValueError('Select a number from the menu.')
            perform(options[index][1])
        except (OSError, RuntimeError, ValueError, subprocess.CalledProcessError) as error:
            print('Stopped:', error)
            print('If PKCS#11 loading failed, check the OpenSSH version, provider architecture, and that the YubiKey is connected.')


if __name__ == '__main__':
    try:
        main()
    except (OSError, RuntimeError, ValueError, subprocess.CalledProcessError) as error:
        sys.exit(str(error))

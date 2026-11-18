#!/usr/bin/env python3
"""Configure an existing ECCP256 PIV 9a key for SSH. Never generates private keys."""
import argparse
import datetime
from pathlib import Path
import shutil
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--provider', type=Path, required=True,
                        help='Absolute path to Yubico libykcs11 shared library')
    args = parser.parse_args()
    if not args.provider.is_absolute() or not args.provider.is_file():
        parser.error('--provider must point to an installed libykcs11 library')
    provider = str(args.provider)
    if any(c in provider for c in ('\n', '\r', '"')):
        parser.error('Unsupported characters in provider path')
    keygen, ssh = shutil.which('ssh-keygen'), shutil.which('ssh')
    if not keygen or not ssh:
        parser.error('Install an OpenSSH client first')
    output = subprocess.check_output([keygen, '-D', provider], text=True)
    keys = [line for line in output.splitlines()
            if line.startswith('ecdsa-sha2-nistp256 ')
            and line.endswith('Public key for PIV Authentication')]
    if len(keys) != 1:
        parser.error('Expected one ECCP256 PIV Authentication key; no configuration changed')
    public = ' '.join(keys[0].split()[:2]) + ' archways404 PIV 9a\n'
    directory = Path.home() / '.ssh'
    directory.mkdir(mode=0o700, exist_ok=True)
    local = directory / 'yubikey-piv-9a.pub'
    if local.exists() and local.read_text().split()[:2] != public.split()[:2]:
        parser.error('Existing PIV public key differs; inspect before replacing it')
    config = directory / 'config'
    original = config.read_text() if config.exists() else ''
    begin, end = '# BEGIN dotfiles YubiKey SSH', '# END dotfiles YubiKey SSH'
    block = f'''{begin}
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
    PKCS11Provider "{provider}"
    IdentityFile ~/.ssh/yubikey-piv-9a.pub
    IdentitiesOnly yes
    IdentityAgent none
{end}'''
    if begin in original or end in original:
        if original.count(begin) != 1 or original.count(end) != 1:
            parser.error('Malformed managed config block')
        start = original.index(begin)
        stop = original.index(end) + len(end)
        if stop <= start:
            parser.error('Malformed managed config block')
        updated = original[:start] + block + original[stop:]
    else:
        lines = original.splitlines(keepends=True)
        index = next((i for i, line in enumerate(lines)
                      if line.strip().lower() == 'host *'), len(lines))
        before = ''.join(lines[:index])
        if before and not before.endswith('\n'):
            before += '\n'
        updated = before + block + '\n\n' + ''.join(lines[index:])
    with tempfile.NamedTemporaryFile('w', suffix='.ssh-config') as temporary:
        temporary.write(updated)
        temporary.flush()
        for host in ('github-personal', 'github-work', 'orb'):
            subprocess.run([ssh, '-G', '-F', temporary.name, host], check=True,
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    local.write_text(public)
    local.chmod(0o644)
    if updated != original:
        if config.exists():
            backup = directory / ('config.backup-piv-' + datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f'))
            shutil.copy2(config, backup)
            print('SSH config backup:', backup)
        config.write_text(updated)
        config.chmod(0o600)
    subprocess.run([keygen, '-lf', str(local)], check=True)
    print('Configured personal/default PIV SSH identity. Work alias keeps its separate FIDO2 key.')
    print('No keys were generated, and no GitHub or server registrations were changed.')
    print('Test in your own terminal: ssh -T git@github-personal')


if __name__ == '__main__':
    main()

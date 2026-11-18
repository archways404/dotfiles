#!/usr/bin/env python3
"""Git SSH-signing bridge for CLI Git and GitHub Desktop; never stores PINs."""
import json
import os
from pathlib import Path
import platform
import subprocess
import sys


def settings():
    return json.loads((Path.home() / '.ssh/dotfiles-signing.json').read_text())


def agent_environment(config, start=False):
    env = os.environ.copy()
    env['PATH'] = os.pathsep.join((str(Path(config['ssh']).parent), str(Path(config['provider']).parent), env.get('PATH', '')))
    suffix = '.exe' if platform.system() == 'Windows' else ''
    add = Path(config['ssh']).with_name('ssh-add' + suffix)
    if platform.system() == 'Windows':
        env.pop('SSH_AUTH_SOCK', None)  # Use the Windows OpenSSH agent service.
    else:
        socket = Path.home() / '.ssh/dotfiles-signing-agent.sock'
        env['SSH_AUTH_SOCK'] = str(socket)
        status = subprocess.run([str(add), '-l'], env=env, stdout=subprocess.DEVNULL,
                                stderr=subprocess.DEVNULL)
        if status.returncode == 2 and start:
            if socket.is_symlink() or (socket.exists() and not socket.is_socket()):
                raise RuntimeError('Unexpected signing socket path. Inspect ~/.ssh/dotfiles-signing-agent.sock.')
            if socket.exists():
                socket.unlink()
            agent = Path(config['ssh']).with_name('ssh-agent')
            subprocess.run([str(agent), '-a', str(socket), '-P', config['provider']],
                           env=env, check=True, stdout=subprocess.DEVNULL)
    return env, str(add)


def loaded(config, env, add):
    result = subprocess.run([add, '-L'], env=env, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    expected = Path(config['public']).read_text().split()[:2]
    return result.returncode == 0 and any(line.split()[:2] == expected for line in result.stdout.splitlines())


def unlock():
    config = settings()
    env, add = agent_environment(config, start=True)
    if not loaded(config, env, add):
        print('Enter the PIV PIN when ssh-add asks for the provider passphrase. It is not saved.', flush=True)
        subprocess.run([add, '-s', config['provider']], env=env, check=True)
    if not loaded(config, env, add):
        raise RuntimeError('The expected PIV identity was not loaded into the signing agent.')
    print('Signing identity is available to Git and GitHub Desktop. Keep the YubiKey plugged in.')


def main():
    if sys.argv[1:] == ['unlock']:
        return unlock()
    config = settings()
    env, add = agent_environment(config)
    signing = '-Y' in sys.argv and sys.argv[sys.argv.index('-Y') + 1:][:1] == ['sign']
    if signing and not loaded(config, env, add):
        raise RuntimeError('YubiKey signing is locked. Open the dotfiles SSH menu and choose Unlock commit signing, then retry the commit.')
    keygen = str(Path(config['ssh']).with_name('ssh-keygen.exe' if platform.system() == 'Windows' else 'ssh-keygen'))
    # Inherit stdin/stdout unchanged: Git streams the exact commit payload here.
    raise SystemExit(subprocess.run([keygen, *sys.argv[1:]], env=env).returncode)


if __name__ == '__main__':
    try:
        main()
    except (OSError, RuntimeError, ValueError, subprocess.CalledProcessError) as error:
        print(error, file=sys.stderr)
        sys.exit(1)

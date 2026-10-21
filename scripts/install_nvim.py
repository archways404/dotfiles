#!/usr/bin/env python3
"""Install the shared Neovim config; no third-party Python dependencies."""
import argparse
import datetime
import gzip
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.request
import zipfile

REPO = Path(__file__).resolve().parents[1]
MIN_NVIM = (0, 12, 0)


def run(*args):
    print('+ ' + ' '.join(map(str, args)), flush=True)
    subprocess.run(list(map(str, args)), check=True)


def find(command):
    return shutil.which(command)


def refresh_windows_path():
    if os.name == 'nt':
        result = subprocess.check_output(['powershell.exe', '-NoProfile', '-Command',
            "[Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')"], text=True)
        os.environ['PATH'] = result.strip() + ';' + os.environ.get('PATH', '')


def install_dependencies():
    system = platform.system()
    if system == 'Darwin':
        if not find('brew'):
            raise RuntimeError('Install Homebrew from https://brew.sh, then rerun this script.')
        packages = {'git': 'git', 'nvim': 'neovim', 'rg': 'ripgrep', 'fd': 'fd',
                    'node': 'node', 'python3': 'python', 'go': 'go', 'cargo': 'rust',
                    'fzf': 'fzf', 'lazygit': 'lazygit', 'tree-sitter': 'tree-sitter-cli', 'unzip': 'unzip'}
        missing = [package for command, package in packages.items() if not find(command)]
        if missing:
            run('brew', 'install', *missing)
        if not any(find(c) for c in ('cc', 'clang', 'gcc')):
            raise RuntimeError('Install Apple build tools with xcode-select --install, then rerun.')
    elif system == 'Linux':
        if find('apt-get'):
            packages = {'git': 'git', 'rg': 'ripgrep', 'fdfind': 'fd-find', 'node': 'nodejs',
                        'npm': 'npm', 'python3': 'python3', 'go': 'golang-go', 'cargo': 'cargo',
                        'cc': 'build-essential', 'c++': 'g++', 'unzip': 'unzip', 'curl': 'curl', 'fzf': 'fzf', 'tar': 'tar', 'xclip': 'xclip'}
            command = ['apt-get', 'install', '-y']
        elif find('dnf'):
            packages = {'git': 'git', 'rg': 'ripgrep', 'fd': 'fd-find', 'node': 'nodejs',
                        'npm': 'npm', 'python3': 'python3', 'go': 'golang', 'cargo': 'cargo',
                        'cc': 'gcc', 'c++': 'gcc-c++', 'unzip': 'unzip', 'curl': 'curl', 'fzf': 'fzf', 'tar': 'tar', 'xclip': 'xclip'}
            command = ['dnf', 'install', '-y']
        elif find('pacman'):
            packages = {'git': 'git', 'rg': 'ripgrep', 'fd': 'fd', 'node': 'nodejs',
                        'npm': 'npm', 'python3': 'python', 'go': 'go', 'cargo': 'rust',
                        'cc': 'base-devel', 'c++': 'base-devel', 'unzip': 'unzip', 'curl': 'curl', 'fzf': 'fzf', 'tar': 'tar', 'xclip': 'xclip'}
            command = ['pacman', '-S', '--needed', '--noconfirm']
        else:
            raise RuntimeError('Supported Linux package managers: apt-get, dnf, pacman. Install dependencies manually and use --skip-deps on other distributions.')
        missing = sorted(set(package for cmd, package in packages.items() if not find(cmd) and not (cmd == 'fdfind' and find('fd'))))
        sudo = [] if os.geteuid() == 0 else ['sudo']
        if missing:
            if command[0] == 'apt-get':
                run(*sudo, 'apt-get', 'update')
            run(*sudo, *command, *missing)
        # Wayland clipboard integration, where applicable.
        if os.environ.get('WAYLAND_DISPLAY') and not find('wl-copy'):
            run(*sudo, *command, 'wl-clipboard')
    elif system == 'Windows':
        if not find('winget'):
            raise RuntimeError('Install Microsoft App Installer (winget), then rerun.')
        packages = {'git': 'Git.Git', 'nvim': 'Neovim.Neovim', 'rg': 'BurntSushi.ripgrep.MSVC',
                    'fd': 'sharkdp.fd', 'node': 'OpenJS.NodeJS.LTS', 'go': 'GoLang.Go',
                    'cargo': 'Rustlang.Rustup', 'clang': 'MartinStorsjo.LLVM-MinGW.UCRT', 'fzf': 'junegunn.fzf', 'lazygit': 'JesseDuffield.lazygit'}
        for cmd, package in packages.items():
            if not find(cmd):
                run('winget', 'install', '--id', package, '--exact', '--source', 'winget',
                    '--accept-package-agreements', '--accept-source-agreements')
                refresh_windows_path()
    else:
        raise RuntimeError('Supported platforms: macOS, Linux, Windows.')


def nvim_version(binary):
    import re
    result = subprocess.check_output([str(binary), '--version'], text=True)
    match = re.search(r'NVIM v(\d+)\.(\d+)\.(\d+)', result)
    return tuple(map(int, match.groups())) if match else (0, 0, 0)


def linux_neovim():
    """Official stable binary avoids outdated distro Neovim packages."""
    arch = {'x86_64': 'x86_64', 'aarch64': 'arm64', 'arm64': 'arm64'}.get(platform.machine())
    if not arch:
        raise RuntimeError('Install Neovim >= 0.12.0 manually for this CPU architecture.')
    request = urllib.request.Request('https://api.github.com/repos/neovim/neovim/releases/latest',
                                     headers={'User-Agent': 'dotfiles-neovim-installer'})
    with urllib.request.urlopen(request) as response:
        release = json.load(response)
    name = 'nvim-linux-' + arch + '.tar.gz'
    asset = next(item for item in release['assets'] if item['name'] == name)
    digest = asset.get('digest', '')
    if not digest or not digest.startswith('sha256:'):
        raise RuntimeError('Release asset has no SHA-256 digest; install Neovim manually.')
    destination = Path.home() / '.local/share/dotfiles/neovim' / release['tag_name']
    with tempfile.TemporaryDirectory() as tmp:
        archive = Path(tmp) / name
        urllib.request.urlretrieve(asset['browser_download_url'], archive)
        if hashlib.sha256(archive.read_bytes()).hexdigest() != digest.split(':', 1)[1]:
            raise RuntimeError('Neovim download checksum failed.')
        # Validate member and link paths before extracting the official archive.
        with tarfile.open(archive) as tar:
            root = Path(tmp).resolve()
            for member in tar.getmembers():
                target = root / member.name
                targets = [target]
                if member.issym():
                    targets.append(target.parent / member.linkname)
                elif member.islnk():
                    targets.append(root / member.linkname)
                if any(root not in p.resolve().parents for p in targets) or member.isdev() or member.isfifo():
                    raise RuntimeError('Unsafe path in Neovim archive.')
            tar.extractall(tmp)
        source = Path(tmp) / name.removesuffix('.tar.gz')
        destination.parent.mkdir(parents=True, exist_ok=True)
        if destination.exists():
            backup(destination)
        shutil.move(str(source), destination)
    binary = destination / 'bin/nvim'
    link = Path.home() / '.local/bin/nvim'
    link.parent.mkdir(parents=True, exist_ok=True)
    if link.exists() or link.is_symlink():
        backup(link)
    link.symlink_to(binary)
    os.environ['PATH'] = str(link.parent) + os.pathsep + os.environ.get('PATH', '')
    print('Neovim installed at ' + str(link) + '; add ~/.local/bin to your shell PATH if needed.')
    return str(binary)


def ensure_tree_sitter(data):
    binary = find('tree-sitter')
    local = data / 'dotfiles-tools/bin' / ('tree-sitter.exe' if os.name == 'nt' else 'tree-sitter')
    if local.exists():
        binary = str(local)
    if binary:
        import re
        version = subprocess.check_output([binary, '--version'], text=True)
        match = re.search(r'(\d+)\.(\d+)\.(\d+)', version)
        if match and tuple(map(int, match.groups())) >= (0, 26, 1):
            return
    system = {'Darwin': 'macos', 'Linux': 'linux', 'Windows': 'windows'}[platform.system()]
    arch = {'x86_64': 'x64', 'AMD64': 'x64', 'aarch64': 'arm64', 'arm64': 'arm64', 'ARM64': 'arm64'}.get(platform.machine())
    if not arch:
        raise RuntimeError('Install tree-sitter-cli >= 0.26.1 manually for this CPU architecture.')
    request = urllib.request.Request('https://api.github.com/repos/tree-sitter/tree-sitter/releases/latest',
                                     headers={'User-Agent': 'dotfiles-neovim-installer'})
    with urllib.request.urlopen(request) as response:
        release = json.load(response)
    names = ['tree-sitter-cli-' + system + '-' + arch + '.zip', 'tree-sitter-' + system + '-' + arch + '.gz']
    asset = next(item for name in names for item in release['assets'] if item['name'] == name)
    digest = asset.get('digest', '')
    if not digest or not digest.startswith('sha256:'):
        raise RuntimeError('Tree-sitter release asset has no SHA-256 digest.')
    with tempfile.TemporaryDirectory() as tmp:
        archive = Path(tmp) / asset['name']
        urllib.request.urlretrieve(asset['browser_download_url'], archive)
        if hashlib.sha256(archive.read_bytes()).hexdigest() != digest.split(':', 1)[1]:
            raise RuntimeError('Tree-sitter download checksum failed.')
        if archive.suffix == '.zip':
            with zipfile.ZipFile(archive) as zipped:
                name = next(n for n in zipped.namelist() if Path(n).name in ('tree-sitter', 'tree-sitter.exe'))
                content = zipped.read(name)
        else:
            with gzip.open(archive, 'rb') as compressed:
                content = compressed.read()
        local.parent.mkdir(parents=True, exist_ok=True)
        local.write_bytes(content)
        local.chmod(0o755)
    print('Installed tree-sitter-cli: ' + str(local))


def backup(path):
    stamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
    target = path.with_name(path.name + '.backup-' + stamp)
    path.rename(target)
    print('Backup: ' + str(target))
    return target


def deploy(source, destination, copy=False):
    source, destination = Path(source).resolve(), Path(destination)
    if not source.is_dir() or not (source / 'init.lua').is_file():
        raise RuntimeError('Source Neovim configuration is missing: ' + str(source))
    if destination.resolve() == source and not copy:
        print('Already linked: ' + str(destination))
        return
    destination.parent.mkdir(parents=True, exist_ok=True)
    # Prepare everything before touching the existing config.
    old = None
    with tempfile.TemporaryDirectory(prefix='.nvim-install-', dir=destination.parent) as tmp:
        staged = Path(tmp) / 'nvim'
        linked = False
        if not copy:
            try:
                staged.symlink_to(source, target_is_directory=True)
                linked = True
            except OSError:
                pass
        if not linked:
            shutil.copytree(source, staged, ignore=shutil.ignore_patterns('__pycache__', '*.pyc'))
        if destination.exists() or destination.is_symlink():
            old = backup(destination)
        try:
            staged.rename(destination)
        except OSError:
            if old is not None and not destination.exists() and not destination.is_symlink():
                old.rename(destination)
            raise
    if linked:
        print('Linked: ' + str(destination) + ' -> ' + str(source))
    else:
        print('Copied: ' + str(destination) + ' (rerun installer after pulling dotfiles updates)')


def nvim_path(binary, kind):
    return Path(subprocess.check_output([str(binary), '--headless', '-u', 'NONE', '-i', 'NONE',
        '--cmd', 'lua io.write(vim.fn.stdpath("' + kind + '"))', '+qa'], text=True).strip())


def main():
    if sys.version_info < (3, 9):
        raise RuntimeError('Python 3.9+ is required.')
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--keyboard', choices=['us', 'se'], help='Save keyboard layout for this machine; omitted preserves existing choice')
    parser.add_argument('--skip-deps', action='store_true', help='Do not install system tools')
    parser.add_argument('--no-sync', action='store_true', help='Install plugins on first launch instead')
    parser.add_argument('--copy', action='store_true', help='Copy config instead of linking it')
    args = parser.parse_args()
    if not args.skip_deps:
        install_dependencies()
    binary = find('nvim')
    if not binary or nvim_version(binary) < MIN_NVIM:
        if platform.system() == 'Linux' and not args.skip_deps:
            binary = linux_neovim()
        elif platform.system() == 'Darwin' and not args.skip_deps:
            run('brew', 'upgrade', 'neovim')
            binary = find('nvim')
        elif platform.system() == 'Windows' and not args.skip_deps:
            run('winget', 'upgrade', '--id', 'Neovim.Neovim', '--exact', '--accept-source-agreements')
            refresh_windows_path()
            binary = find('nvim')
    if not binary or nvim_version(binary) < MIN_NVIM:
        raise RuntimeError('Neovim >= 0.12.0 is required; install/upgrade it and rerun.')
    for command in ('git',):
        if not find(command):
            raise RuntimeError(command + ' is required. Install it and rerun.')
    config = nvim_path(binary, 'config')
    state = nvim_path(binary, 'state')
    data = nvim_path(binary, 'data')
    if not args.skip_deps:
        ensure_tree_sitter(data)
    deploy(REPO / 'nvim', config, args.copy)
    if args.keyboard:
        state.mkdir(parents=True, exist_ok=True)
        (state / 'dotfiles-keyboard.json').write_text(json.dumps({'layout': args.keyboard}) + '\n', encoding='utf-8')
    if not args.no_sync:
        run(binary, '--headless', '+Lazy! restore', '+qa')
    print('\nReady. Start nvim, then :Overview and :LazyHealth. Mason installs language tools on first use.')
    print('Optional external services (Claude Code) need their own installation/sign-in. Use a Nerd Font in your terminal.')


if __name__ == '__main__':
    try:
        main()
    except (RuntimeError, subprocess.CalledProcessError, OSError, ValueError, StopIteration) as error:
        print('Setup stopped: ' + str(error), file=sys.stderr)
        sys.exit(1)

#!/usr/bin/env python3
"""Full macOS / Windows setup. Launch install-macos.command or install-windows.cmd."""
import argparse
import ctypes
import hashlib
import json
import os
from pathlib import Path
import plistlib
import shutil
import subprocess
import sys
import tempfile
import urllib.request
import uuid
import zipfile

import install_nvim as core

REPO = Path(__file__).resolve().parents[1]
FONT = 'JetBrainsMono Nerd Font'
MAC_TOOLS = ['starship', 'zoxide', 'mise', 'fastfetch', 'zsh-completions', 'zsh-autosuggestions', 'zsh-syntax-highlighting']
WINDOWS_TOOLS = {'Starship.Starship': 'starship', 'ajeetdsouza.zoxide': 'zoxide', 'AutoHotkey.AutoHotkey': None}
TERMINAL_GUID = '{' + str(uuid.uuid5(uuid.NAMESPACE_URL, 'https://github.com/archways404/dotfiles/powershell')) + '}'


def backup_copy(path):
    if path.exists():
        import datetime
        stamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
        copy = path.with_name(path.name + '.backup-' + stamp)
        shutil.copy2(path, copy)
        print('Backup: ' + str(copy))


def write_if_changed(path, content):
    path = Path(path)
    if path.exists() and path.read_text(encoding='utf-8-sig') == content:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    backup_copy(path)
    temporary = path.with_name(path.name + '.dotfiles-tmp')
    temporary.write_text(content, encoding='utf-8')
    temporary.replace(path)


def detect_keyboard(system):
    try:
        if system == 'Darwin':
            prefs = Path.home() / 'Library/Preferences/com.apple.HIToolbox.plist'
            with prefs.open('rb') as file:
                data = plistlib.load(file)
            for source in data.get('AppleSelectedInputSources', []):
                name = source.get('KeyboardLayout Name', '').lower()
                if 'swedish' in name or source.get('KeyboardLayout ID') == 7:
                    return 'se'
        elif system == 'Windows':
            text = subprocess.check_output(['powershell.exe', '-NoProfile', '-Command',
                'Add-Type -AssemblyName System.Windows.Forms; [Console]::Write([System.Windows.Forms.InputLanguage]::CurrentInputLanguage.Culture.Name)'], text=True)
            if text.strip().lower().startswith('sv'):
                return 'se'
    except (OSError, ValueError, subprocess.CalledProcessError):
        pass
    return 'us'


def install_mac_apps(skip_font=False, skip_remap=False):
    installed = subprocess.check_output(['brew', 'list', '--formula', '-1'], text=True).splitlines()
    missing = [tool for tool in MAC_TOOLS if tool not in installed]
    if missing:
        core.run('brew', 'install', *missing)
    apps = []
    if not Path('/Applications/Ghostty.app').exists() and not (Path.home() / 'Applications/Ghostty.app').exists():
        apps.append('ghostty')
    if not skip_remap and not Path('/Applications/Karabiner-Elements.app').exists():
        apps.append('karabiner-elements')
    if not skip_font:
        casks = subprocess.check_output(['brew', 'list', '--cask', '-1'], text=True).splitlines()
        if 'font-jetbrains-mono-nerd-font' not in casks:
            apps.append('font-jetbrains-mono-nerd-font')
    if apps:
        core.run('brew', 'install', '--cask', *apps)


def find_ahk():
    found = core.find('AutoHotkey64.exe') or core.find('AutoHotkey.exe')
    if found:
        return Path(found)
    for folder in [os.environ.get('ProgramFiles', ''), os.environ.get('ProgramFiles(x86)', ''), str(Path(os.environ.get('LOCALAPPDATA', '.')) / 'Programs')]:
        for filename in ('AutoHotkey64.exe', 'AutoHotkey32.exe'):
            candidate = Path(folder) / 'AutoHotkey/v2' / filename
            if candidate.is_file():
                return candidate


def winget_install(identifier, extra=()):
    core.run('winget', 'install', '--id', identifier, '--exact', '--source', 'winget', '--silent',
             '--accept-package-agreements', '--accept-source-agreements', '--disable-interactivity', *extra)
    core.refresh_windows_path()


def install_windows_apps(skip_remap=False):
    if not core.find('wt.exe'):
        winget_install('Microsoft.WindowsTerminal')
    # MSVC and the Windows SDK are needed by Rust and native parser builds.
    vswhere = Path(os.environ.get('ProgramFiles(x86)', 'C:/Program Files (x86)')) / 'Microsoft Visual Studio/Installer/vswhere.exe'
    msvc = ''
    if vswhere.exists():
        msvc = subprocess.check_output([str(vswhere), '-latest', '-products', '*', '-requires',
            'Microsoft.VisualStudio.Component.VC.Tools.x86.x64', '-property', 'installationPath'], text=True).strip()
    if not msvc:
        winget_install('Microsoft.VisualStudio.2022.BuildTools', ('--override',
            '--wait --passive --norestart --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended'))
    for identifier, command in WINDOWS_TOOLS.items():
        if identifier == 'AutoHotkey.AutoHotkey':
            if not skip_remap and not find_ahk():
                winget_install(identifier)
        elif not core.find(command):
            winget_install(identifier)


def download_release(repository, asset_name, destination):
    request = urllib.request.Request('https://api.github.com/repos/' + repository + '/releases/latest',
                                     headers={'User-Agent': 'dotfiles-setup'})
    with urllib.request.urlopen(request, timeout=60) as response:
        release = json.load(response)
    asset = next(item for item in release['assets'] if item['name'] == asset_name)
    digest = asset.get('digest', '')
    if not digest.startswith('sha256:'):
        raise RuntimeError('No SHA-256 release digest for ' + asset_name)
    urllib.request.urlretrieve(asset['browser_download_url'], destination)
    if hashlib.sha256(Path(destination).read_bytes()).hexdigest() != digest.split(':', 1)[1]:
        raise RuntimeError('Checksum mismatch: ' + asset_name)


def install_windows_font():
    import winreg
    directory = Path(os.environ['LOCALAPPDATA']) / 'Microsoft/Windows/Fonts'
    directory.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as temporary:
        if not (directory / 'JetBrainsMonoNerdFont-Regular.ttf').exists():
            archive = Path(temporary) / 'JetBrainsMono.zip'
            download_release('ryanoasis/nerd-fonts', archive.name, archive)
            with zipfile.ZipFile(archive) as fonts:
                selected = [name for name in fonts.namelist() if Path(name).name.startswith('JetBrainsMonoNerdFont-') and name.endswith('.ttf')]
                if not selected:
                    raise RuntimeError('JetBrainsMono font files missing from release archive.')
                for name in selected:
                    (directory / Path(name).name).write_bytes(fonts.read(name))
        with winreg.CreateKey(winreg.HKEY_CURRENT_USER, r'Software\Microsoft\Windows NT\CurrentVersion\Fonts') as registry:
            for destination in directory.glob('JetBrainsMonoNerdFont-*.ttf'):
                winreg.SetValueEx(registry, destination.stem + ' (TrueType)', 0, winreg.REG_SZ, str(destination))
                ctypes.windll.gdi32.AddFontResourceExW(str(destination), 0, 0)
    result = ctypes.c_ulong()
    ctypes.windll.user32.SendMessageTimeoutW(0xFFFF, 0x001D, 0, 0, 0x0002, 1000, ctypes.byref(result))


def parse_jsonc(text):
    """Read Terminal settings without confusing comments with URLs inside strings."""
    out, index, quoted, escaped = [], 0, False, False
    while index < len(text):
        char = text[index]
        if quoted:
            out.append(char)
            if escaped:
                escaped = False
            elif char == '\\':
                escaped = True
            elif char == '"':
                quoted = False
        elif char == '"':
            quoted = True
            out.append(char)
        elif text[index:index + 2] == '//':
            newline = text.find('\n', index)
            index = len(text) if newline < 0 else newline
            continue
        elif text[index:index + 2] == '/*':
            end = text.find('*/', index + 2)
            if end < 0:
                raise ValueError('Unterminated comment in Windows Terminal settings')
            out.append(' ')
            index = end + 2
            continue
        else:
            out.append(char)
        index += 1
    # Remove trailing commas only outside strings.
    clean, quoted, escaped = [], False, False
    text = ''.join(out)
    for index, char in enumerate(text):
        if not quoted and char == ',':
            next_index = index + 1
            while next_index < len(text) and text[next_index].isspace():
                next_index += 1
            if next_index < len(text) and text[next_index] in '}]':
                continue
        clean.append(char)
        if quoted:
            if escaped: escaped = False
            elif char == '\\': escaped = True
            elif char == '"': quoted = False
        elif char == '"': quoted = True
    return json.loads(''.join(clean))


def terminal_settings_path(local):
    packages = local / 'Packages'
    matches = sorted(packages.glob('Microsoft.WindowsTerminal_*/LocalState/settings.json'))
    if matches:
        return matches[0]
    unpackaged = local / 'Microsoft/Windows Terminal/settings.json'
    if unpackaged.exists():
        return unpackaged
    # Standard Microsoft Store / winget stable package family.
    return packages / 'Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json'


def load_ghostty_theme(path):
    theme = {'palette': {}}
    for raw in Path(path).read_text().splitlines():
        line = raw.strip()
        if not line or line.startswith('#') or '=' not in line:
            continue
        key, value = map(str.strip, line.split('=', 1))
        if key == 'palette':
            number, color = value.split('=', 1)
            theme['palette'][int(number)] = color.strip()
        else:
            theme[key] = value
    if len(theme['palette']) != 16:
        raise ValueError('Theme must define all 16 terminal colors')
    return theme


def merge_terminal(settings, profile_path):
    settings = json.loads(json.dumps(settings))
    profiles = settings.setdefault('profiles', {})
    if isinstance(profiles, list):
        profiles = settings['profiles'] = {'list': profiles, 'defaults': {}}
    defaults = profiles.setdefault('defaults', {})
    defaults.setdefault('font', {}).update({'face': FONT, 'size': 10})
    defaults.update({'opacity': 65, 'useAcrylic': True, 'colorScheme': 'Dotfiles', 'padding': '12, 10, 12, 10'})
    command = 'powershell.exe -NoLogo -NoExit -ExecutionPolicy RemoteSigned -Command ". ' + "'" + str(profile_path).replace("'", "''") + "'\""
    profile = {'guid': TERMINAL_GUID, 'name': 'Dotfiles PowerShell', 'commandline': command, 'startingDirectory': '%USERPROFILE%'}
    entries = profiles.setdefault('list', [])
    entries[:] = [entry for entry in entries if entry.get('guid', '').lower() != TERMINAL_GUID.lower()]
    entries.append(profile)
    settings['defaultProfile'] = TERMINAL_GUID
    theme = load_ghostty_theme(REPO / 'osxconfig/ghostty/themes/cobalt2-default')
    scheme = {'name': 'Dotfiles', 'background': theme['background'], 'foreground': theme['foreground'],
              'cursorColor': theme['cursor-color'], 'selectionBackground': theme['selection-background']}
    names = ['black', 'red', 'green', 'yellow', 'blue', 'purple', 'cyan', 'white', 'brightBlack', 'brightRed', 'brightGreen', 'brightYellow', 'brightBlue', 'brightPurple', 'brightCyan', 'brightWhite']
    scheme.update({name: theme['palette'][index] for index, name in enumerate(names)})
    schemes = settings.setdefault('schemes', [])
    schemes[:] = [item for item in schemes if item.get('name') != 'Dotfiles']
    schemes.append(scheme)
    # Preserve unrelated user shortcuts; replace only the two requested bindings.
    bindings = settings.setdefault('keybindings', [])
    bindings[:] = [item for item in bindings if str(item.get('keys', '')).lower() not in ('ctrl+c', 'ctrl+v')]
    actions = settings.setdefault('actions', [])
    actions[:] = [item for item in actions if item.get('id') not in ('Dotfiles.Copy', 'Dotfiles.Paste')
                  and str(item.get('keys', '')).lower() not in ('ctrl+c', 'ctrl+v')]
    actions.extend([{'id': 'Dotfiles.Copy', 'command': {'action': 'copy', 'singleLine': False}}, {'id': 'Dotfiles.Paste', 'command': 'paste'}])
    bindings.extend([{'id': 'Dotfiles.Copy', 'keys': 'ctrl+c'}, {'id': 'Dotfiles.Paste', 'keys': 'ctrl+v'}])
    return settings


def configure_windows(skip_remap=False, skip_shell=False):
    local = Path(os.environ['LOCALAPPDATA'])
    directory = local / 'dotfiles'
    directory.mkdir(parents=True, exist_ok=True)
    if not skip_shell:
        profile = directory / 'profile.ps1'
        write_if_changed(profile, (REPO / 'windows/profile.ps1').read_text())
        settings_path = terminal_settings_path(local)
        settings = parse_jsonc(settings_path.read_text(encoding='utf-8-sig')) if settings_path.exists() else {}
        write_if_changed(settings_path, json.dumps(merge_terminal(settings, profile), indent=2) + '\n')
    if not skip_remap:
        script = directory / 'caps-navigation.ahk'
        write_if_changed(script, (REPO / 'windows/caps-navigation.ahk').read_text())
        executable = find_ahk()
        if not executable:
            raise RuntimeError('AutoHotkey v2 was not found after installation.')
        startup = Path(os.environ['APPDATA']) / 'Microsoft/Windows/Start Menu/Programs/Startup/dotfiles-caps.cmd'
        write_if_changed(startup, '@echo off\nstart "" "' + str(executable) + '" "' + str(script) + '"\n')
        subprocess.Popen([str(executable), str(script)], creationflags=subprocess.CREATE_NEW_PROCESS_GROUP)


def configure_mac(skip_shell=False, skip_remap=False):
    if not skip_shell:
        core.run('bash', REPO / 'osxconfig/install.sh', *( ['--skip-caps'] if skip_remap else [] ))
    elif not skip_remap:
        core.run(sys.executable, REPO / 'scripts/install_caps.py')
    if not skip_remap:
        core.run('open', '-a', 'Karabiner-Elements')


def bootstrap_neovim(binary):
    core.run(binary, '--headless', '+Lazy! restore', '+qa')
    # Environment avoids embedding a path with quotes/spaces in an Ex command.
    env = dict(os.environ, DOTFILES_BOOTSTRAP=str(REPO / 'scripts/bootstrap_nvim.lua'))
    subprocess.run([binary, '--headless', '-i', 'NONE', '+lua dofile(vim.env.DOTFILES_BOOTSTRAP)'], check=True, env=env)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--keyboard', choices=['us', 'se'])
    for option in ['skip-deps', 'no-sync', 'skip-font', 'skip-remap', 'skip-shell', 'copy', 'dry-run']:
        parser.add_argument('--' + option, action='store_true')
    args = parser.parse_args(argv)
    system = core.platform.system()
    if system not in ('Darwin', 'Windows'):
        raise RuntimeError('Full setup supports macOS and Windows. Linux: use install-nvim.sh.')
    if args.dry_run:
        print(json.dumps({'platform': system, 'keyboard': args.keyboard or 'preserve-or-detect',
            'steps': ['package manager/Python bootstrap in launcher', 'core editor tools and language runtimes',
                      'terminal and Nerd Font', 'backed-up Neovim deployment', 'shell shortcuts',
                      'Caps remapper', 'locked plugins', 'language servers/formatters', 'syntax parsers'],
            'manual': ['OS administrator prompts', 'macOS Karabiner permissions', 'optional external service sign-ins']}, indent=2))
        return
    if not args.skip_deps:
        if system == 'Darwin': install_mac_apps(args.skip_font, args.skip_remap)
        else: install_windows_apps(args.skip_remap)
    command = [sys.executable, str(REPO / 'scripts/install_nvim.py'), '--no-sync']
    if args.keyboard: command += ['--keyboard', args.keyboard]
    if args.skip_deps: command.append('--skip-deps')
    if args.copy: command.append('--copy')
    core.run(*command)
    core.refresh_windows_path()
    binary = core.find('nvim')
    if not binary: raise RuntimeError('Neovim is not available on PATH after installation.')
    state = core.nvim_path(binary, 'state')
    if not args.keyboard and not (state / 'dotfiles-keyboard.json').exists():
        state.mkdir(parents=True, exist_ok=True)
        (state / 'dotfiles-keyboard.json').write_text(json.dumps({'layout': detect_keyboard(system)}) + '\n')
    for directory in ('REPO', 'Downloads'):
        (Path.home() / directory).mkdir(exist_ok=True)
    if system == 'Darwin': configure_mac(args.skip_shell, args.skip_remap)
    else:
        if not args.skip_font: install_windows_font()
        configure_windows(args.skip_remap, args.skip_shell)
    if not args.no_sync: bootstrap_neovim(binary)
    print('\nSetup complete. Open a NEW terminal, run nvim, then :Overview.')
    if system == 'Darwin' and not args.skip_remap:
        print('Finish Karabiner Setup permissions if prompted; this part requires macOS approval.')
    print('Admin/UAC prompts and optional Claude/service sign-ins require your interaction.')


if __name__ == '__main__':
    try:
        main()
    except (RuntimeError, OSError, ValueError, StopIteration, subprocess.CalledProcessError) as error:
        print('Setup stopped: ' + str(error), file=sys.stderr)
        sys.exit(1)

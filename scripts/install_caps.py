#!/usr/bin/env python3
"""Add the scoped Caps navigation rule to the selected Karabiner profile."""
import datetime
import json
from pathlib import Path
import shutil
import sys


def install(repo, config_root=None):
    if sys.platform != 'darwin' and config_root is None:
        raise RuntimeError('This installer is for macOS Karabiner-Elements.')
    root = Path(config_root) if config_root else Path.home() / '.config/karabiner'
    asset = Path(repo) / 'osxconfig/karabiner/caps-navigation.json'
    rule = json.loads(asset.read_text())['rules'][0]
    root.mkdir(parents=True, exist_ok=True)
    config_path = root / 'karabiner.json'
    if config_path.exists():
        config = json.loads(config_path.read_text())
    else:
        config = {'profiles': [{'name': 'Default profile', 'selected': True, 'complex_modifications': {'rules': []}}]}
    profiles = config.setdefault('profiles', [])
    if not profiles:
        profiles.append({'name': 'Default profile', 'selected': True})
    profile = next((p for p in profiles if p.get('selected')), profiles[0])
    rules = profile.setdefault('complex_modifications', {}).setdefault('rules', [])
    rules[:] = [r for r in rules if r.get('description') != rule['description']]
    rules.insert(0, rule)
    if config_path.exists():
        timestamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
        backup = config_path.with_name('karabiner.json.backup-' + timestamp)
        shutil.copy2(config_path, backup)
        print('Backup: ' + str(backup))
    temporary = root / 'karabiner.json.tmp'
    temporary.write_text(json.dumps(config, indent=2) + '\n')
    temporary.replace(config_path)
    assets = root / 'assets/complex_modifications'
    assets.mkdir(parents=True, exist_ok=True)
    shutil.copy2(asset, assets / asset.name)
    print('Installed Caps navigation in profile: ' + profile.get('name', 'unnamed'))
    print('Finish Karabiner Setup permissions before the shortcuts can work.')


if __name__ == '__main__':
    install(Path(__file__).resolve().parents[1])

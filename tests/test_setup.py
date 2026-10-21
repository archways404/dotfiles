import importlib.util
import json
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

SCRIPTS = Path(__file__).resolve().parents[1] / 'scripts'
sys.path.insert(0, str(SCRIPTS))
spec = importlib.util.spec_from_file_location('full_setup', SCRIPTS / 'setup.py')
setup = importlib.util.module_from_spec(spec)
spec.loader.exec_module(setup)
spec = importlib.util.spec_from_file_location('caps_setup', SCRIPTS / 'install_caps.py')
caps = importlib.util.module_from_spec(spec)
spec.loader.exec_module(caps)


class SettingsTests(unittest.TestCase):
    def test_jsonc_preserves_strings_and_removes_comments_and_trailing_commas(self):
        text = r'''{
          // a comment
          "url": "https://example.test/a/*literal*/", /* another comment */
          "quoted": "a\\b\"c", "list": [1, 2,],
        }'''
        value = setup.parse_jsonc(text)
        self.assertEqual(value['url'], 'https://example.test/a/*literal*/')
        self.assertEqual(value['quoted'], 'a\\b"c')
        self.assertEqual(value['list'], [1, 2])

    def test_invalid_jsonc_does_not_silently_replace_settings(self):
        with self.assertRaises(ValueError):
            setup.parse_jsonc('{/* broken')

    def test_terminal_merge_preserves_user_settings_and_is_idempotent(self):
        original = {'custom': True, 'profiles': {'list': [{'guid': '{personal}', 'name': 'Linux'}]},
                    'actions': [{'command': 'newTab', 'keys': 'ctrl+t'}],
                    'keybindings': [{'id': 'User.Help', 'keys': 'f1'}],
                    'schemes': [{'name': 'personal', 'background': '#111111'}]}
        profile = Path("C:/Users/Example Name's/profile.ps1")
        changed = setup.merge_terminal(original, profile)
        self.assertEqual(changed, setup.merge_terminal(changed, profile))
        self.assertTrue(changed['custom'])
        self.assertEqual(changed['profiles']['list'][0]['guid'], '{personal}')
        self.assertEqual(changed['profiles']['defaults']['font']['face'], setup.FONT)
        self.assertIn({'command': 'newTab', 'keys': 'ctrl+t'}, changed['actions'])
        self.assertEqual(changed['schemes'][-1]['background'], '#122738')
        self.assertEqual(changed['schemes'][-1]['green'], '#3ad900')
        self.assertIn("Name''s", changed['profiles']['list'][-1]['commandline'])
        self.assertEqual(original['profiles']['list'], [{'guid': '{personal}', 'name': 'Linux'}])

    def test_terminal_legacy_profile_array_is_preserved(self):
        changed = setup.merge_terminal({'profiles': [{'guid': '{old}', 'name': 'old'}]}, Path('profile.ps1'))
        self.assertEqual(changed['profiles']['list'][0]['guid'], '{old}')

    def test_theme_is_exact_supplied_palette(self):
        theme = setup.load_ghostty_theme(setup.REPO / 'osxconfig/ghostty/themes/cobalt2-default')
        self.assertEqual(theme['background'], '#122738')
        self.assertEqual(theme['foreground'], '#ffffff')
        self.assertEqual(len(theme['palette']), 16)

    def test_write_only_backs_up_when_content_changes(self):
        with tempfile.TemporaryDirectory() as folder:
            target = Path(folder) / 'settings.json'
            setup.write_if_changed(target, 'one')
            setup.write_if_changed(target, 'one')
            self.assertEqual(list(Path(folder).glob('*.backup-*')), [])
            setup.write_if_changed(target, 'two')
            self.assertEqual(len(list(Path(folder).glob('*.backup-*'))), 1)

    def test_windows_config_with_spaces_and_quoted_path(self):
        with tempfile.TemporaryDirectory() as folder, patch.dict(os.environ, {'LOCALAPPDATA': folder}):
            setup.configure_windows(skip_remap=True)
            target = setup.terminal_settings_path(Path(folder))
            value = json.loads(target.read_text())
            self.assertEqual(value['defaultProfile'], setup.TERMINAL_GUID)
            self.assertTrue((Path(folder) / 'dotfiles/profile.ps1').exists())
            setup.configure_windows(skip_remap=True)
            self.assertEqual(list(target.parent.glob('*.backup-*')), [])

    def test_dry_run_never_executes_installers(self):
        for system in ('Darwin', 'Windows'):
            with patch.object(setup.core.platform, 'system', return_value=system), patch.object(setup.core, 'run') as run:
                setup.main(['--dry-run'])
                run.assert_not_called()


class CapsTests(unittest.TestCase):
    def test_rule_merge_preserves_other_profiles_and_remains_unique(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            value = {'profiles': [{'name': 'other', 'selected': False, 'complex_modifications': {'rules': []}},
                        {'name': 'active', 'selected': True, 'simple_modifications': [{'custom': True}],
                         'complex_modifications': {'rules': [{'description': 'personal'}]}}]}
            (root / 'karabiner.json').write_text(json.dumps(value))
            caps.install(setup.REPO, root)
            caps.install(setup.REPO, root)
            changed = json.loads((root / 'karabiner.json').read_text())
            self.assertEqual(changed['profiles'][0], value['profiles'][0])
            self.assertEqual(changed['profiles'][1]['simple_modifications'], [{'custom': True}])
            self.assertEqual(len(changed['profiles'][1]['complex_modifications']['rules']), 2)
            self.assertEqual(len(list(root.glob('*.backup-*'))), 2)


if __name__ == '__main__':
    unittest.main()

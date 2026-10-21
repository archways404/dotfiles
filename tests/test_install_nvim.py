import importlib.util
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('installer', Path(__file__).resolve().parents[1] / 'scripts/install_nvim.py')
installer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(installer)


class DeploymentTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.source = self.root / 'repo with spaces/nvim'
        self.source.mkdir(parents=True)
        (self.source / 'init.lua').write_text('-- shared config')
        self.destination = self.root / 'config/nvim'

    def test_existing_directory_backed_up_then_linked(self):
        self.destination.mkdir(parents=True)
        (self.destination / 'old.lua').write_text('-- personal config')
        installer.deploy(self.source, self.destination)
        self.assertEqual(self.destination.resolve(), self.source.resolve())
        backups = list(self.destination.parent.glob('nvim.backup-*'))
        self.assertEqual(len(backups), 1)
        self.assertEqual((backups[0] / 'old.lua').read_text(), '-- personal config')

    def test_rerun_does_not_backup_correct_symlink(self):
        installer.deploy(self.source, self.destination)
        installer.deploy(self.source, self.destination)
        self.assertEqual(list(self.destination.parent.glob('nvim.backup-*')), [])

    def test_copy_fallback_without_symlink_permission(self):
        with patch.object(Path, 'symlink_to', side_effect=OSError('Windows privilege unavailable')):
            installer.deploy(self.source, self.destination)
        self.assertFalse(self.destination.is_symlink())
        self.assertEqual((self.destination / 'init.lua').read_text(), '-- shared config')

    def test_broken_old_symlink_is_backed_up(self):
        self.destination.parent.mkdir()
        self.destination.symlink_to(self.root / 'missing')
        installer.deploy(self.source, self.destination)
        self.assertTrue(list(self.destination.parent.glob('nvim.backup-*'))[0].is_symlink())
        self.assertEqual(self.destination.resolve(), self.source.resolve())

    def test_copy_update_preserves_old_config(self):
        installer.deploy(self.source, self.destination, copy=True)
        (self.source / 'init.lua').write_text('-- updated')
        installer.deploy(self.source, self.destination, copy=True)
        old = next(self.destination.parent.glob('nvim.backup-*'))
        self.assertEqual((old / 'init.lua').read_text(), '-- shared config')
        self.assertEqual((self.destination / 'init.lua').read_text(), '-- updated')

    def test_failed_copy_leaves_existing_config_untouched(self):
        self.destination.mkdir(parents=True)
        (self.destination / 'old.lua').write_text('-- keep me')
        with patch.object(installer.shutil, 'copytree', side_effect=OSError('disk full')):
            with self.assertRaises(OSError):
                installer.deploy(self.source, self.destination, copy=True)
        self.assertEqual((self.destination / 'old.lua').read_text(), '-- keep me')
        self.assertEqual(list(self.destination.parent.glob('nvim.backup-*')), [])

    def test_version_parsing(self):
        with patch.object(installer.subprocess, 'check_output', return_value='NVIM v0.12.0\nRelease'):
            self.assertEqual(installer.nvim_version('nvim'), (0, 12, 0))
        with patch.object(installer.subprocess, 'check_output', return_value='NVIM v0.10.4'):
            self.assertLess(installer.nvim_version('nvim'), installer.MIN_NVIM)


if __name__ == '__main__':
    unittest.main()

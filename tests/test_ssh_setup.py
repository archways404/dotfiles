import importlib.util
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

SCRIPTS = Path(__file__).resolve().parents[1] / 'scripts'
spec = importlib.util.spec_from_file_location('ssh_setup', SCRIPTS / 'ssh_setup.py')
setup = importlib.util.module_from_spec(spec)
spec.loader.exec_module(setup)
PUBLIC = (Path(__file__).resolve().parents[1] / 'config/ssh/yubikey-piv-9a.pub').read_text()


class ConfigTests(unittest.TestCase):
    def test_leading_include_and_host_overrides_survive(self):
        original = 'Include ~/.orbstack/ssh/config\nHost special\n    IdentityAgent /tmp/special\nHost *\n    IdentityAgent /tmp/old\n'
        updated = setup.managed_config(original, '/opt/homebrew/lib/libykcs11.dylib')
        self.assertTrue(updated.startswith('Include ~/.orbstack/ssh/config\nHost special'))
        self.assertLess(updated.index('Host special'), updated.index(setup.BEGIN))
        self.assertLess(updated.index(setup.END), updated.index('IdentityAgent /tmp/old'))
        self.assertEqual(updated, setup.managed_config(updated, '/opt/homebrew/lib/libykcs11.dylib'))

    def test_windows_provider_is_quoted_and_uses_forward_slashes(self):
        updated = setup.managed_config('', r'C:\Program Files\Yubico\bin\libykcs11.dll')
        self.assertIn('PKCS11Provider "C:/Program Files/Yubico/bin/libykcs11.dll"', updated)

    def test_malformed_managed_block_does_not_get_replaced(self):
        for text in (setup.BEGIN, setup.END, setup.END + setup.BEGIN, setup.BEGIN * 2 + setup.END):
            with self.subTest(text=text), self.assertRaises(ValueError):
                setup.managed_config(text, '/provider')

    def test_rejects_provider_config_injection(self):
        with self.assertRaises(ValueError):
            setup.managed_config('', '/provider\nProxyCommand malicious')

    def test_invalid_public_encoding_is_rejected(self):
        for value in ('PRIVATE KEY', 'ssh-rsa !bad!', 'ssh-rsa AAAA'):
            with self.subTest(value=value), self.assertRaises(ValueError):
                setup.public_fields(value)

    def test_public_fingerprint_is_stable_with_comments(self):
        self.assertEqual(setup.fingerprint(PUBLIC), setup.fingerprint(' '.join(PUBLIC.split()[:2])))


class FilesTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / 'repo'
        self.repo.mkdir()
        self.home = self.root / 'home'
        self.home.mkdir()
        self.tools = {'ssh': shutil.which('ssh') or 'ssh', 'provider': '/provider',
                      'keygen': 'ssh-keygen', 'piv': 'yubico-piv-tool'}
        self.real_read_public = setup.read_public
        self.patches = [patch.object(setup, 'REPO', self.repo), patch.object(setup, 'read_public', return_value=PUBLIC)]
        for item in self.patches:
            item.start()
            self.addCleanup(item.stop)

    @unittest.skipUnless(shutil.which('ssh'), 'OpenSSH required')
    def test_configure_preserves_backup_and_is_idempotent(self):
        sshdir = self.home / '.ssh'
        sshdir.mkdir()
        original = 'Host *\n    ServerAliveInterval 17\n'
        (sshdir / 'config').write_text(original)
        setup.configure(self.tools, self.home)
        backups = list(sshdir.glob('config.backup-*'))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), original)
        setup.configure(self.tools, self.home)
        self.assertEqual(list(sshdir.glob('config.backup-*')), backups)

    def test_different_connected_key_cannot_replace_saved_identity(self):
        sshdir = self.home / '.ssh'
        sshdir.mkdir()
        (sshdir / 'config').write_text('Host *\n    Port 2222\n')
        (sshdir / setup.IDENTITY).write_text('not a valid key')
        with self.assertRaises(ValueError):
            setup.configure(self.tools, self.home)
        self.assertEqual((sshdir / 'config').read_text(), 'Host *\n    Port 2222\n')

    def test_export_contains_public_files_only_and_rejects_overwrite(self):
        destination = self.root / 'exports'
        certificate = '-----BEGIN CERTIFICATE-----\nPUBLIC\n-----END CERTIFICATE-----\n'
        with patch.object(setup, 'run', return_value=certificate):
            setup.export_public(self.tools, destination)
            self.assertEqual({p.name for p in destination.iterdir()},
                             {'archways404-ssh.pub', 'archways404-piv-certificate.pem', 'README.txt'})
            self.assertEqual((destination / 'archways404-ssh.pub').read_text(), PUBLIC)
            (destination / 'archways404-ssh.pub').write_text('different key')
            with self.assertRaises(RuntimeError):
                setup.export_public(self.tools, destination)

    def test_pkcs11_export_excludes_attestation_identity(self):
        output = PUBLIC.strip() + ' Public key for PIV Authentication\n' + PUBLIC.strip() + ' Public key for PIV Attestation\n'
        # Provider comments are intentionally matched; do not choose the first arbitrary key.
        with patch.object(setup, 'run', return_value=output):
            self.assertEqual(setup.public_fields(self.real_read_public(self.tools)), setup.public_fields(PUBLIC))


@unittest.skipUnless(shutil.which('git') and shutil.which('ssh-keygen') and shutil.which('ssh-agent')
                     , 'Git/OpenSSH integration test')
class SigningIntegrationTests(unittest.TestCase):
    def test_desktop_style_commit_signs_without_a_terminal_and_restore_keeps_previous_settings(self):
        # Only a disposable SOFTWARE key and isolated agent are used; never accesses a YubiKey.
        if os.name == 'nt' and not os.environ.get('GITHUB_ACTIONS'):
            self.skipTest('Windows signing-agent service test runs only on isolated GitHub runners.')
        with tempfile.TemporaryDirectory(dir='/tmp' if os.name != 'nt' else None) as temporary:
            root = Path(temporary)
            home = root / 'home with spaces'
            (home / '.ssh').mkdir(parents=True)
            repo = root / 'repo'
            (repo / 'scripts').mkdir(parents=True)
            shutil.copyfile(SCRIPTS / 'yubikey_signing.py', repo / 'scripts/yubikey_signing.py')
            key = root / 'software-test-key'
            subprocess.run(['ssh-keygen', '-q', '-t', 'ecdsa', '-b', '256', '-N', '', '-f', str(key)], check=True)
            public = key.with_suffix('.pub').read_text()
            (home / '.ssh' / setup.IDENTITY).write_text(public)
            socket = home / '.ssh/dotfiles-signing-agent.sock'
            agent_env = os.environ.copy()
            if os.name == 'nt':
                agent_env.pop('SSH_AUTH_SOCK', None)
                subprocess.run(['powershell.exe', '-NoProfile', '-Command', 'Set-Service ssh-agent -StartupType Manual; Start-Service ssh-agent'], check=True)
            else:
                agent_env['SSH_AUTH_SOCK'] = str(socket)
                output = subprocess.check_output(['ssh-agent', '-a', str(socket)], text=True)
                pid = next(line.split('=')[1].split(';')[0] for line in output.splitlines() if line.startswith('SSH_AGENT_PID='))
                agent_env['SSH_AGENT_PID'] = pid
            try:
                subprocess.run(['ssh-add', str(key)], env=agent_env, check=True, stderr=subprocess.DEVNULL)
                env = {'HOME': str(home), 'USERPROFILE': str(home), 'GIT_CONFIG_GLOBAL': str(root / 'gitconfig'),
                       'GIT_CONFIG_NOSYSTEM': '1'}
                with patch.dict(os.environ, env), patch.object(Path, 'home', return_value=home), \
                     patch.object(setup, 'REPO', repo), patch.object(setup, 'read_public', return_value=public):
                    subprocess.run(['git', 'config', '--global', 'gpg.format', 'openpgp'], check=True)
                    tools = {'ssh': shutil.which('ssh'), 'provider': '/not-used-by-software-test'}
                    setup.enable_signing(tools)
                    project = root / 'project'
                    subprocess.run(['git', 'init', '-q', str(project)], check=True)
                    commit = subprocess.run(['git', '-C', str(project), '-c', 'user.name=Signing test',
                                             '-c', 'user.email=test@example.invalid', 'commit', '--allow-empty', '-qm', 'Signing bridge test'],
                                            input='', text=True, capture_output=True)
                    self.assertEqual(commit.returncode, 0, commit.stderr)
                    verify = subprocess.run(['git', '-C', str(project), 'verify-commit', 'HEAD'], capture_output=True, text=True)
                    self.assertEqual(verify.returncode, 0, verify.stderr)
                    setup.restore()
                    previous = subprocess.check_output(['git', 'config', '--global', 'gpg.format'], text=True).strip()
                    self.assertEqual(previous, 'openpgp')
                    self.assertNotEqual(subprocess.run(['git', 'config', '--global', '--get', 'commit.gpgsign']).returncode, 0)
            finally:
                if os.name == 'nt':
                    subprocess.run(['ssh-add', '-d', str(key)], env=agent_env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                else:
                    subprocess.run(['ssh-agent', '-k'], env=agent_env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


if __name__ == '__main__':
    unittest.main()

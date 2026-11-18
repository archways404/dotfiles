# SSH and commit signing with YubiKey404

Clone or download/extract this dotfiles repository onto a **trusted computer**.
Plug in the same YubiKey. You do not generate a new identity for each computer.

| Platform | Double-click |
| --- | --- |
| macOS | **`ssh-macos.command`** |
| Windows 10/11 | **`ssh-windows.cmd`** |

These are independent of the full editor/terminal installers. The launchers
bootstrap Homebrew or WinGet and Python if missing, then show the SSH menu. Normal
administrator/UAC, Apple Command Line Tools and GitHub authorization prompts need
your interaction. No account passwords or PINs are saved or transcribed.

Choose **Set up this computer** to install Git, OpenSSH, Yubico PIV Tool, YubiKey
Manager CLI and GitHub CLI; apply the existing PIV identity to SSH; select this
OpenSSH client for Git; and export public files. Other menu actions let you run
each operation independently. GitHub Desktop installation is a separate option.
The script neither generates/replaces token keys nor changes PINs/management keys.

The current setup uses an ECCP256 PIV key in slot **9a** for `archways404`, with
**PIN once per session and no touch**, and a separate resident FIDO2 key for
`philipstenberg-TVX`. The public PIV certificate expires **2030-12-01**. Existing
FIDO2 registrations remain available as fallback. PIV and FIDO2 have separate PINs
on this YubiKey 5C NFC.

## First setup on a new machine

1. Launch the menu and choose **Set up this computer**.
2. Choose **Copy public SSH key and open GitHub settings** if the personal key
   has not yet been registered. In the correct GitHub account, choose
   **Authentication key**. Reusing the same YubiKey does not need re-enrollment.
3. Choose **Test personal GitHub login**. Enter your PIV PIN and confirm the
   success greeting names `archways404`. GitHub exits 1 even on successful tests.
4. If using the work account, choose **Recover resident work key**; enter its
   FIDO2 PIN and local-handle passphrase as prompted. The script reapplies the PIV
   personal default afterward. Test the work account separately. If the work
   handle already exists, skip recovery. The earlier FIDO2 signing issue has not
   been resolved by this PIV personal setup.

| SSH host | Credential |
| --- | --- |
| `github-personal` and `github.com` | PIV 9a, personal account |
| `github-work` | Resident FIDO2 work identity |
| Other hosts | PIV 9a unless an earlier host-specific setting overrides it |

Git remotes may use `git@github-personal:archways404/REPO.git` or
`git@github-work:Telavox/REPO.git`. Existing HTTPS remotes stay HTTPS. A GitHub
organization may additionally require SSO authorization. Servers still need the
public key registered on the appropriate account. Verify new host fingerprints
through a trusted source when SSH asks.

Leading Includes and earlier host overrides are preserved, including OrbStack.
The managed default supersedes the earlier generic 1Password SSH agent setting.
The menu can remove that managed block and restore saved global Git settings.
Timestamped config backups allow exact manual restoration. Settings overridden
in a repository or by environment variables remain effective.

## Automatic commit signing: regular Git and GitHub Desktop

1. Choose **Enable automatic commit signing**. This backs up and sets global
   `gpg.format=ssh`, `user.signingkey`, `gpg.ssh.program`, `commit.gpgsign=true`,
   and a local allowed-signers file. Author name/email are not changed.
2. Choose **Copy public key for GitHub Signing key registration**. Register the
   PIV public key AGAIN on your personal account, this time selecting
   **Signing key**. Authentication-key enrollment alone does not enable GitHub
   signature verification. Use a commit email verified on that account.
3. Choose **Unlock commit signing**. When `ssh-add` requests the provider
   passphrase, enter the **PIV PIN**. The PIN is not saved. Windows may request UAC
   approval to start its SSH agent service; no SSH server is enabled.
4. Choose **Test signing with a temporary commit**. It signs and verifies an
   isolated commit without modifying your project history.
5. Commit normally from Git or GitHub Desktop. Restart Desktop if it was already
   open when settings changed.

The signing bridge is installed under `~/.ssh/dotfiles-signing/` with absolute
client/Python paths, so GUI apps do not depend on your interactive shell PATH or
an exported `SSH_AUTH_SOCK`. macOS uses a dedicated local signing agent; Windows
uses the OpenSSH agent service. Unlock again after agent/computer restarts or if
the token identity is no longer available. The key must remain plugged in when
signing. A locked/unavailable key fails the commit rather than silently signing
with another key or committing unsigned. GUI commits do **not** pop up a PIN
dialog: unlock in the SSH menu before committing.

These defaults select the **personal PIV signing identity**. They do not create
a separate work signing key or change your work author identity. Repository-local
signing settings can override the global defaults. Register and configure a
separate work signing identity before expecting work-account Verified badges.
The local allowed-signers file trusts signatures by this public key for any local
author principal; GitHub independently checks its own registered key/email trust.

## Export for manual GUI import

Choose **Export public key + certificate**. Default location:

```text
~/Downloads/yubikey-ssh-export/
  archways404-ssh.pub
  archways404-piv-certificate.pem
  README.txt
```

- **GitHub/server SSH key field:** paste the entire single line from the `.pub`
  file, beginning `ecdsa-sha2-nistp256`. The copy menu can put it on the clipboard.
- **Server GUI:** choose an OpenSSH public-key import or paste that line into the
  intended account's authorized keys. Never supply a private key to the server.
- **X.509 certificate field:** the `.pem` is a public certificate. It is not the
  format GitHub's SSH-key field expects and is not an SSH CA user certificate.

The export includes its fingerprint and instructions. It contains no private key,
PIN, PUK or management key. Export refuses to overwrite different existing files;
choose another directory with `--export-dir` when exporting a different identity.

## Command-line usage

```sh
# macOS launchers can also run one action instead of opening the menu:
bash ssh-macos.command setup
bash ssh-macos.command export --export-dir "$HOME/Desktop/SSH-public-files"

# With Python already available (Windows: py -3 instead of python3):
python3 scripts/ssh_setup.py
python3 scripts/ssh_setup.py configure
python3 scripts/ssh_setup.py signing
python3 scripts/ssh_setup.py unlock-signing
python3 scripts/ssh_setup.py test-signing
python3 scripts/ssh_setup.py restore
```

Windows examples: `ssh-windows.cmd setup` or
`ssh-windows.cmd export --export-dir "%USERPROFILE%\Desktop\SSH-public-files"`.
Use `--provider` for a nonstandard absolute path to `libykcs11.dylib`, `.dll`, or
`.so`. The older `scripts/setup_piv_ssh.py --provider ...` entry point remains an
alias for Configure. The older FIDO2 setup/enrollment helpers are retained for
recovery; reapply the PIV default after running their Configure/Create actions.

## Windows compatibility and limits

The Windows installer selects `Microsoft.OpenSSH.Preview` from Microsoft's
WinGet manifests (the upstream Win32-OpenSSH release channel), with **client-only**
MSI features. It installs `Yubico.PIVTool` and puts its DLL directory on the menu
process's PATH for dependency loading. The installed OpenSSH client is preferred
over the Windows inbox client. Runtime export through `ssh-keygen -D` checks actual
PKCS#11 support before changing SSH settings. Unsupported clients, missing keys,
or architecture mismatches stop with an error rather than reporting setup success.
Windows ARM64 uses the x64 OpenSSH/PIV pair where supported by Windows emulation,
because the current PIV package has no native ARM64 build.

Menu tests and the selected Git client use explicit paths. An `ssh` command in an
unrelated existing terminal can still resolve to the older Windows inbox client;
use the client path shown by **Show device/client status** if needed. WSL is a
separate environment and is not provisioned by the native Windows launcher.

macOS public-key export and SSH config parsing were exercised against the real
YubiKey. Unit tests cover preservation, idempotence, export and rollback; a
disposable software-key integration test signs/verifies a commit without a TTY.
Windows CI checks Python behavior and PowerShell parsing. Physical Windows PIV
PIN/login/signing behavior and GitHub Desktop commits require validation on a PC.

References: [Yubico PIV/PKCS#11 SSH](https://developers.yubico.com/PIV/Guides/SSH_with_PIV_and_PKCS11.html),
[YKCS11 Windows DLL setup](https://docs.yubico.com/software/yubikey/tools/pivtool/piv-tool-ykcs11.html),
[Microsoft client-only installer](https://github.com/PowerShell/Win32-OpenSSH/wiki/Install-Win32-OpenSSH-Using-MSI),
[GitHub commit signing](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits).

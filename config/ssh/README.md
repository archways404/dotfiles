# Portable SSH with a YubiKey

## Current setup: PIV personal identity

Personal/default SSH now uses the ECCP256 key generated on YubiKey404 in PIV
slot 9a. Subject: `CN=archways404 ssh`; certificate expiry: **2030-12-01**.
The private key never leaves the YubiKey. Its policies are **PIN once per session**
and **touch never**, as selected by Authenticator's GUI defaults. This is the PIV
PIN, separate from the FIDO2 PIN. There is no local private-key-file passphrase.
Changing PIN/touch policies on an existing PIV key requires replacing that key;
do not generate a replacement in the occupied slot just to change a label or expiry.

- `yubikey-piv-9a.pub`: the personal SSH public key registered on archways404.
- `yubikey-piv-9a.pem`: the public self-signed X.509 certificate, not a private key.
- `yubikey-main.pub` and `yubikey-work.pub`: earlier resident FIDO2 public keys.
  These remain registered. The work GitHub alias still uses its FIDO2 key.

On another Mac, clone dotfiles via HTTPS, install the provider, plug in the same
YubiKey, and configure the existing PIV credential:

```sh
brew install openssh yubico-piv-tool
python3 scripts/setup_piv_ssh.py --provider "$(brew --prefix yubico-piv-tool)/lib/libykcs11.dylib"
ssh -T git@github-personal
```

The helper exports only the PIV Authentication public key, refuses to replace a
different saved public key, backs up SSH config, validates parsing, and installs
these defaults. It generates no private keys and requires no management key.
For Linux, install libykcs11/OpenSSH and supply the installed `.so` path instead.
This helper targets macOS/Linux; Windows needs separate client/provider setup.

| Host | Credential |
| --- | --- |
| `github-personal` or `github.com` | PIV 9a, personal archways404 account |
| `github-work` | Resident FIDO2 work key, philipstenberg-TVX account |
| Other hosts | PIV 9a unless an earlier host-specific setting overrides it |

Earlier Includes/host overrides remain in place, including OrbStack's identity.
GitHub success reports the account name and exits with status 1. Actual PIV
signing/login still requires a successful interactive test; merely registering
the public key does not test signing. Keep existing recovery credentials until
login works. HTTPS Git remotes are unchanged.

Register `yubikey-piv-9a.pub` in each server account's `authorized_keys` to use PIV
there. Do not upload this personal key to the work GitHub account; that account
needs a separate PIV key if it is migrated later. On a new Mac, recover the existing
work FIDO2 handle using the recovery commands below, THEN run the PIV setup helper.
Running the older FIDO2 helper's create/recover/configure commands restores its
FIDO2 defaults, so rerun `setup_piv_ssh.py` afterward to restore the PIV default.
The FIDO2 GitHub enrollment helper below handles only the earlier FIDO2 identities.

To renew the X.509 certificate, create/import a new certificate for the SAME key;
ordinary SSH public-key registration stays the same. Generating a new private key
changes your SSH identity and requires re-enrollment everywhere. A spare YubiKey
needs its own separately authorized key. Never commit PINs, PUKs or management keys.

## Earlier FIDO2 setup and work-account recovery

The main identity is a resident `ed25519-sk` credential generated on the YubiKey,
with PIN verification and touch required. The private key never leaves the token.
`~/.ssh/id_ed25519_sk_yubikey_main` is a local handle, not an exportable private key.
Keep even this handle out of Git. Only `yubikey-main.pub`, configuration and these
instructions belong in this repository. Use this only on computers you trust.

## First setup

On macOS install `brew install openssh ykman`. Ensure Homebrew's bin directory
(`/opt/homebrew/bin` on Apple Silicon, `/usr/local/bin` on Intel) precedes `/usr/bin`
in your shell PATH. Check `command -v ssh ssh-keygen` in a new terminal. Linux needs
OpenSSH with libfido2 support. Native Windows needs a FIDO-capable OpenSSH build;
WSL requires extra USB integration or delegation to the Windows client.

Plug in the intended YubiKey. Check `ykman info` and `ykman fido info`. If a FIDO2
PIN is not set, use `ykman fido access change-pin` interactively. Never put PINs in
commands, Git, or chat. The FIDO2 PIN is separate from the PIV PIN in Authenticator.
Do not reset FIDO2: a reset deletes existing FIDO credentials/passkeys.

Run from this repo in your own terminal (on Windows use `py -3` for `python3`):

```sh
python3 scripts/yubikey_ssh.py create
cp ~/.ssh/id_ed25519_sk_yubikey_main.pub config/ssh/yubikey-main.pub
```

The script refuses to overwrite keys, generates the credential interactively, then
backs up and updates `~/.ssh/config`. A local handle passphrase is optional and is
separate from the FIDO2 PIN. It never reads or records your PIN. Key creation is
deliberately separate from the general dotfiles installer.

The managed `Host *` block makes this the default identity and uses it directly,
without an agent. It is inserted before the first existing generic `Host *` block,
after existing leading Includes and host overrides. On this Mac that preserves
OrbStack's leading Include and its explicit identity. The existing 1Password agent
line stays in the config but is superseded for hosts using the new default. If a
host still needs 1Password, place its `Host hostname` block BEFORE the managed
block, set its `IdentityAgent` socket and `IdentitiesOnly no`, and check `ssh -G hostname`.
To undo, remove the lines between and including `BEGIN/END dotfiles YubiKey SSH`,
or restore the printed config backup. No server settings are changed.

## Authorize and test

Upload the contents of `yubikey-main.pub` as an authentication key at GitHub
Settings → SSH and GPG keys. For each server, add that same public key as one line
in the account's `~/.ssh/authorized_keys`. Retain current access until the new key
has successfully logged in. GitHub organization SSO may need separate authorization.

```sh
ssh-keygen -lf ~/.ssh/id_ed25519_sk_yubikey_main.pub
ssh -G github.com
ssh -T git@github.com
ssh your-user@your-server
```

Verify first-contact host fingerprints with a trusted source. GitHub's successful
SSH test reports authentication success but exits with status 1. Git remotes using
HTTPS continue using HTTPS; switch an individual remote to `git@github.com:OWNER/REPO.git`
when you want SSH. FIDO SSH keys require compatible servers (OpenSSH 8.2+).

## Two GitHub accounts

GitHub does not allow the same authentication key on two accounts. The main key
belongs to `archways404`; a separate resident credential on the same physical
YubiKey belongs to `philipstenberg-TVX`:

```sh
python3 scripts/yubikey_ssh.py create --profile work
cp ~/.ssh/id_ed25519_sk_yubikey_work.pub config/ssh/yubikey-work.pub
```

Register `yubikey-main.pub` on archways404 and `yubikey-work.pub` on
philipstenberg-TVX. You can use the GitHub web settings, or (with `gh` signed in
to both accounts) run:

```sh
python3 scripts/enroll_yubikey_github.py
```

The enrollment helper switches to each named account, confirms its identity,
requests the `write:public_key` OAuth scope through GitHub's normal browser flow
if needed, uploads only the matching public key, verifies enrollment, then restores
the previously active CLI account. The scope permits listing and creating SSH
public keys. Check the account name before approving each browser authorization.
It skips an already-enrolled key and never uploads local key handles.

 When the work handle exists, the helper configures these routes:

| SSH hostname | Identity |
| --- | --- |
| `github.com` or `github-personal` | Personal/main key |
| `github-work` | Work key, connecting to github.com |
| Other hosts | Main key unless overridden earlier |

Use `git@github-work:Telavox/REPO.git` for work-account repositories and
`git@github-personal:archways404/REPO.git` for personal repositories. Test with
`ssh -T git@github-work` and `ssh -T git@github-personal`. The work alias excludes
the main key so a missing work enrollment cannot silently authenticate as personal.
Existing HTTPS remotes are unchanged.

See [GitHub key uniqueness](https://docs.github.com/en/authentication/troubleshooting-ssh/error-key-already-in-use).

## Another computer

Install a compatible client, clone dotfiles via HTTPS, plug in the SAME YubiKey:

```sh
python3 scripts/yubikey_ssh.py recover --public-key config/ssh/yubikey-main.pub
```

For the work account, also run:

```sh
python3 scripts/yubikey_ssh.py recover --profile work --public-key config/ssh/yubikey-work.pub
```

This runs `ssh-keygen -K` in a private temporary directory, matches the saved public
key, restores the handle under the standard name, and configures SSH. The public
key remains the same, so servers need no re-enrollment. If the handle is already
present, use `python3 scripts/yubikey_ssh.py configure`. The physical YubiKey and
its PIN are required; cloning dotfiles alone does not give anyone your SSH access.

Generate an independent key on a spare YubiKey and authorize its public key on
every service as a backup. A key generated on the first YubiKey cannot be cloned
to the spare. Keep a separate recovery route and remove a lost token's public key
from every service. Do not run the main-key create command again for the spare:
use a different filename/application label and keep its public key separately.

## Certificates and other YubiKey uses

FIDO2 SSH does not use the PIV certificate slots shown in Yubico Authenticator.
Those slots pair a private key with an X.509 certificate:

| Slot | Typical purpose |
| --- | --- |
| 9a Authentication | Smart-card login, client authentication such as VPN or mTLS |
| 9c Digital signature | Document or email signing with compatible software |
| 9d Key management | Decryption, for example S/MIME email |
| 9e Card authentication | Card/device authentication, usually without a PIN |

PIV can also provide SSH authentication via PKCS#11, but FIDO2 is simpler for this
setup. Empty PIV certificate slots do not prove that no private keys exist there.
Do not generate/import into a PIV slot without checking for existing keys first.
An employer/CA must issue a certificate trusted by the service for corporate
smart-card/VPN/mTLS use. A self-signed certificate does not create that trust.
Configure the PIV PIN, PUK and management key securely when adopting PIV, storing
recovery values in your password manager. Keep encryption-key recovery in mind
before using a non-exportable PIV key for data you cannot afford to lose.

OpenSSH user certificates are a different format from PIV/X.509 certificates. An
SSH CA can sign your public key for a limited time, and servers trust that CA.
They are useful for centrally managed fleets; they require server-side CA trust.
The CA private key must stay out of dotfiles and should not be the daily login key.
The YubiKey also supports passkeys/2FA; these do not require filling the PIV slots.

References: [Yubico FIDO2 SSH guide](https://developers.yubico.com/SSH/Securing_SSH_with_FIDO2.html),
[PIV certificate slots](https://developers.yubico.com/PIV/Introduction/Certificate_slots.html),
[SSH with PIV](https://developers.yubico.com/PIV/Guides/SSH_with_PIV_and_PKCS11.html).

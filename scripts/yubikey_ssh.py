#!/usr/bin/env python3
"""Create or recover a resident YubiKey SSH identity. Run in your own terminal."""
import argparse
import datetime
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


KEY_NAME = "id_ed25519_sk_yubikey_main"
BEGIN = "# BEGIN dotfiles YubiKey SSH"
END = "# END dotfiles YubiKey SSH"


def binaries():
    if sys.platform == "darwin":
        for prefix in ("/opt/homebrew", "/usr/local"):
            directory = Path(prefix) / "bin"
            if (directory / "ssh-keygen").exists():
                return str(directory / "ssh-keygen"), str(directory / "ssh")
        raise RuntimeError("Install FIDO-capable OpenSSH first: brew install openssh")
    keygen, ssh = shutil.which("ssh-keygen"), shutil.which("ssh")
    if not keygen or not ssh:
        raise RuntimeError("Install an OpenSSH client compiled with FIDO2 support first.")
    return keygen, ssh


def run(*args, **kwargs):
    return subprocess.run(args, check=True, **kwargs)


def public_identity(path):
    fields = path.read_text().split()
    if len(fields) < 2 or fields[0] != "sk-ssh-ed25519@openssh.com":
        raise RuntimeError(f"Expected an ed25519-sk public key: {path}")
    return fields[:2]


def configure(directory, key):
    # Keep leading Includes (including OrbStack) and host-specific settings in place.
    # Insert immediately before the first generic Host * block, or at the end.
    config = directory / "config"
    original = config.read_text() if config.exists() else ""
    lines = original.splitlines(keepends=True)
    starts = [i for i, line in enumerate(lines) if line.strip() == BEGIN]
    ends = [i for i, line in enumerate(lines) if line.strip() == END]
    if starts or ends:
        if len(starts) != 1 or len(ends) != 1 or starts[0] >= ends[0]:
            raise RuntimeError("Malformed managed SSH block; inspect ~/.ssh/config first.")
        stop = ends[0] + 1
        if stop < len(lines) and not lines[stop].strip():
            stop += 1
        del lines[starts[0]:stop]
    index = next((i for i, line in enumerate(lines)
                  if line.strip().lower() == "host *"), len(lines))
    work_name = "id_ed25519_sk_yubikey_work"
    aliases = ""
    if (directory / work_name).exists():
        aliases = ("Host github-work\n    HostName github.com\n    User git\n"
                   f"    IdentityFile ~/.ssh/{work_name}\n"
                   "    IdentitiesOnly yes\n    IdentityAgent none\n\n"
                   "Host github-personal\n    HostName github.com\n    User git\n\n")
    default_hosts = "* !github-work" if aliases else "*"
    block = (f"{BEGIN}\n{aliases}Host {default_hosts}\n"
             f"    IdentityFile ~/.ssh/{KEY_NAME}\n"
             "    IdentitiesOnly yes\n"
             "    IdentityAgent none\n"
             f"{END}\n\n")
    before, after = "".join(lines[:index]), "".join(lines[index:])
    if before and not before.endswith("\n"):
        before += "\n"
    updated = before + block + after
    if updated != original:
        if config.exists():
            stamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S-%f")
            backup = directory / f"config.backup-{stamp}"
            shutil.copy2(config, backup)
            print(f"SSH config backup: {backup}")
        config.write_text(updated)
        if os.name != "nt":
            config.chmod(0o600)
    print("Default SSH identity configured. Existing earlier host settings take priority.")


def main():
    if os.name != "nt":
        os.umask(0o077)
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("create", "recover", "configure"))
    parser.add_argument("--profile", choices=("main", "work"), default="main")
    parser.add_argument("--public-key", type=Path,
                        help="Trusted public key to match during recovery")
    args = parser.parse_args()
    keygen, ssh = binaries()
    directory = Path.home() / ".ssh"
    directory.mkdir(mode=0o700, exist_ok=True)
    name = KEY_NAME if args.profile == "main" else "id_ed25519_sk_yubikey_work"
    account = "archways404" if args.profile == "main" else "philipstenberg-TVX"
    key = directory / name
    public = directory / (name + ".pub")
    if args.action in ("create", "recover"):
        if not sys.stdin.isatty():
            raise RuntimeError("Run in your own terminal so PINs stay local.")
        if key.exists() or public.exists():
            raise RuntimeError(f"Refusing to overwrite {key} or its public key. Use configure if already set up.")
    if args.action == "create":
        print("Use your FIDO2 PIN (separate from the PIV PIN), then touch the YubiKey.", flush=True)
        run(keygen, "-t", "ed25519-sk", "-O", "resident", "-O", "verify-required",
            "-O", f"application=ssh:{account}-{args.profile}", "-O", f"user={account}",
            "-C", f"{account} YubiKey {args.profile}", "-f", str(key))
    elif args.action == "recover":
        # Downloads into a private temporary directory; never overwrites existing handles.
        with tempfile.TemporaryDirectory(prefix="yubikey-ssh-") as temporary:
            run(keygen, "-K", cwd=temporary)
            candidates = list(Path(temporary).glob("*.pub"))
            if args.public_key:
                expected = public_identity(args.public_key)
                candidates = [p for p in candidates if p.read_text().split()[:2] == expected]
            if len(candidates) != 1:
                raise RuntimeError("Expected exactly one resident SSH key. Rerun with --public-key pointing to your saved main .pub file.")
            source = candidates[0]
            public_identity(source)
            handle = source.with_suffix("")
            # Exclusive creation avoids overwriting if another process created the target.
            with key.open("xb") as output:
                output.write(handle.read_bytes())
            with public.open("xb") as output:
                output.write(source.read_bytes())
    if not key.exists() or not public.exists():
        raise RuntimeError(f"Both {key} and {public} must exist before configuration.")
    public_identity(public)
    if os.name != "nt":
        key.chmod(0o600)
        public.chmod(0o644)
    # Parse the current config before modifying it.
    run(ssh, "-G", "github.com", stdout=subprocess.DEVNULL)
    configure(directory, key)
    run(ssh, "-G", "github.com", stdout=subprocess.DEVNULL)
    run(keygen, "-lf", str(public))
    print(f"Public key to register on GitHub/servers: {public}")
    print(f"To save it in dotfiles, copy ONLY that .pub file to config/ssh/yubikey-{args.profile}.pub.")
    print("On macOS, ensure Homebrew bin precedes /usr/bin in PATH for both ssh and Git.")


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, OSError, subprocess.CalledProcessError) as error:
        sys.exit(str(error))

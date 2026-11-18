#!/usr/bin/env python3
"""Register each public YubiKey key on the matching signed-in GitHub account."""
import json
from pathlib import Path
import shutil
import subprocess
import sys


def gh(*args, capture=False):
    return subprocess.run(["gh", *args], check=True, text=True,
                          stdout=subprocess.PIPE if capture else None)


def main():
    if not sys.stdin.isatty():
        sys.exit("Run in your own terminal for GitHub's browser authorization prompts.")
    if not shutil.which("gh"):
        sys.exit("Install GitHub CLI and sign in to both accounts first.")
    pairs = [("archways404", "main"), ("philipstenberg-TVX", "work")]
    keys = []
    for account, profile in pairs:
        path = Path.home() / ".ssh" / f"id_ed25519_sk_yubikey_{profile}.pub"
        fields = path.read_text().split()
        if len(fields) < 2 or fields[0] != "sk-ssh-ed25519@openssh.com":
            sys.exit(f"Expected ed25519-sk public key: {path}")
        keys.append((account, profile, path, " ".join(fields[:2])))
    original = gh("api", "user", "--jq", ".login", capture=True).stdout.strip()
    try:
        for account, profile, path, public in keys:
            gh("auth", "switch", "--hostname", "github.com", "--user", account)
            actual = gh("api", "user", "--jq", ".login", capture=True).stdout.strip()
            if actual != account:
                sys.exit(f"Wrong GitHub account: expected {account}, got {actual}")
            print(f"Registering {profile} public key on {account}.", flush=True)
            result = subprocess.run(["gh", "api", "user/keys"], text=True,
                                    stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
            if result.returncode:
                print("GitHub CLI needs write:public_key permission to add the key. Approve in your browser as the named account.", flush=True)
                gh("auth", "refresh", "--hostname", "github.com", "--scopes", "write:public_key")
                actual = gh("api", "user", "--jq", ".login", capture=True).stdout.strip()
                if actual != account:
                    sys.exit(f"Authorization used the wrong account: {actual}. Stopping before upload.")
            current = json.loads(gh("api", "user/keys", capture=True).stdout)
            if not any(item["key"].split()[:2] == public.split() for item in current):
                gh("ssh-key", "add", str(path), "--type", "authentication",
                   "--title", f"YubiKey 5C NFC — {profile}")
            current = json.loads(gh("api", "user/keys", capture=True).stdout)
            if not any(item["key"].split()[:2] == public.split() for item in current):
                sys.exit(f"Could not verify public-key enrollment for {account}")
            print(f"Verified public key enrollment: {account}", flush=True)
    finally:
        gh("auth", "switch", "--hostname", "github.com", "--user", original)
    print("Both accounts enrolled. Test ssh -T git@github-personal and ssh -T git@github-work; enter your PIN and touch the YubiKey.")


if __name__ == "__main__":
    try:
        main()
    except (OSError, subprocess.CalledProcessError, ValueError) as error:
        sys.exit(str(error))

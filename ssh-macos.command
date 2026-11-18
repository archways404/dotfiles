#!/bin/bash
# Double-click to open the SSH menu. Arguments: setup, export, status, etc.
set -euo pipefail
SSH_SETUP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
finish() {
  ssh_setup_status=$?
  if [ "$ssh_setup_status" -ne 0 ]; then echo "SSH setup stopped (exit $ssh_setup_status)."; fi
  if [ -t 0 ] && [ "${DOTFILES_NO_PAUSE:-0}" != 1 ]; then
    read -r -p 'Press Return to close. ' ssh_setup_reply
  fi
  exit "$ssh_setup_status"
}
trap finish EXIT
if [ "$(uname -s)" != Darwin ]; then echo 'This launcher requires macOS.'; exit 1; fi
for ssh_setup_brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  if [ -x "$ssh_setup_brew" ]; then eval "$("$ssh_setup_brew" shellenv)"; break; fi
done
if ! command -v brew >/dev/null 2>&1; then
  echo 'Installing Homebrew from its official installer. Complete any macOS administrator/Command Line Tools prompts.'
  ssh_setup_download="$(mktemp -t dotfiles-ssh-homebrew)"
  curl --fail --location --silent --show-error https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$ssh_setup_download"
  /bin/bash "$ssh_setup_download"
  rm -f "$ssh_setup_download"
  for ssh_setup_brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$ssh_setup_brew" ]; then eval "$("$ssh_setup_brew" shellenv)"; break; fi
  done
fi
if ! brew list --versions python >/dev/null 2>&1; then brew install python; fi
SSH_SETUP_PYTHON="$(brew --prefix python)/bin/python3"
# Do not tee/transcribe this session: SSH PIN entry remains local and unlogged.
"$SSH_SETUP_PYTHON" "$SSH_SETUP_ROOT/scripts/ssh_setup.py" "$@"

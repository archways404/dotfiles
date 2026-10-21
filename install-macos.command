#!/bin/bash
# Double-click in Finder, or: bash install-macos.command --keyboard se
set -euo pipefail
SETUP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$HOME/Library/Logs/dotfiles"
exec > >(tee -a "$HOME/Library/Logs/dotfiles/install.log") 2>&1
finish() {
  setup_status=$?
  if [ "$setup_status" -ne 0 ]; then
    echo "Installation stopped (exit $setup_status). See ~/Library/Logs/dotfiles/install.log."
  fi
  if [ -t 0 ] && [ "${DOTFILES_NO_PAUSE:-0}" != 1 ]; then
    read -r -p 'Press Return to close this installer. ' _setup_reply
  fi
  exit "$setup_status"
}
trap finish EXIT
if [ "$(uname -s)" != Darwin ]; then echo 'This launcher requires macOS.'; exit 1; fi
for setup_brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  if [ -x "$setup_brew" ]; then eval "$("$setup_brew" shellenv)"; break; fi
done
if ! command -v brew >/dev/null 2>&1; then
  echo 'Installing Homebrew from its official installer. macOS may request your password or Command Line Tools.'
  sudo -v
  setup_download="$(mktemp -t dotfiles-homebrew)"
  curl --fail --location --silent --show-error https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$setup_download"
  NONINTERACTIVE=1 /bin/bash "$setup_download"
  rm -f "$setup_download"
  for setup_brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$setup_brew" ]; then eval "$("$setup_brew" shellenv)"; break; fi
  done
fi
if ! /usr/bin/xcrun --find clang >/dev/null 2>&1; then
  /usr/bin/xcode-select --install || true
  echo 'Complete the Apple Command Line Tools installation prompt; setup will continue automatically.'
  setup_wait=0
  until /usr/bin/xcrun --find clang >/dev/null 2>&1; do
    sleep 5
    setup_wait=$((setup_wait + 5))
    if [ "$setup_wait" -ge 1800 ]; then echo 'Command Line Tools installation timed out. Rerun after it finishes.'; exit 1; fi
  done
fi
# Use a current Homebrew Python, rather than an outdated macOS stub.
if ! brew list --versions python >/dev/null 2>&1; then brew install python; fi
SETUP_PYTHON="$(brew --prefix python)/bin/python3"
"$SETUP_PYTHON" "$SETUP_ROOT/scripts/setup.py" "$@"

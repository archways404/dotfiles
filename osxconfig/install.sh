#!/usr/bin/env bash
# One-time (and safely re-runnable) setup: symlinks the configs in
# this folder to where each tool actually expects them.
#
# Run this LOCALLY in your own Terminal/Ghostty on your Mac:
#   cd ~/REPO/dotfiles/osxconfig
#   chmod +x install.sh
#   ./install.sh
#
# Because these become symlinks, editing the file at either the repo
# path or the real path edits the exact same file — there's nothing
# to "sync" and nothing can drift out of date. Re-running this script
# later (e.g. after adding more files) is safe: it skips anything
# already linked correctly and backs up any real file it would
# otherwise overwrite.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

link() {
  local src="$1" dest="$2"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "✓ already linked: $dest"
    return
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mkdir -p "$(dirname "$BACKUP_DIR/${dest#$HOME/}")"
    mv "$dest" "$BACKUP_DIR/${dest#$HOME/}"
    echo "  backed up existing $dest -> $BACKUP_DIR/${dest#$HOME/}"
  fi
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "-> linked $dest -> $src"
}

link "$DOTFILES/zshrc"          "$HOME/.zshrc"
link "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"

echo "Done. Open a new terminal to pick up changes."

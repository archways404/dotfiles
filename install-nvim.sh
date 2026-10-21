#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if ! command -v python3 >/dev/null 2>&1; then
  for arg in "$@"; do
    if [ "$arg" = "--skip-deps" ]; then
      echo 'Python 3.9+ is required with --skip-deps.' >&2
      exit 1
    fi
  done
  if command -v brew >/dev/null 2>&1; then
    brew install python
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y python3
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y python3
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm python
  else
    echo 'Install Python 3.9+ (and Homebrew on macOS), then rerun.' >&2
    exit 1
  fi
fi
exec python3 "$ROOT/scripts/install_nvim.py" "$@"

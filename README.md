# Dotfiles

## One-launch setup

Clone/download this repository, keep the folder where you want it to live, then:

| Platform | Double-click |
|---|---|
| macOS | **`install-macos.command`** |
| Windows 10/11 | **`install-windows.cmd`** |

These launchers install the package manager/Python if missing, editor tools,
terminal, Nerd Font, shell helpers, key remapper, Neovim config, locked plugins,
language servers, formatters and syntax parsers. Existing settings are backed up.
Repeat the same launcher after pulling updates; no separate config-copy steps.

Normal administrator/UAC prompts still need approval. On macOS, finish
Karabiner's Setup permissions (background services, Accessibility/input capture,
and its driver). Apple Command Line Tools may show an installation prompt. External
accounts such as Claude Code need their own sign-in; the installer does not create
accounts or install optional cloud-service CLIs. Downloads require internet access.

### What gets configured

- **macOS:** Homebrew, Ghostty, Karabiner, JetBrainsMono Nerd Font, the shared zsh
  setup, `repo` / `dl`, and Caps navigation restricted to Ghostty.
- **Windows:** WinGet, Windows Terminal, AutoHotkey v2 with terminal-scoped Caps
  shortcuts and login startup, the Nerd Font, and a dedicated **Dotfiles PowerShell**
  profile with `repo` / `dl`. Existing terminal profiles and unrelated bindings stay
  available. Only this profile uses a process-scoped RemoteSigned execution policy;
  no account/machine execution policy is changed.
- **Both:** Neovim >= 0.12, Git, ripgrep, fd, fzf, Node/npm, Python, Go/Rust and C/C++
  tooling; plugin versions from `nvim/lazy-lock.json`; Mason language tools and
  Treesitter parsers installed before the launcher reports completion.

The supplied **`cobalt2-default`** theme is included verbatim in
`osxconfig/ghostty/themes/`. Ghostty uses it with the existing transparency/blur;
Windows Terminal receives the same palette and acrylic transparency. Neovim keeps
its separate vivid syntax colors and transparent editor background.

Keyboard layout is preserved on existing installs, or detected initially as US or
Swedish. Change it any time with `:KeyboardLayout us` / `:KeyboardLayout se`.

### Command-line options

```sh
# macOS: same full install with an explicit keyboard layout
bash install-macos.command --keyboard se
```

```powershell
# Windows: same full install with an explicit keyboard layout
.\setup-windows.ps1 -Keyboard se
```

For an existing Python environment, `python3 scripts/setup.py --dry-run` prints the
plan without installing anything. The Python setup also supports `--skip-deps`,
`--no-sync`, `--skip-font`, `--skip-remap`, `--skip-shell`, and `--copy`; the Windows
PowerShell launcher exposes matching switches. `--no-sync` leaves plugins/language
tools/parsers for later instead of doing the full bootstrap.

The lower-level `install-nvim.sh` / `install-nvim.ps1` remain available for
**Neovim-only** installs. Linux/WSL can use `bash install-nvim.sh --keyboard us`;
the full terminal/remapper launchers target native macOS and Windows.

### Updates, backups and logs

Neovim and macOS config files are linked to this repo where possible. Windows
falls back to copying when symlinks are unavailable; rerun the launcher after a
pull to refresh copies. Terminal/AutoHotkey files on Windows are managed copies.
Keep the repo in place for linked configs.

Existing Neovim configs receive sibling `.backup-<timestamp>` folders; macOS shell
backups go in `~/.dotfiles-backup/`; Terminal and Karabiner JSON backups remain
beside their settings files. No old plugin caches are deleted. Re-running preserves
unrelated user profiles/rules and doesn't duplicate managed entries.

Logs: macOS `~/Library/Logs/dotfiles/install.log`; Windows
`%LOCALAPPDATA%\dotfiles\install.log`. Failed downloads/tool installs stop with a
nonzero exit and a useful message. Fix the reported OS/network issue and rerun.
The launcher does not claim success while language tools/parsers are still pending.
Project-specific SDKs, licenses, credentials and tool versions remain project setup.

Open a **new terminal**, run `nvim`, then `:Overview` or `Space ?` for actions and
customization. See the [Neovim guide](nvim/README.md) for movement, comments, folds,
clipboard shortcuts and theme settings. `config/nvim/` and `backup/` are older
configurations and are not installed.

Tests: `python3 -m unittest discover -s tests -v`. CI runs the installer tests on
macOS, Windows and Linux, plus PowerShell/shell parsing and an AutoHotkey startup
check. This does not replace testing a complete install on a fresh physical machine.

Sources: [Homebrew](https://docs.brew.sh/Installation),
[WinGet](https://learn.microsoft.com/en-us/windows/package-manager/winget/),
[Karabiner](https://karabiner-elements.pqrs.org/docs/getting-started/installation/).

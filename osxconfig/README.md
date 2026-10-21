# osxconfig

Source-of-truth macOS configs, symlinked (not copied) into place.
Because a symlink IS the file, editing it anywhere — here in the repo,
or at the real path zsh/Ghostty actually reads — changes the same
underlying file instantly. No watcher, no sync step, nothing to go
stale.

| File in this folder | Symlinked to |
|---|---|
| `zshrc` | `~/.zshrc` |
| `ghostty/config` | `~/.config/ghostty/config` |

## First-time setup (or on a new Mac)

```
cd ~/REPO/dotfiles/osxconfig
chmod +x install.sh
./install.sh
```

Safe to re-run any time — it skips files already linked correctly and
backs up anything real it would otherwise overwrite into
`~/.dotfiles-backup/<timestamp>/`.


## Directory and clipboard shortcuts

- `repo` changes to `~/REPO`; `dl` changes to `~/Downloads`.
- `termhelp` lists the terminal tools and directory shortcuts.
- Cmd+C copies terminal selections, or reaches Neovim when it has the selection.
- Cmd+V pastes the system clipboard using terminal bracketed paste.
- Neovim displays an `←↓↑→` movement reminder.

After editing, run `source ~/.zshrc` in an existing shell. Reload Ghostty config
with Cmd+Shift+comma, and restart Neovim for Neovim changes.
The Ghostty config applies its background opacity to explicitly colored cells,
so popup menus, selections and status colors also blend with the terminal.
Left Option acts as Alt; Right Option remains available for Swedish text input.


## Caps Lock navigation (Ghostty)

Hold Caps and press A/D for line beginning/end, W/S for file top/bottom.
The Karabiner rule is restricted to Ghostty, and tapping Caps alone retains its
usual behavior. `install.sh` installs the rule when Karabiner and Python exist;
otherwise run `python3 scripts/install_caps.py` from the dotfiles root later.
The selected profile is merged and backed up, not replaced. Complete Karabiner's
Setup screen permissions before testing the physical shortcuts.

See [Karabiner setup](https://karabiner-elements.pqrs.org/docs/getting-started/installation/)
for required macOS permissions. Normal/Visual navigation in Neovim uses the permanent
P / L Ö Ä cluster (US: P / L ; apostrophe). Select the OS input language and use
`:KeyboardLayout se` / `us` accordingly; no navigation toggle is needed.


## Full installer and supplied theme

For a new Mac use the root `install-macos.command` launcher: it installs the
applications, shell dependencies, font, Neovim and language tools before linking
these files. `osxconfig/install.sh` remains a config-linking helper for existing
machines. It also links the supplied `ghostty/themes/cobalt2-default` file and
sets Ghostty to that exact palette. Reload Ghostty with Cmd+Shift+comma.

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

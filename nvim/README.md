# Portable Neovim setup

Shared LazyVim config for macOS, Linux, Windows and WSL, with US or Swedish keyboards.
The canonical config is `nvim/` in the dotfiles repository. `config/nvim/` and `backup/`
are older configs; the installer does not use them.

## Install after cloning dotfiles

Double-click `install-macos.command` on macOS or `install-windows.cmd` on Windows
from the repo root. The full launcher installs the terminal, font, key remapper,
shell setup, editor, plugins, language tools and parsers. OS permissions/admin
prompts still need approval. See the [main setup guide](../README.md) for full
requirements, logs, backups and options.

For only the Neovim config/dependencies, use `bash install-nvim.sh --keyboard se`
or `.\install-nvim.ps1 -Keyboard se`. Use `us` for a US keyboard. Linux/WSL uses
the Bash Neovim-only installer. First-launch language installation remains enabled
for these lower-level installers; the full launcher waits for it in advance.

The destination follows Neovim's `stdpath("config")` and respects XDG paths and
`NVIM_APPNAME`. Existing configs are backed up, then linked to the repo where
supported or copied on Windows if links are unavailable. Re-run after pulling
updates when using copies. The plugin lockfile keeps shared versions consistent.

## Discover actions and customizations

| Command / keys | Purpose |
|---|---|
| `:Overview` or `Space ?` | One menu for actions, settings, plugins, and this guide |
| `Space` then wait | Available shortcuts grouped by task |
| `Space sk` | Search keybindings and their descriptions |
| `Space sC` | Search editor commands |
| `Space u` then wait | Toggle formatting, wrapping, spelling, diagnostics, etc. |
| `:KeyboardLayout` | Choose the keyboard layout for this machine |
| `:Lazy` | Installed plugins and updates |
| `:LazyExtras` | Enable optional language / feature packs |
| `:Mason` | Language servers, linters and formatters |
| `:LazyHealth`, `:checkhealth` | Check dependencies and platform integration |

Searchable commands and mappings reflect loaded plugins and registered lazy
commands. Language-specific actions appear when opening a matching file.

## Switching physical keyboards

- `:KeyboardLayout us` — standard US keys.
- `:KeyboardLayout se` — adds the Swedish helpers below on macOS and Windows/Linux.
- Switch immediately without restarting; your choice is saved in Neovim's state
  directory, outside Git, so each computer keeps its own setting.
- `NVIM_KEYBOARD=us` or `NVIM_KEYBOARD=se` overrides the saved choice at startup,
  useful for terminal profiles. An OS keyboard switch does not automatically switch Neovim.
- Leader stays `Space`. Both layouts keep all original shortcuts. Helpers apply
  only to normal, visual and operator-pending modes; typing Swedish in insert
  mode still works. Select the matching input language in the OS as usual.

| Swedish key | Acts as | Example |
|---|---|---|
| `ö` / `ä` | `[` / `]` | `öd` / `äd` diagnostics, `öb` / `äb` buffers |
| `Ö` / `Ä` | `{` / `}` | Previous / next paragraph |
| `+` / `¤` / `€` | `$` | End of line (`0` still goes to the beginning) |
| `§` | backtick | Exact mark jump |

On macOS, Option combinations depend on terminal settings (Option as Alt versus
text input). These helpers avoid needing Option for common navigation. The same
aliases work on Swedish Windows/Linux keyboards because they use the characters
Neovim actually receives, rather than physical key codes.

## Everyday shortcuts

| Keys | Action |
|---|---|
| `Space Space` / `Space /` | Find files / search project text |
| `Space e` / `Space fm` | Explorer / mini.files |
| `gd` / `K` | Definition / hover documentation |
| `Space ca` / `Space cr` / `Space cf` | Code actions / rename / format |
| `Space xx` | Diagnostics |
| `Space gg` | LazyGit (install manually on Linux if unavailable) |
| `Space tt` / `Space db` | Run nearest test / toggle breakpoint |
| `Space U` | Undo history |
| `Ctrl-d` / `Ctrl-u` | Half-page movement, centered |

## Where to customize

| File | Controls |
|---|---|
| `lua/plugins/ui.lua` | Vivid syntax palette, transparency, line number, status bar |
| `lua/config/options.lua` | Editor behavior and local tool PATH |
| `lua/config/keymaps.lua` | Shared shortcuts |
| `lua/config/keyboard.lua` | Layout helpers and per-machine preferences |
| `lua/config/overview.lua` | Overview menu |
| `lua/config/lazy.lua` | Enabled language and feature extras |
| `lua/plugins/*.lua` | Plugin additions and overrides |
| `lazy-lock.json` | Plugin versions; commit after intentional updates |

The editor stays transparent, highlights only the current line number, and shows
filename, modification state, Git info, diagnostics, file type, position, and a
12-hour clock. Date appears when the terminal has at least 110 columns.

Language extras: TS/JS/React, JSON, Tailwind, Python, Go, Rust, C/C++, CMake,
YAML, TOML, Markdown, Docker, SQL, Git, shell and Lua.

Sources: [LazyVim installation](https://www.lazyvim.org/installation),
[LazyVim keymaps](https://www.lazyvim.org/keymaps),
[Neovim installation](https://neovim.io/doc/install/).

## Clipboard and movement reminder

The status bar shows bold, centered `⬅  ⬇  ⬆  ➡` in Normal mode when at least 90 columns fit.
On macOS, select text in Neovim and press Cmd+C; Cmd+V pastes from the system
clipboard. The shared Ghostty config lets Cmd+C reach Neovim when there is no
terminal selection; terminal selections still copy normally. Reload Ghostty's
config after updating it. On a new Mac, run `bash osxconfig/install.sh` from the
dotfiles root once to link the shared shell/Ghostty settings. Terminal paste uses bracketed paste to preserve text.

Ctrl+C copies a Visual selection and Ctrl+V pastes inside Neovim on Windows/Linux.
Ctrl+C without a selection keeps its cancel/interrupt behavior. Ctrl+Q or
`Space cB` enters block selection, replacing the usual Ctrl+V binding.
`Space cy` copies the current line; `Space cp` pastes from the system clipboard.
Command-line mode supports clipboard pasting too. OS/terminal interception takes
precedence over Neovim mappings; Windows Terminal normally handles Ctrl+V itself.
If a terminal captures Ctrl+C, Shift+mouse-select copies terminal text, and
`Space cy` remains available for copying within Neovim.

Native macOS uses pbcopy/pbpaste; Windows uses Neovim's clipboard provider.
Run `:checkhealth vim.provider` if the OS clipboard does not work. GUI Neovim
clients can use the same Cmd+C/Cmd+V mappings. Remote SSH clipboard behavior
depends on the terminal's OSC 52 support.

The macOS shell also has `repo` (go to `~/REPO`) and `dl` (go to `~/Downloads`).
Run `termhelp` for the shell cheat sheet. Ghostty's `background-opacity-cells`
setting applies opacity to menus and other explicitly colored cells as well.

## Editing and navigation

| Keys | Action |
|---|---|
| `Space e` | Switch focus between explorer and editor; opens explorer if needed |
| `Space E` | Show / hide explorer |
| `Tab`, `Esc`, or `Ctrl-l` inside explorer | Return focus to the editor |
| `Ctrl-h` / `Ctrl-l` in the editor | Move between left / right windows |
| `Enter` / `l` / Right in explorer | Open file in editor, or expand directory |
| `h` / Left in explorer | Collapse directory |
| `/` in explorer | Search/filter the tree |
| `a` / `r` / `d` in explorer | Add / rename / delete (confirmation/trash where supported) |
| `H` / `I` in explorer | Show hidden / ignored files |
| `?` in explorer | Explorer key help |
| `Space cc` / `gcc` | Toggle comment on the current line |
| `V`, then down/up in the cluster, then `Space cc` or `gc` | Select lines and toggle comments |
| `Space zt` / `za` | Toggle the fold under the cursor |
| `Space zo` / `zO` | Expand current block and its nested folds |
| `Space zc` / `zC` | Collapse current block and its nested folds |
| `Space zr` / `zR` | Expand all |
| `Space zm` / `zM` | Collapse all |
| `Space zj` / `zj`, `Space zk` / `zk` | Jump to next / previous fold boundary |
| `Space cj` / `]f`, `Space ck` / `[f` | Next / previous function (Space shortcuts open the target fold) |
| `%` | Jump to matching brace/bracket |
| `Space ss` | Search functions and other symbols in this file (LSP) |

Files start with syntax-aware folds collapsed. This needs the filetype's
Treesitter parser and fold queries; `:TSInstall <language>` can install a missing
parser. Comment toggling uses the filetype's comment syntax. The explorer stays
open after opening files and follows the active file.

File search (`Space Space`, `Space ff`), text search (`Space /`, `Space sg`) and
recent files (`Space fr`) are scoped to the active project. Git roots take priority
over language-server subprojects, so monorepos search the whole repository.
Outside Git, language/project markers are used, then the current working directory.
`Space fF` and `Space sG` remain available for an explicit working-directory search.

## Vivid syntax palette

The background stays transparent, including folded lines. Ordinary identifiers
are white; functions yellow; strings green; object properties cyan; types blue;
local declarations purple; imports/exports pink; return/exception keywords and
numbers orange; booleans red. Comments use a softer blue-gray.

For JS/TS/JSX/TSX, `const`, `let`, and `var` are purple locally and pink when the
declaration is directly exported. This is based on syntax, rather than trying to
infer runtime/public API visibility. Strings and declaration keywords retain their
roles when language-server highlighting is active.

Edit `lua/config/palette.lua` for colors, `after/queries/ecma/` for JS/TS-specific
rules, `lua/plugins/workflow.lua` for the explorer, and `lua/config/navigation.lua`
for focus/project scope behavior. Terminals use a single cell font size; the
movement arrows use heavier glyphs, bold white, and spacing for visibility.


## Smooth scrolling, power and arrow keys

Keyboard scrolling uses a short easing animation. Holding scroll keys uses a
quicker repeat animation. Snacks avoids adding another animation on top of small
mouse-wheel/trackpad scrolls, leaving those to the terminal.

The default animation profile is `auto`: 120 FPS target on external power and
60 FPS on battery (or unknown power). The cursor animation follows the same
policy. Power is checked asynchronously at startup, when Neovim gains focus, and
every 60 seconds. macOS uses pmset; native Windows uses the Windows power API
through PowerShell; Linux reads sysfs. WSL falls back to 60 FPS if host battery
information is unavailable. An attached desktop without a battery uses the AC profile.

`:AnimationProfile` shows the current setting. `:AnimationProfile battery`
forces 60 FPS, `:AnimationProfile performance` requests 120 FPS, and
`:AnimationProfile auto` returns to power detection. Manual overrides last for
this Neovim session; choose battery mode manually when OS energy-saving settings
or a remote connection call for it. `Space uS` toggles smooth scrolling.
Actual visible frame rate depends on the terminal, display, workload and scrolling
distance; a 60 Hz display cannot show 120 distinct frames. These settings do not
change the display refresh rate or disable terminal vsync.

In editor Normal/Visual mode, Up/Down scroll the viewport by 20 lines;
Left/Right move normally. Insert-mode arrows still move normally. Explorer/finder
arrows keep their usual menu navigation.

## Permanent same-position navigation cluster

No modifier or toggle is needed in Normal/Visual editor buffers:

| Direction | Swedish | US |
|---|---|---|
| Up | `p` | `p` |
| Left | `l` | `l` |
| Down | `ö` | `;` |
| Right | `ä` | apostrophe (`'`) |

```text
Swedish:      p           US:      p
            l ö ä               l ; '
```

`:KeyboardLayout se` / `us` adapts the character mappings when changing the OS
input language. They use equivalent physical keyboard positions; the setting
does not detect the OS input source automatically. Swedish `å`/`¨` correspond to
US `[`/`]` positions; this cluster uses `p` and the three home-row positions below.

Old `h`, `j`, and `k` movement is disabled in these editor modes, and `l` now moves
left. `p` is no longer paste: use Cmd/Ctrl+V or `Space cp`. The previous optional
cluster mode and Alt+WASD workaround have been removed. No stored toggle is read.

Insert typing, operator-pending commands, and explorer/finder bindings keep their
normal meanings. This preserves operations like `dw`, `dh`, and `f<char>`; other
prefix shortcuts (`Space ...`, `Ctrl-w ...`) still work. On US layouts, the
original semicolon repeat-find command is available with `Space m;`, and the
apostrophe mark-jump command with `Space m'` followed by the mark name.
Swedish `ö`/`ä` no longer act as bracket helpers in Normal/Visual editor mode;
use the original `[`/`]` commands, or the `Space c`/`Space z` navigation shortcuts.

## Caps Lock boundary jumps on macOS

| Hold Caps Lock and press | Jump |
|---|---|
| `a` | Beginning of line |
| `d` | End of line |
| `w` | Top of file |
| `s` | Bottom of file |

The shared Karabiner rule applies only in Ghostty and leaves Caps Lock alone in
other applications. Tapping Caps Lock by itself keeps its usual toggle behavior.
It sends Home/End and Ctrl+Home/Ctrl+End, which Neovim understands independently
of Swedish/US layout. The editor config also maps those full-keyboard events.

Run `python3 scripts/install_caps.py` from the dotfiles root, or run the macOS
`osxconfig/install.sh` helper. Finish Karabiner's Setup permissions (background
services, Accessibility, input capture, and driver as requested). Until those
macOS prerequisites are complete the Caps shortcuts cannot work. These OS-level
permissions give Karabiner keyboard access; the configuration scopes the rules
to Ghostty. Windows/Linux need an OS remapper emitting the same four key events;
this macOS rule is not installed on those systems.

Caps Lock is a toggle key, not a terminal modifier, so Neovim alone cannot detect
Caps+WASD reliably. The rule is in `osxconfig/karabiner/caps-navigation.json`;
the installer merges it into the selected profile and backs up existing settings.

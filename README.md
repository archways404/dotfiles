# Keybind Cheat Sheet

## Custom Keybinds

| Keybind      | Mode   | Action                                                                         | Description                                              |
| ------------ | ------ | ------------------------------------------------------------------------------ | -------------------------------------------------------- |
| `<leader>pv` | Normal | `vim.cmd.Ex`                                                                   | Open file explorer                                       |
| `H`          | Visual | `:m '>+1<CR>gv=gv`                                                             | Move selected line/block up                              |
| `J`          | Visual | `:m '<-2<CR>gv=gv`                                                             | Move selected line/block down                            |
| `J`          | Normal | `mzJ`                                                                          | Join line below to the current one without losing cursor |
| `<C-d>`      | Normal | `<C-d>zz`                                                                      | Scroll down and center cursor                            |
| `<C-u>`      | Normal | `<C-u>zz`                                                                      | Scroll up and center cursor                              |
| `n`          | Normal | `nzzzv`                                                                        | Next search result and center cursor                     |
| `N`          | Normal | `Nzzzv`                                                                        | Previous search result and center cursor                 |
| `<leader>p`  | Visual | `"_dP`                                                                         | Paste without overwriting register                       |
| `<leader>y`  | Normal | `"+y`                                                                          | Yank to system clipboard                                 |
| `<leader>y`  | Visual | `"+y`                                                                          | Yank to system clipboard                                 |
| `<leader>Y`  | Normal | `"+Y`                                                                          | Yank line to system clipboard                            |
| `<C-s>`      | Normal | `:w<CR>`                                                                       | Save file                                                |
| `<C-s>`      | Insert | `<C-o>:w<CR>`                                                                  | Save file                                                |
| `<C-s>`      | Visual | `<C-c>:w<CR>`                                                                  | Save file                                                |
| `<leader>gs` | Normal | `vim.cmd.Git`                                                                  | Open Git status                                          |
| `<leader>a`  | Normal | `mark.add_file`                                                                | Add file to harpoon                                      |
| `<C-e>`      | Normal | `ui.toggle_quick_menu`                                                         | Toggle harpoon quick menu                                |
| `<C-h>`      | Normal | `function() ui.nav_file(1) end`                                                | Navigate to harpoon file 1                               |
| `<C-t>`      | Normal | `function() ui.nav_file(2) end`                                                | Navigate to harpoon file 2                               |
| `<C-n>`      | Normal | `function() ui.nav_file(3) end`                                                | Navigate to harpoon file 3                               |
| `<C-s>`      | Normal | `function() ui.nav_file(4) end`                                                | Navigate to harpoon file 4                               |
| `<leader>pf` | Normal | `builtin.find_files`                                                           | Find files using Telescope                               |
| `<C-p>`      | Normal | `builtin.git_files`                                                            | Find Git files using Telescope                           |
| `<leader>ps` | Normal | `function() builtin.grep_string({ search = vim.fn.input('Grep for > ') }) end` | Grep for a string using Telescope                        |
| `<leader>u`  | Normal | `vim.cmd.UndotreeToggle`                                                       | Toggle Undotree                                          |
| `<C-L>`      | Insert | `copilot#Accept("<CR>")`                                                       | Accept GitHub Copilot suggestion                         |
| `<C-K>`      | Insert | `copilot#Next()`                                                               | Next GitHub Copilot suggestion                           |
| `<C-J>`      | Insert | `copilot#Previous()`                                                           | Previous GitHub Copilot suggestion                       |

## Additional Plugin Keybinds

### Harpoon

| Keybind     | Mode   | Action                | Description                 |
| ----------- | ------ | --------------------- | --------------------------- |
| `<leader>a` | Normal | `mark.add_file`       | Add file to harpoon         |
| `<C-e>`     | Normal | `ui.toggle_quick_menu`| Toggle harpoon quick menu   |
| `<C-h>`     | Normal | `ui.nav_file(1)`      | Navigate to harpoon file 1  |
| `<C-t>`     | Normal | `ui.nav_file(2)`      | Navigate to harpoon file 2  |
| `<C-n>`     | Normal | `ui.nav_file(3)`      | Navigate to harpoon file 3  |
| `<C-s>`     | Normal | `ui.nav_file(4)`      | Navigate to harpoon file 4  |

### Telescope

| Keybind      | Mode   | Action                | Description                   |
| ------------ | ------ | --------------------- | ----------------------------- |
| `<leader>pf` | Normal | `builtin.find_files`  | Find files using Telescope    |
| `<C-p>`      | Normal | `builtin.git_files`   | Find Git files using Telescope|
| `<leader>ps` | Normal | `builtin.grep_string` | Grep for a string using Telescope |

### Fugitive

| Keybind      | Mode   | Action         | Description      |
| ------------ | ------ | -------------- | ---------------- |
| `<leader>gs` | Normal | `vim.cmd.Git`  | Open Git status  |

### UndoTree

| Keybind      | Mode   | Action                    | Description         |
| ------------ | ------ | ------------------------- | ------------------- |
| `<leader>u`  | Normal | `vim.cmd.UndotreeToggle`  | Toggle Undotree     |

## Default Keybinds (Common Ones)

| Keybind  | Mode   | Action                 | Description                  |
| -------- | ------ | ---------------------- | ---------------------------- |
| `i`      | Normal | Enter Insert Mode      | Start inserting text         |
| `v`      | Normal | Enter Visual Mode      | Start visual selection       |
| `y`      | Normal | Yank (copy)            | Copy the selected text       |
| `p`      | Normal | Paste                  | Paste text                   |
| `d`      | Normal | Delete                 | Delete text                  |
| `u`      | Normal | Undo                   | Undo last action             |
| `Ctrl-r` | Normal | Redo                   | Redo undone action           |
| `/`      | Normal | Search                 | Start searching              |
| `n`      | Normal | Next Search Result     | Go to next search result     |
| `N`      | Normal | Previous Search Result | Go to previous search result |
| `:`      | Normal | Command Prompt         | Open command line            |
| `q`      | Normal | Quit                   | Quit Neovim                  |
| `w`      | Normal | Write                  | Save file                    |
| `e`      | Normal | Edit                   | Open file                    |
| `Esc`    | Insert | Normal Mode            | Switch back to Normal mode   |

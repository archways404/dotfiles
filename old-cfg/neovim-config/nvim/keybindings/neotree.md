# Neo-tree Cheat Sheet



This cheat sheet outlines the keybindings and configurations for the Neo-tree plugin in Neovim.



---



## Keybindings



### Window Mappings

| Key                 | Action                                      |

|---------------------|---------------------------------------------|

| `<space>`           | Toggle the node (expand/collapse)          |

| `<2-LeftMouse>`     | Open the selected file or directory         |

| `<CR>`              | Open the selected file                     |

| `<ESC>`             | Cancel (close preview or floating window)  |

| `P`                 | Toggle preview (use float/image.nvim)      |

| `l`                 | Focus preview                              |

| `S`                 | Open in horizontal split                   |

| `s`                 | Open in vertical split                     |

| `t`                 | Open in a new tab                          |

| `w`                 | Open with window picker                    |

| `C`                 | Close the node                             |

| `z`                 | Close all nodes                            |

| `a`                 | Add a new file                             |

| `A`                 | Add a new directory                        |

| `d`                 | Delete the selected file/directory         |

| `r`                 | Rename the selected file/directory         |

| `y`                 | Copy to clipboard                          |

| `x`                 | Cut to clipboard                           |

| `p`                 | Paste from clipboard                       |

| `c`                 | Copy to a specified location               |

| `m`                 | Move to a specified location               |

| `q`                 | Close the Neo-tree window                  |

| `R`                 | Refresh the Neo-tree                       |

| `<`                 | Move to the previous source                |

| `>`                 | Move to the next source                    |

| `i`                 | Show file details                          |

| `?`                 | Show help                                  |



### Filesystem Mappings

| Key                 | Action                                      |

|---------------------|---------------------------------------------|

| `<BS>`              | Navigate up                                |

| `.`                 | Set the current directory as root          |

| `H`                 | Toggle visibility of hidden files          |

| `/`                 | Open fuzzy finder                          |

| `D`                 | Fuzzy finder for directory                 |

| `f`                 | Filter files                               |

| `<C-x>`             | Clear filter                               |

| `[g`                | Go to previous git-modified file           |

| `]g`                | Go to next git-modified file               |



### Git Status Mappings

| Key                 | Action                                      |

|---------------------|---------------------------------------------|

| `A`                 | Stage all files                            |

| `gu`                | Unstage the selected file                  |

| `ga`                | Stage the selected file                    |

| `gr`                | Revert the selected file                   |

| `gc`                | Commit changes                             |

| `gp`                | Push changes                               |

| `gg`                | Commit and push changes                    |



---



## Configuration Options



### Default Settings

- **Close Neo-tree if it's the last window:** `false`

- **Popup border style:** `rounded`

- **Enable git status:** `true`

- **Enable diagnostics:** `true`

- **Case-insensitive sorting:** `false`

- **Indentation markers:** Enabled with `│` for normal and `└` for last indent.

- **Icons:** Uses `nvim-web-devicons` for file and folder icons.

- **Diagnostics Signs:** Custom symbols for errors, warnings, info, and hints.



### Diagnostic Symbols

| Diagnostic Type     | Symbol         |

|---------------------|----------------|

| Error               |              |

| Warning             |              |

| Info                |              |

| Hint                | 󰌵            |



### Filesystem

- **Hide dotfiles:** `true`

- **Hide gitignored files:** `true`

- **Always show specific files:** You can configure specific files to always show regardless of other settings.



### Window Position

| Position            | Description                                |

|---------------------|--------------------------------------------|

| Left                | Opens Neo-tree on the left side (default) |

| Float               | Opens Neo-tree in a floating window       |



---



## Commands

| Command             | Action                                      |

|---------------------|---------------------------------------------|

| `:Neotree reveal`   | Reveal the current file in Neo-tree         |

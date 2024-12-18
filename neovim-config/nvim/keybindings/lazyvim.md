# Neovim Keybindings Cheat Sheet



## General Navigation

- **CTRL + j**: Move cursor down (smart line wrap aware).

- **CTRL + k**: Move cursor up (smart line wrap aware).

- **CTRL + Down Arrow**: Move cursor down (smart line wrap aware).

- **CTRL + Up Arrow**: Move cursor up (smart line wrap aware).



## Window Navigation

- **CTRL + h**: Go to the left window.

- **CTRL + j**: Go to the lower window.

- **CTRL + k**: Go to the upper window.

- **CTRL + l**: Go to the right window.



## Window Resizing

- **CTRL + Up Arrow**: Increase window height.

- **CTRL + Down Arrow**: Decrease window height.

- **CTRL + Left Arrow**: Decrease window width.

- **CTRL + Right Arrow**: Increase window width.



## Moving Lines

- **ALT + j**: Move current line/selection down.

- **ALT + k**: Move current line/selection up.



## Buffer Navigation

- **SHIFT + h**: Switch to the previous buffer.

- **SHIFT + l**: Switch to the next buffer.

- **[b**: Go to the previous buffer.

- **]b**: Go to the next buffer.

- **Leader + bb**: Switch to the other buffer.

- **Leader + \`**: Switch to the other buffer.

- **Leader + bd**: Delete the current buffer.

- **Leader + bo**: Delete all buffers except the current one.

- **Leader + bD**: Delete the current buffer and window.



## Searching and Highlighting

- **Escape**: Clear search highlights.

- **Leader + ur**: Redraw screen, clear search highlights, and update diffs.



## Undo Breakpoints

- **,**: Insert a break point for undo.

- **.**: Insert a break point for undo.

- **;**: Insert a break point for undo.



## File Operations

- **CTRL + s**: Save file (Windows/Linux).

- **Command + s**: Save file (MacOS).

- **Leader + fn**: Create a new file.



## Indenting

- **<**: Indent left (in visual mode).

- **>**: Indent right (in visual mode).



## Commenting

- **gco**: Add a comment below the current line.

- **gcO**: Add a comment above the current line.



## Diagnostics

- **Leader + cd**: Show line diagnostics.

- **]d**: Jump to the next diagnostic.

- **[d**: Jump to the previous diagnostic.

- **]e**: Jump to the next error diagnostic.

- **[e**: Jump to the previous error diagnostic.

- **]w**: Jump to the next warning diagnostic.

- **[w**: Jump to the previous warning diagnostic.



## Terminal

- **CTRL + /**: Open a floating terminal.

- **CTRL + /** (in terminal): Close the floating terminal.



## Tabs

- **Leader + Tab + l**: Go to the last tab.

- **Leader + Tab + o**: Close all other tabs.

- **Leader + Tab + f**: Go to the first tab.

- **Leader + Tab + Tab**: Create a new tab.

- **Leader + Tab + ]**: Go to the next tab.

- **Leader + Tab + d**: Close the current tab.

- **Leader + Tab + [**: Go to the previous tab.



## Git (if Lazygit is installed)

- **Leader + gg**: Open Lazygit in the root directory.

- **Leader + gG**: Open Lazygit in the current working directory.

- **Leader + gf**: Show the current file's history in Lazygit.

- **Leader + gb**: Show blame for the current line.

- **Leader + gB**: Open the repository in a browser.



---



### Keybinding Legend

- **CTRL**: Control key.

- **ALT**: Alt/Option key.

- **Leader**: Your configured leader key.

-- remap.lua

-- Remap movement to WASD in normal mode
vim.api.nvim_set_keymap('n', 'w', 'k', { noremap = true, silent = true })  -- Move up
vim.api.nvim_set_keymap('n', 's', 'j', { noremap = true, silent = true })  -- Move down
vim.api.nvim_set_keymap('n', 'a', 'h', { noremap = true, silent = true })  -- Move left
vim.api.nvim_set_keymap('n', 'd', 'l', { noremap = true, silent = true })  -- Move right

-- Remap movement in visual mode to WASD
vim.api.nvim_set_keymap('v', 'w', 'k', { noremap = true, silent = true })  -- Move up
vim.api.nvim_set_keymap('v', 's', 'j', { noremap = true, silent = true })  -- Move down
vim.api.nvim_set_keymap('v', 'a', 'h', { noremap = true, silent = true })  -- Move left
vim.api.nvim_set_keymap('v', 'd', 'l', { noremap = true, silent = true })  -- Move right

-- Remap in operator-pending mode (for commands like 'dw', 'cw', etc.)
vim.api.nvim_set_keymap('o', 'w', 'k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('o', 's', 'j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('o', 'a', 'h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('o', 'd', 'l', { noremap = true, silent = true })

-- Remap some overwritten default keybindings
-- Remap 'd' (delete) to 'x'
vim.api.nvim_set_keymap('n', 'x', 'd', { noremap = true, silent = true })  -- Delete
vim.api.nvim_set_keymap('v', 'x', 'd', { noremap = true, silent = true })  -- Delete in visual mode

-- Remap 'a' (append) to 'A' (Shift-a)
vim.api.nvim_set_keymap('n', 'A', 'a', { noremap = true, silent = true })  -- Append after the cursor


-- Navigation
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "H", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "J", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("x", "<leader>p", "\"_dP")

vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")


vim.api.nvim_set_keymap('i', '<Caps_Lock>', '<Esc>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<Caps_Lock>', '<Esc>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('v', '<Caps_Lock>', '<Esc>', { noremap = true, silent = true })

-- Remap Copilot key mappings to Ctrl + Arrow Keys
vim.g.copilot_no_tab_map = true

-- Accept Copilot suggestion with 'Ctrl + Right Arrow'
vim.api.nvim_set_keymap("i", "<C-Right>", 'copilot#Accept("<CR>")', { silent = true, expr = true })

-- Next Copilot suggestion with 'Ctrl + Down Arrow'
vim.api.nvim_set_keymap("i", "<C-Down>", 'copilot#Next()', { silent = true, expr = true })

-- Previous Copilot suggestion with 'Ctrl + Left Arrow'
vim.api.nvim_set_keymap("i", "<C-Left>", 'copilot#Previous()', { silent = true, expr = true })






-- Open a terminal in horizontal split
-- vim.api.nvim_set_keymap('n', '<leader>th', ':split | terminal<CR>', { noremap = true, silent = true })

-- Open a terminal in vertical split
-- vim.api.nvim_set_keymap('n', '<leader>tv', ':vsplit | terminal<CR>', { noremap = true, silent = true })

-- Close the terminal using Ctrl-x
-- vim.api.nvim_set_keymap('t', '<C-x>', [[<C-\><C-n>:q<CR>]], { noremap = true, silent = true })

-- Exit terminal mode with Esc
-- vim.api.nvim_set_keymap('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })

-- Switch focus between windows with Ctrl-w w
-- vim.api.nvim_set_keymap('t', '<C-w><C-w>', [[<C-\><C-n><C-w>w]], { noremap = true, silent = true })

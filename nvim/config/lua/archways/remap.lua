-- remap.lua

-- Remap 'h' to move up and 'j' to move down
vim.api.nvim_set_keymap('n', 'h', 'k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'j', 'j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'k', 'h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'l', 'l', { noremap = true, silent = true })

-- Also remap 'h' and 'j' in visual mode
vim.api.nvim_set_keymap('v', 'h', 'k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'j', 'j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'k', 'h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'l', 'l', { noremap = true, silent = true })

-- Remap 'h' and 'j' in operator-pending mode (for commands like 'dh' or 'cj')
vim.api.nvim_set_keymap('o', 'h', 'k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('o', 'j', 'j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('o', 'k', 'h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('o', 'l', 'l', { noremap = true, silent = true })

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

vim.api.nvim_set_keymap('n', '<C-s>', ':w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-s>', '<C-o>:w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-s>', '<C-c>:w<CR>', { noremap = true, silent = true })


-- Save on buffer leave
vim.cmd("autocmd BufLeave * :wa")

-- Save on leaving insert mode
vim.cmd("autocmd InsertLeave * :wa")


vim.api.nvim_set_keymap('i', '<Caps_Lock>', '<Esc>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Caps_Lock>', '<Esc>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<Caps_Lock>', '<Esc>', { noremap = true, silent = true })


-- Key mappings for GitHub Copilot
vim.g.copilot_no_tab_map = true
vim.api.nvim_set_keymap("i", "<C-L>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
vim.api.nvim_set_keymap("i", "<C-K>", 'copilot#Next()', { silent = true, expr = true })
vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Previous()', { silent = true, expr = true })

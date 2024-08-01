-- Remap 'j' to move up and 'k' to move down
vim.api.nvim_set_keymap('n', 'j', 'k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'k', 'j', { noremap = true, silent = true })

-- Also remap 'j' and 'k' in visual mode
vim.api.nvim_set_keymap('v', 'j', 'k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'k', 'j', { noremap = true, silent = true })

-- Remap 'j' and 'k' in operator-pending mode (for commands like 'dj' or 'ck')
vim.api.nvim_set_keymap('o', 'j', 'k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('o', 'k', 'j', { noremap = true, silent = true })

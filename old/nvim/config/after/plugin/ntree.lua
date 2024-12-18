-- Disable netrw (recommended to avoid conflicts)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.termguicolors = true

require('nvim-tree').setup({
  git = {
    enable = true,
    ignore = true,
  },

  on_attach = function(bufnr)
    local api = require('nvim-tree.api')

    -- Define options for mappings
    local opts = { noremap = true, silent = true, buffer = bufnr }

    -- Remap 'a' to go up a directory or close folder
    vim.keymap.set('n', 'a', api.node.navigate.parent_close, opts)

    -- Remap 'd' to open a file or expand folder
    vim.keymap.set('n', 'd', api.node.open.edit, opts)

    -- Remap default 'a' (add a file or directory) to 'A'
    vim.keymap.set('n', 'A', api.fs.create, opts)

    -- Remap default 's' (open file in a horizontal split) to 'S'
    vim.keymap.set('n', 'S', api.node.open.horizontal, opts)

    -- Remap default 'space' (toggle preview) to 'p'
    vim.keymap.set('n', 'p', api.node.open.preview, opts)
    
  end
})

-- Key mapping to toggle the tree view
vim.api.nvim_set_keymap('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require('nvim-tree.api').tree.open()
  end
})
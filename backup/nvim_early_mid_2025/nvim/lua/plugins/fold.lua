return {
  "kevinhwang91/nvim-ufo",
  dependencies = { "kevinhwang91/promise-async" },
  config = function()
    --vim.opt.foldcolumn = "1" -- Show fold column
    --vim.opt.foldlevel = 0 -- Start with all folds closed
    --vim.opt.foldlevelstart = 0 -- Ensure folds are closed on startup
    --vim.opt.foldenable = true -- Enable folding

    vim.opt.foldcolumn = "1" -- Show fold column
    vim.opt.foldlevel = 99 -- Allow deeper folding levels
    vim.opt.foldlevelstart = 99 -- Open most folds by default
    vim.opt.foldenable = true -- Enable folding

    -- Use Treesitter + LSP for better folds
    require("ufo").setup({
      provider_selector = function(bufnr, filetype, buftype)
        return { "treesitter", "indent" }
      end,
    })

    -- Keybindings for better folding control
    vim.keymap.set("n", "<leader>of", "zO", { desc = "Open fold and all sub-folds" }) -- Open fold and everything inside
    vim.keymap.set("n", "<leader>cf", "zc", { desc = "Close current fold" }) -- Close fold at cursor
    vim.keymap.set("n", "<leader>af", "zR", { desc = "Open all folds" }) -- Open all folds
    vim.keymap.set("n", "<leader>xf", "zM", { desc = "Close all folds" }) -- Close all folds
  end
}
return {
  "mikavilpas/yazi.nvim",
  dependencies = { "nvim-lua/plenary.nvim" }, -- Plenary is required
  cmd = "Yazi", -- Only load when running `:Yazi`
  config = function()
    require("yazi").setup({
      open_for_directories = true, -- Open Yazi when entering a directory
      resize_to_editor = true, -- Resize Yazi when opening files
    })

    -- Keybindings
    vim.keymap.set("n", "<leader>yo", ":Yazi<CR>", { desc = "Open Yazi File Manager" })
    vim.keymap.set("n", "<leader>yf", ":Yazi %<CR>", { desc = "Open current file in Yazi" })

  end
}
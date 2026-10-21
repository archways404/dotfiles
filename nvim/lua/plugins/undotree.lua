-- Browse the full undo history (persistent across sessions via undofile)
return {
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = { { "<leader>U", "<cmd>UndotreeToggle<cr>", desc = "Undo tree" } },
    init = function()
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
  },
}

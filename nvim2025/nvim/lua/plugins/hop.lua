return {
  "smoka7/hop.nvim",
  version = "*", -- Use the latest stable version
  config = function()
    local hop = require("hop")
    hop.setup({
      keys = "etovxqpdygfblzhckisuran", -- Customizable keys
      case_insensitive = true, -- Ignore case while searching
      uppercase_labels = true, -- Disable uppercase hints
      multi_windows = false, -- Prevents displaying hints across all windows
    })

    -- Keybindings for movement
    vim.keymap.set("n", "<leader>j", "<cmd>HopWord<CR>", { desc = "Jump to word" })
    vim.keymap.set("n", "<leader>k", "<cmd>HopLine<CR>", { desc = "Jump to line" })
    vim.keymap.set("n", "<leader>c", "<cmd>HopChar1<CR>", { desc = "Jump to single character" })
    vim.keymap.set("n", "<leader>cc", "<cmd>HopChar2<CR>", { desc = "Jump to two characters" })
    vim.keymap.set("n", "<leader>p", "<cmd>HopPattern<CR>", { desc = "Jump to pattern" })
  end,
}
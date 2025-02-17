return {
  "otavioschwanck/arrow.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("arrow").setup({
      show_icons = true, -- Enable icons in the UI
      leader_key = "<leader>r", -- Shortcut prefix for Arrow commands
      disable_default_keybindings = false, -- Keep default keybindings
      mappings = {
        ["<leader>ra"] = "add", -- Add new file
        ["<leader>rr"] = "rename", -- Rename file
        ["<leader>rm"] = "move", -- Move file
        ["<leader>rd"] = "delete", -- Delete file
        ["<leader>rf"] = "find", -- Fuzzy find files
        ["<leader>rs"] = "search", -- Live grep
      },
    })
  end,
}
return {
  "karb94/neoscroll.nvim",
  event = "VeryLazy", -- Load lazily
  config = function()
    require("neoscroll").setup({
      -- Disable the default mappings
      mappings = {},
    })

    -- Manually set the mappings using helper functions
    local t = {
      ["<C-y>"] = { "scroll", { "-vim.wo.scroll", "true", "250" } }, -- Scroll up
      ["<C-e>"] = { "scroll", { "vim.wo.scroll", "true", "250" } }, -- Scroll down
      ["<C-d>"] = { "scroll", { "-5", "true", "100" } }, -- Scroll up 5 lines
      ["<C-u>"] = { "scroll", { "5", "true", "100" } }, -- Scroll down 5 lines
      ["zz"] = { "scroll", { "0", "true", "200" } }, -- Center cursor
    }

    -- Apply the mappings
    require("neoscroll.config").set_mappings(t)
  end,
}
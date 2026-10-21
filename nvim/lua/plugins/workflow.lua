return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          -- Reserve Space cc for commenting even after an LSP attaches.
          keys = { { "<leader>cc", false, mode = { "n", "x" } } },
        },
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = true },
      picker = {
        sources = {
          explorer = {
            follow_file = true,
            auto_close = false,
            jump = { close = false },
            layout = { preset = "sidebar", preview = false, layout = { width = 36, min_width = 28 } },
            actions = { focus_editor = function(picker) require("config.navigation").focus_editor(picker) end },
            win = {
              list = {
                keys = {
                  ["<Tab>"] = "focus_editor", ["<C-l>"] = "focus_editor",
                  ["<Right>"] = "confirm", ["<Left>"] = "explorer_close",
                  ["<Esc>"] = "focus_editor",
                },
              },
            },
          },
        },
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = { spec = { { "<leader>z", group = "folds / blocks" } } },
  },
}

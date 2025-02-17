return {
  "folke/noice.nvim",
  event = "VeryLazy", -- Load when needed
  dependencies = {
    "MunifTanjim/nui.nvim", -- Required UI Library
    "rcarriga/nvim-notify", -- Optional: Fancy notifications
  },
  config = function()
    require("noice").setup({
      -- 📢 Customize Message UI (LSP, Echo, Errors)
      messages = {
        enabled = true, -- Show messages
        view = "mini", -- Compact messages at the bottom
        view_error = "notify", -- Show errors as notifications
        view_warn = "notify", -- Show warnings as notifications
        view_search = "virtualtext", -- Highlight search messages inline
      },

      -- 📜 Customize Command UI (Cmdline)
      cmdline = {
        enabled = true, -- Show command UI
        view = "cmdline_popup", -- Show as a floating UI
        format = {
          cmdline = { icon = ">" }, -- Normal mode commands
          search_down = { icon = "🔎↓" }, -- `/` search
          search_up = { icon = "🔎↑" }, -- `?` search
          lua = { icon = "🌙", title = "Lua Command" }, -- Lua command mode
        },
      },

      -- 🛠 Customize Popup UI (Hover, Signatures)
      popupmenu = {
        enabled = true, -- Use Noice for popups
        backend = "nui", -- Better UI rendering
      },

      -- 🎯 Customize LSP UI (Hover, Messages)
      lsp = {
        progress = {
          enabled = true, -- Show LSP progress
          format = "lsp_progress", -- Use LSP progress format
        },
        hover = { enabled = false }, -- Use default LSP hover
        signature = { enabled = false }, -- Use default LSP signature
        message = { enabled = true, view = "notify" }, -- Show LSP messages
      },

      -- 🔥 Presets (Recommended)
      presets = {
        bottom_search = true, -- Moves search messages to the bottom
        long_message_to_split = true, -- Avoids message overflow
        inc_rename = true, -- Smooth rename experience
        lsp_doc_border = true, -- Adds border around LSP popups
      },
    })

    -- 🔔 Use `nvim-notify` as the notification backend
    require("notify").setup({
      background_colour = "#000000", -- Set notification background
      fps = 60, -- Smooth animations
      timeout = 3000, -- Messages disappear after 3s
    })

    -- Set Neovim's notification handler to use Noice
    vim.notify = require("notify")
  end,
}
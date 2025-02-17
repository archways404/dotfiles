return {
  "numToStr/Comment.nvim",
  dependencies = {
    "JoosepAlviste/nvim-ts-context-commentstring", -- Required for JSX/TSX/HTML
  },
  event = "VeryLazy", -- Load when needed
  config = function()
    require("Comment").setup({
      padding = true, -- Add space after comment marker
      sticky = true, -- Keeps cursor position after commenting
      toggler = {
        line = "gcc", -- Toggle comment for the current line
        block = "gbc", -- Toggle comment for a block
      },
      opleader = {
        line = "gc", -- Comment lines in visual mode
        block = "gb", -- Comment block in visual mode
      },
      extra = {
        above = "gcO", -- Add comment above the line
        below = "gco", -- Add comment below the line
        eol = "gcA", -- Add comment at end of line
      },
      mappings = {
        basic = true, -- Enables gcc, gbc, gc{motion}
        extra = true, -- Enables gcO, gco, gcA
      },

      -- Use Treesitter for JSX/TSX/HTML comments
      pre_hook = function(ctx)
        local U = require("Comment.utils")

        local location = nil
        if ctx.ctype == U.ctype.block then
          location = require("ts_context_commentstring.utils").get_cursor_location()
        elseif ctx.cmotion == U.cmotion.line or ctx.cmotion == U.cmotion.v then
          location = require("ts_context_commentstring.utils").get_visual_start_location()
        end

        return require("ts_context_commentstring.internal").calculate_commentstring({
          key = ctx.ctype == U.ctype.line and "__default" or "__multiline",
          location = location,
        })
      end,
    })

    -- Setup ts-context-commentstring for auto-detecting comment styles
    require("ts_context_commentstring").setup({
      enable_autocmd = false, -- Prevent auto-updating in insert mode
    })
  end,
}
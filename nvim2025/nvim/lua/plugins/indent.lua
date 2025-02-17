return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    -- 🌈 Define Rainbow Indentation Colors BEFORE `ibl.setup()`
    local highlights = {
      "RainbowRed",
      "RainbowYellow",
      "RainbowBlue",
      "RainbowGreen",
      "RainbowCyan",
      "RainbowPurple",
    }

    -- Set the highlight colors
    vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75", nocombine = true })
    vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B", nocombine = true })
    vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF", nocombine = true })
    vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379", nocombine = true })
    vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2", nocombine = true })
    vim.api.nvim_set_hl(0, "RainbowPurple", { fg = "#C678DD", nocombine = true })

    -- Now require `ibl` after highlights are set
    local ibl = require("ibl")

    -- Ensure `ibl` is loaded before using it
    if not ibl then
      vim.notify("Error loading indent-blankline.nvim", vim.log.levels.ERROR)
      return
    end

    -- Setup indent-blankline (IBL)
    ibl.setup({
      indent = {
        char = "│", -- Use vertical lines for indentation
        highlight = highlights, -- Use rainbow colors for indentation
        smart_indent_cap = true, -- Limit indent guides to correct level
      },
      scope = {
        enabled = true, -- Enables highlighting of the current indentation level
        show_start = true, -- Show start of scope
        show_end = false, -- Disable scope end lines
      },
      exclude = {
        filetypes = { "help", "dashboard", "NvimTree", "lazy", "mason", "terminal" },
        buftypes = { "terminal", "nofile" },
      },
    })
  end,
}
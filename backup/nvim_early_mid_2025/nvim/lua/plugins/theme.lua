return {
  "olimorris/onedarkpro.nvim",
  priority = 1000, -- Ensure it loads first
  lazy = false, -- Load it immediately
  config = function()
    require("onedarkpro").setup({
      styles = {
        comments = "italic",
        keywords = "bold",
        functions = "italic,bold",
        variables = "NONE",
      },
      options = {
        transparency = true, -- Make background transparent
        terminal_colors = true, -- Apply colors to terminal
        cursorline = true, -- Highlight current line
        highlight_inactive_windows = false, -- Dim inactive windows
      },
    })

    -- Set colorscheme after configuring
    vim.cmd("colorscheme onedark") -- Change to "onelight" if you prefer a light theme
  end,
}
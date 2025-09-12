return {
  "sontungexpt/better-diagnostic-virtual-text",
  event = "LspAttach",
  config = function()
    require("better-diagnostic-virtual-text").setup({
      update_in_insert = false, -- Don't show diagnostics while in insert mode
      virt_text_pos = "inline", -- "inline" or "eol" (end of line)
      severity_sort = true, -- Sort errors first, then warnings, etc.
      signs = true, -- Show signs in the gutter
      update_event = { "DiagnosticChanged", "CursorHold" }, -- Auto-update when diagnostics change
      max_width = 80, -- Limit diagnostic width to 80 characters
      auto_wrap = true, -- Automatically wrap text if it exceeds the width
      trim_trailing_whitespace = true, -- Remove trailing whitespace in messages
      format = function(diagnostic) -- Custom format for messages
        return string.format("[%s] %s", diagnostic.source or "LSP", diagnostic.message)
      end,
    })

    -- Ensure Neovim diagnostic settings match
    vim.diagnostic.config({
      virtual_text = false, -- Disable default inline virtual text
      float = { border = "rounded" }, -- Use floating diagnostics with rounded borders
      severity_sort = true,
    })
  end
}
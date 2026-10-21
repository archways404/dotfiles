-- Bracket pair colorization, VS Code style:
--   ( [ {  nested brackets cycle gold → orchid → blue, like VS Code
--   the indent guide of the current scope takes the same color as its brackets
--   the bracket matching the one under the cursor is bold + underlined

local colors = {
  BracketGold = "#ffd700",
  BracketOrchid = "#da70d6",
  BracketBlue = "#179fff",
}
local order = { "BracketGold", "BracketOrchid", "BracketBlue" }

local function set_hl()
  for name, fg in pairs(colors) do
    vim.api.nvim_set_hl(0, name, { fg = fg })
  end
  vim.api.nvim_set_hl(0, "MatchParen", { bold = true, underline = true, sp = "#888888" })
end
set_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })

return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "LazyFile",
    init = function()
      vim.g.rainbow_delimiters = { highlight = order }
    end,
    config = function() end, -- works via g:rainbow_delimiters, no setup() needed
  },

  -- Color the active indent guide to match its bracket level
  {
    "folke/snacks.nvim",
    opts = {
      indent = {
        scope = { hl = order },
      },
    },
  },
}

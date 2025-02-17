return {
  "xiyaowong/transparent.nvim",
  config = function()
    require("transparent").setup({
      enable = true, -- Enable transparency globally
      extra_groups = { -- Remove background for ALL elements
        "Normal",
        "NormalNC",
        "Comment",
        "Constant",
        "Special",
        "Identifier",
        "Statement",
        "PreProc",
        "Type",
        "Underlined",
        "Todo",
        "String",
        "Function",
        "Conditional",
        "Repeat",
        "Operator",
        "Structure",
        "LineNr",
        "NonText",
        "SignColumn",
        "CursorLineNr",
        "EndOfBuffer",
        "FloatBorder",
        "NormalFloat",
        "NvimTreeNormal",
        "TelescopeNormal",
        "TelescopeBorder",
        "NeoTreeNormal",
        "VertSplit",
        "WinSeparator",
        "StatusLine",
        "StatusLineNC",
      },
      exclude = {}, -- No exclusions, full transparency
    })

    -- Make sure transparency is enabled at startup
    vim.cmd("TransparentEnable")
  end
}
-- Vivid syntax on a transparent editor, with a centered movement reminder.

-- Groups whose background gets cleared (keeps their text color)
local clear_bg = {
  "Normal", "NormalNC", "NormalSB", "NormalFloat", "FloatBorder", "FloatTitle",
  "Folded", "ColorColumn", "CursorColumn", "CursorLine", "CursorLineSign", "CursorLineFold",
  "SignColumn", "FoldColumn", "LineNr", "CursorLineNr", "EndOfBuffer",
  "StatusLine", "StatusLineNC", "TabLine", "TabLineFill", "WinBar", "WinBarNC",
  "Pmenu", "PmenuKind", "PmenuExtra", "PmenuSbar", "PmenuBorder",
  "PmenuShadow", "PmenuShadowThrough", "WinSeparator", "VertSplit", "MsgArea",
  "SnacksNormal", "SnacksNormalNC", "SnacksPicker", "SnacksPickerBorder",
  "SnacksDashboardNormal", "WhichKeyNormal", "WhichKeyBorder",
  "NeoTreeNormal", "NeoTreeNormalNC", "TreesitterContext",
  "BufferLineFill", "BufferLineBackground",
  "NoicePopup", "NoicePopupBorder", "NoicePopupmenu", "NoicePopupmenuBorder",
  "NoiceCmdlinePopup", "NoiceCmdlinePopupBorder", "NoiceConfirm", "NoiceMini",
  "SnacksInputNormal", "SnacksInputBorder", "LazyNormal", "MasonNormal",
}

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("transparent_vscode", { clear = true }),
  callback = function()
    for _, name in ipairs(clear_bg) do
      local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
      hl.bg = nil
      hl.ctermbg = nil
      vim.api.nvim_set_hl(0, name, hl)
    end
    if vim.g.colors_name == "vscode" then require("config.palette").apply() end
    -- Only the current line number lights up; the row stays transparent.
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ffffff", bold = true })
  end,
})

return {
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "dark",
      transparent = true,
      italic_comments = false,
      disable_nvimtree_bg = true,
    },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "vscode" } },

  -- Statusline in vscode colors, middle section transparent
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local ok, theme = pcall(require, "lualine.themes.vscode")
      if not ok then return end
      for _, mode in pairs(theme) do
        if mode.c then mode.c.bg = "NONE" end
      end
      opts.options = opts.options or {}
      opts.options.theme = theme
      opts.sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = {
          {
            "filename",
            path = 1, -- relative path distinguishes files with the same name
            symbols = { modified = "[+]", readonly = "[RO]", unnamed = "[No Name]", newfile = "[New]" },
          },
          "diagnostics",
        },
        lualine_x = {
          {
            function() return "⬅  ⬇  ⬆  ➡%=" end,
            cond = function() return vim.o.columns >= 90 and vim.fn.mode():sub(1, 1) == "n" end,
            color = { fg = "#FFFFFF", bold = true },
            separator = "",
          },
          "diff", "filetype",
        },
        lualine_y = {
          function()
            return string.format("Ln %d, Col %d", vim.fn.line("."), vim.fn.virtcol("."))
          end,
        },
        lualine_z = {
          {
            function() return os.date("%b %d") end,
            cond = function() return vim.o.columns >= 110 end,
          },
          function() return (os.date("%I:%M %p"):gsub("^0", "")) end,
        },
      }
    end,
  },
}

return {
  -- Add onedarkpro
  {
    "olimorris/onedarkpro.nvim",
  },

  -- Configure LazyVim to load onedarkpro
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark_vivid", -- or "onedark", "onelight", "tokyonight", etc. depending on your style
    },
  },
  
}
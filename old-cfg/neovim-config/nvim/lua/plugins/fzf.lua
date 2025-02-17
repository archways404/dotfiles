return {
  -- Add fzf-lua plugin
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- Optional icons support
    config = function()
      require("fzf-lua").setup({
        winopts = {
          height = 0.8, -- Window height
          width = 0.8, -- Window width
          row = 0.3, -- Window row position
          col = 0.5, -- Window column position
        },
        fzf_opts = {
          ["--layout"] = "reverse", -- Show results below the prompt
        },
      })
    end,
  },
}
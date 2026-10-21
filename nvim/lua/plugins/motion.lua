return {
  {
    "folke/snacks.nvim",
    opts = {
      animate = { fps = 60 }, -- power detection raises this to 120 on AC
      scroll = {
        enabled = true,
        animate = { duration = { step = 10, total = 160 }, easing = "outQuad" },
        animate_repeat = { delay = 100, duration = { step = 4, total = 60 }, easing = "linear" },
      },
    },
  },
  {
    "sphamba/smear-cursor.nvim",
    opts = function(_, opts)
      opts.time_interval = require("config.animation").fps == 120 and 8 or 17
    end,
  },
}

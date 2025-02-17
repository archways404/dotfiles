return {
  "ThePrimeagen/harpoon",
  keys = {
    -- Add files to the Harpoon menu
    { "<leader>ha", "<cmd>lua require('harpoon.mark').add_file()<cr>", desc = "Add File to Harpoon" },
    -- Open Harpoon menu
    { "<leader>hm", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", desc = "Harpoon Menu" },
    -- Navigate between files
    { "<leader>h1", "<cmd>lua require('harpoon.ui').nav_file(1)<cr>", desc = "Harpoon File 1" },
    { "<leader>h2", "<cmd>lua require('harpoon.ui').nav_file(2)<cr>", desc = "Harpoon File 2" },
    { "<leader>h3", "<cmd>lua require('harpoon.ui').nav_file(3)<cr>", desc = "Harpoon File 3" },
    { "<leader>h4", "<cmd>lua require('harpoon.ui').nav_file(4)<cr>", desc = "Harpoon File 4" },
    -- Cycle between Harpoon files
    { "<C-h>", "<cmd>lua require('harpoon.ui').nav_prev()<cr>", desc = "Previous Harpoon File" },
    { "<C-l>", "<cmd>lua require('harpoon.ui').nav_next()<cr>", desc = "Next Harpoon File" },

  },
  opts = {
    global_settings = {
      save_on_toggle = true, -- Save the Harpoon index when toggling the menu
      save_on_change = true, -- Automatically save when navigating between files
      enter_on_sendcmd = false, -- Prevent entering a terminal automatically
      tmux_autoclose_windows = false, -- Avoid auto-closing tmux panes
      excluded_filetypes = { "neo-tree", "snacks_dashboard" }, -- Ignore filetypes
    },
  },
  config = function(_, opts)
    require("harpoon").setup(opts)
  end,
}

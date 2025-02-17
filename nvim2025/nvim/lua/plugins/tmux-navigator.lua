return {
  "christoomey/vim-tmux-navigator",
  lazy = false, -- Ensure plugin loads at startup
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<C-Left>", "<cmd>TmuxNavigateLeft<CR>" },  -- Move left
    { "<C-Up>", "<cmd>TmuxNavigateUp<CR>" },      -- Move up
    { "<C-Down>", "<cmd>TmuxNavigateDown<CR>" },  -- Move down
    { "<C-Right>", "<cmd>TmuxNavigateRight<CR>" }, -- Move right
    { "<C-\\>", "<cmd>TmuxNavigatePrevious<CR>" }, -- Previous window
  },
}
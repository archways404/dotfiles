-- NEOVIDE SETUP
if vim.g.neovide then

  -- Helper function for transparency formatting
local alpha = function()
  return string.format("%x", math.floor(255 * vim.g.transparency or 0.8))
end

-- Function to check if running on battery or plugged in
function is_on_battery()
  local handle
  local result
  
  -- Check if we're on macOS
  handle = io.popen("pmset -g batt | grep 'Battery Power'")
  result = handle:read("*a")
  handle:close()
  
  -- If result is non-empty, it means we're on battery
  if result ~= "" then
    return true
  else
    return false
  end
end


  -- Put anything you want to happen only in Neovide here
  vim.opt.linespace = 0
  vim.g.neovide_scale_factor = 0.75
  vim.g.neovide_padding_top = 25
  vim.g.neovide_padding_bottom = 25
  vim.g.neovide_padding_right = 25
  vim.g.neovide_padding_left = 25
  vim.g.neovide_theme = 'auto'
  vim.g.experimental_layer_grouping = false
  vim.g.neovide_remember_window_size = true
  vim.g.neovide_cursor_smooth_blink = true
  vim.cmd('cd /Users/archways404/Developer/')
  vim.g.neovide_text_gamma = 0.0
  vim.g.neovide_text_contrast = 0.5

vim.g.neovide_transparency = 0.0
vim.g.transparency = 0.9
vim.g.neovide_background_color = "#0f1117" .. alpha()

vim.g.neovide_position_animation_length = 0.15
vim.g.neovide_scroll_animation_length = 0.2

vim.g.neovide_hide_mouse_when_typing = false
vim.g.neovide_refresh_rate_idle = 5
vim.g.neovide_remember_window_size = true
vim.g.neovide_cursor_smooth_blink = true

-- Set refresh rate based on power status
if is_on_battery() then
  vim.g.neovide_refresh_rate = 60
  vim.g.neovide_no_idle = false
else
  vim.g.neovide_refresh_rate = 144
  vim.g.neovide_no_idle = true
end


end

-- Set Space as the leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.showmode = false
vim.opt.wrap = true

-- Set global indentation settings
vim.opt.expandtab = true   -- Use spaces instead of tabs
vim.opt.shiftwidth = 2     -- Number of spaces per indentation level
vim.opt.tabstop = 2        -- Number of spaces per tab
vim.opt.smartindent = true -- Enable smart indentation

-- vim.opt.guicursor = "n-v-c-sm-i-ci-ve-r-cr-o:ver25"
vim.opt.virtualedit = "onemore"


-- CHECK OS AND SET SHELL
local uname = vim.loop.os_uname()
if uname.sysname == "Windows_NT" then
  -- Set shell options for Windows
  vim.o.shell = 'C:/"Program Files"/Git/bin/bash.exe'
  vim.o.shellcmdflag = "-s"
elseif uname.sysname == "Darwin" then
elseif uname.sysname == "Linux" then
end



-- Keybindings for different terminal layouts and instances
vim.keymap.set('n', '<leader>th', ':ToggleTerm direction=horizontal<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>tv', ':ToggleTerm direction=vertical<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>tf', ':ToggleTerm direction=float<CR>', { noremap = true, silent = true })


-- Optional: Key mapping to open Glow in normal mode
vim.api.nvim_set_keymap('n', '<leader>gm', ':Glow<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>c', ':lua require("Comment.api").toggle_current_linewise()<CR>', { noremap = true, silent = true })


-- Function to enable line wrapping and configure linebreak
local function configure_buffer_wrap()
  vim.wo.wrap = true                -- Enable line wrap
  vim.wo.linebreak = true           -- Wrap lines at word boundaries
  vim.wo.sidescrolloff = 5          -- Keep a margin of 5 characters from the edge
end

-- Keybinding to open new buffers with wrapping enabled
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "*",
  callback = configure_buffer_wrap,
})

-- Keybinding to trigger split and move tree (example from before)
vim.keymap.set('n', '<leader>bt', function()
  vim.cmd("vsplit")
  vim.cmd("wincmd l")
  vim.cmd("enew")
  require("nvim-tree.api").tree.open()
  vim.cmd("wincmd L")
end, { noremap = true, silent = true })



-- [ FUNCTIONS ]
local function clock()
  return os.date('%H:%M %p')  -- This will return time in the format HH:MM: AM/PM
end

-- Set up lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- LazyVim and additional plugins
  { "folke/lazy.nvim", event = "VeryLazy" },

  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup()
    end,
  },

  {
    "kylechui/nvim-surround",
    version = "*",   -- Use for stability, or you can specify a branch or commit
    event = "VeryLazy", -- You can trigger this to load lazily if needed
    config = function()
      require("nvim-surround").setup({
        -- Configuration options here, if needed. Defaults are fine for most cases.
      })
    end,
  },

  {
    "Wansmer/treesj",
    requires = { "nvim-treesitter/nvim-treesitter" }, -- Requires nvim-treesitter as a dependency
    config = function()
      require("treesj").setup({
        -- Configuration options if needed (default options are usually fine)
        use_default_keymaps = false, -- Disable default keymaps if you want to set custom ones
      })

      -- Example custom keybindings for splitting/joining code blocks
      vim.api.nvim_set_keymap('n', '<leader>ts', ':TSJSplit<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>tj', ':TSJJoin<CR>', { noremap = true, silent = true })
    end,
  },

  -- Add glow.nvim plugin
  {
    "ellisonleao/glow.nvim",
    config = true,  -- Enable default configuration
    cmd = "Glow",   -- Make the command available
  },

  {
    "luckasRanarison/tailwind-tools.nvim",
    config = function()
      require("tailwind-tools").setup({
        -- Optional configuration settings can be added here, like mappings or specific configurations.
      })

      -- Key mapping to toggle TailwindCSS color hints
      vim.api.nvim_set_keymap('n', '<leader>tc', ':TailwindColorToggle<CR>', { noremap = true, silent = true })
    end,
  },

  -- Indentation highlighting (ibl - indent-blankline version 3)
  {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl", -- Use "ibl" as the main entry point
  config = function()
    -- Define the rainbow colors, excluding green
    local indent_highlight = {
      "RainbowRed",
      "RainbowYellow",
      "RainbowBlue",
      "RainbowOrange",
      "RainbowViolet",
      "RainbowCyan",
    }

      -- Define the scope color (green)
      local scope_highlight = { "ScopeGreen" }

      local hooks = require "ibl.hooks"

      -- Create the highlight groups in the highlight setup hook
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        -- Rainbow colors for indent
        vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
        vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
        vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
        vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
        vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })

        -- Specific green for scope highlight
        vim.api.nvim_set_hl(0, "ScopeGreen", { fg = "#98C379", bold = true })  -- Green for scope with bold for emphasis
      end)

      -- Setup ibl with rainbow highlights and green scope highlight
      require("ibl").setup({
        indent = {
          char = "┊", -- Define character for indentation
          highlight = indent_highlight, -- Use rainbow colors without green for indent guides
        },
        scope = {
          enabled = true, -- Enable scope highlighting
          highlight = scope_highlight, -- Apply green color for the scope guides
          show_start = true, -- Show where the scope starts
          show_end = true, -- Show where the scope ends (optional)
        },
        whitespace = {
          highlight = indent_highlight, -- Apply the same indent highlight to whitespace
          remove_blankline_trail = false, -- Optional, prevents removing trailing whitespace
        },
        exclude = {
          filetypes = {
            "help",
            "alpha",
            "dashboard",
            "neo-tree",
            "Trouble",
            "trouble",
            "lazy",
            "mason",
            "notify",
            "toggleterm",
            "lazyterm",
          },
        },
      })

      -- Register the scope highlight hook to apply the green color to the scope
      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
    end,
  },

  {
    "uga-rosa/ccc.nvim",
    config = function()
        -- Basic setup for ccc.nvim
        require("ccc").setup({
            highlighter = {
                auto_enable = true, -- Automatically highlight colors in files
                lsp = true, -- Enable LSP support for color highlighting
            },
        })
        
        -- Keybinding for color picker
        vim.api.nvim_set_keymap('n', '<leader>cp', ":CccPick<CR>", { noremap = true, silent = true })
    end,
  },





  -- Add mini.nvim and its modules here
  {
    "echasnovski/mini.nvim",
    version = "*", -- Use the latest version
    config = function()
      -- Set up each mini.nvim module

      -- Mini comment: Easily toggle comments
      require("mini.comment").setup()

      -- Mini pairs: Auto-pairs for brackets, quotes, etc.
      require("mini.pairs").setup()

      -- Mini surround: Quickly add, delete, change surroundings
      require("mini.surround").setup({
        -- Custom setup can go here
      })

      -- Mini indentscope: Visualize the scope of indentation (updated)
      require("mini.indentscope").setup({
        draw = {
          delay = 100,  -- Adjust delay if needed
        },
        symbol = "┊",  -- Define character for indentation
      })

      -- Mini bufremove: Easily delete buffers while keeping window layout
      require("mini.bufremove").setup()
    end,
  },

  -- Add toggleterm.nvim
  {
    "akinsho/toggleterm.nvim",
    version = "*", -- Use the latest version
    config = function()
    require("toggleterm").setup({
      open_mapping = [[<C-\>]],
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = false, -- Start in normal mode
      persist_size = true,
      close_on_exit = true,
      direction = "horizontal", -- The layout direction
      size = function(term)
        -- Use a minimum size of 10 lines
        local min_size = 10

        -- You can adjust this dynamically if you want:
        -- If only one terminal is open, use the minimum size (e.g., 10 lines)
        if term.direction == "horizontal" then
          return min_size -- Set a fixed size for horizontal terminals
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4 -- Use 40% of the screen width for vertical terminals
        else
          return 20 -- Default size for floating terminals
        end
      end,
    })

        -- Create 3 terminals
    local Terminal = require('toggleterm.terminal').Terminal

    local terminal1 = Terminal:new({ id = 1 })
    local terminal2 = Terminal:new({ id = 2 })
    local terminal3 = Terminal:new({ id = 3 })

    -- Function to toggle terminals
    function _toggle_terminal1() terminal1:toggle() end
    function _toggle_terminal2() terminal2:toggle() end
    function _toggle_terminal3() terminal3:toggle() end

    -- Keybindings to toggle each terminal
    vim.api.nvim_set_keymap("n", "<leader>t1", "<cmd>lua _toggle_terminal1()<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>t2", "<cmd>lua _toggle_terminal2()<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>t3", "<cmd>lua _toggle_terminal3()<CR>", { noremap = true, silent = true })

    -- Keybinding to toggle all terminals
    vim.api.nvim_set_keymap("n", "<leader>ta", ":ToggleTermToggleAll<CR>", { noremap = true, silent = true })

    -- Keybinding to escape terminal mode
    vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })

    end,
  },

  

  -- Prettier formatter (for formatting on save)
  {
    "jose-elias-alvarez/null-ls.nvim",
    requires = { "nvim-lua/plenary.nvim" }, -- Ensure plenary is available
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettier, -- Add prettier for formatting
        },
        on_attach = function(client, bufnr)
          -- Updated on_attach function using server_capabilities
          if client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ async = true })
              end,
            })
          end
        end,
      })
    end,
  },

-- Dashboard plugin
{
  'glepnir/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    require('dashboard').setup({
      theme = 'hyper',
      config = {
        header = {
[[⣿⣿⣿⣿⣿⣿⣿⣤⡘⡍⠛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠋⡡⠊⠉⢀⠞⡻⠊⡐⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
[[⣿⣿⣿⣿⣿⣿⣿⡟⢿⠻⡀⠀⠀⠉⠛⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠉⠀⠀⣠⠞⠃⠀⢀⡀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
[[⣿⣿⣿⣿⣿⣿⣿⡄⠀⢀⠳⡀⠀⠀⠀⠀⠀⠈⠙⢿⣿⣿⡿⠟⣻⠟⠉⠀⠀⠀⠀⠀⠀⠠⠟⠁⠀⠀⠀⣠⡞⠀⠀⡀⠠⢜⣡⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
[[⣿⣿⣿⣿⣿⣿⣿⡇⠂⣰⣧⠐⡄⠀⠀⠀⠀⠀⣐⣮⣤⠤⠀⠨⠴⣶⡶⡶⠤⣀⠀⠀⠀⠀⠀⠀⠑⠲⣿⣋⣭⣛⠁⠠⠒⢵⣏⡀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
[[⣿⣿⣿⣿⣿⣿⣿⣹⣄⢘⣧⠀⢺⣆⠀⣠⠴⠛⠉⡱⠁⠀⠀⠀⠀⠀⠀⠀⠑⠢⡹⣦⡀⠀⠀⠀⠀⠀⠈⠻⡗⠀⠀⣀⣀⣒⡓⠧⡀⠀⢠⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
[[⣿⣿⣿⣿⣿⣿⣿⡈⣙⡿⠂⢈⡿⠋⠀⠀⠀⠈⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠙⢝⣆⠑⡄⠀⠀⠀⠀⠘⢶⣀⣈⠉⣻⢿⡧⠀⠀⣸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
[[⣿⣿⣿⣿⣿⣿⣿⣿⣶⣿⣀⠞⠀⠀⡀⠀⠠⠂⠀⠀⠀⠀⠀⠱⠀⠀⠠⠀⠀⠀⠀⠀⠻⡱⣼⡄⠀⠀⠀⠀⠈⢗⠤⣅⣴⣟⣇⣠⠀⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
[[⣿⣿⣿⣿⣿⣿⣿⣿⣟⡿⠁⠀⠀⡰⠀⠀⡆⢰⠀⠀⠀⠀⠀⠀⢇⠀⠀⠑⡀⠀⠀⠀⠠⡘⢜⢿⡄⠀⢀⠀⠀⠈⢇⢨⣿⣿⠃⢀⣴⡅⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
[[⣿⣿⣿⣿⣿⣿⣿⣿⠏⠀⠀⠀⢠⢃⠀⣰⠀⠘⠀⠀⠀⠀⣇⠀⢸⣧⡀⠀⠘⢦⠀⠠⠀⠉⢌⠺⣷⠀⠈⡆⠀⠀⠘⣿⢟⡿⢶⣿⡟⠘⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
[[⣿⣿⣿⣿⣿⣿⣿⡿⠃⠀⠀⠀⠀⣤⠇⢠⡟⡆⠀⡄⠀⠀⠀⠘⡄⠀⢏⠓⢄⠀⠣⠳⣄⠑⢄⠀⠣⡹⣇⠀⢰⠀⠀⠀⢳⠈⣰⣿⣿⢅⠘⣱⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
[[⣿⣿⣿⣿⣿⣿⠏⢠⠃⠀⠀⠀⢠⡟⠀⡾⠀⡇⠀⠂⠀⠀⠀⢳⠸⡄⠘⣄⣧⡦⡔⠒⠘⢯⡙⢍⠒⠚⢾⡀⠐⡆⠀⢡⠸⡮⠿⢫⡇⠘⡄⠀⢣⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
[[⣿⣿⣿⣿⠟⠁⢠⠃⠀⠀⠀⠀⢸⠇⣸⠇⢠⢡⢀⢸⡀⠀⠀⠸⣧⢳⡠⢻⠀⠑⢜⣆⠘⠄⠑⢌⡳⡀⠀⠇⠀⣧⠀⢸⠀⣇⡰⠋⠀⠀⣷⠀⡀⠡⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
[[⣿⣿⠟⠁⢀⣴⡏⠀⡄⠀⠀⠀⢸⢀⣿⡀⠤⢼⡞⡄⣷⡘⣆⠀⠹⣍⣷⡀⢣⠀⠀⣙⣻⣦⣤⣤⣭⣛⣲⣤⠀⢹⠀⠀⠀⣍⣠⣤⠁⡰⢿⠀⠰⡀⠱⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
[[⠋⢀⣠⣴⣿⣿⠁⠀⠁⠀⣸⠀⣾⠜⡏⠀⠀⠈⢿⡰⡘⣷⠘⣧⡀⠻⣿⣧⣀⣶⡿⢿⣿⣿⣿⣿⣿⡝⠻⣿⡶⠏⠀⠀⠀⢹⣿⣁⠜⡀⡿⣧⠀⡙⡄⠈⡢⡀⠀⠀⠀⠀⠀⠀⠀]],
[[⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⢿⠀⣿⠀⠃⠀⢀⣀⣨⠷⡑⢼⣧⡽⣷⣄⡀⢻⡠⡏⠀⠸⠏⢹⣿⣿⠙⡇⠀⣼⡇⠀⠀⠀⡆⣎⡙⢇⡰⢁⡇⣿⣧⣿⢮⠢⡀⠀⠑⠢⡀⠀⠀⠀⠀]],
[[⣿⣿⣿⣿⣿⡇⠀⠀⡇⠀⢸⡇⢻⠀⢐⣾⠟⣿⣿⣿⣗⠀⠈⠻⣆⠝⠣⢄⠈⠀⠀⠀⠰⣟⠹⢻⣿⠁⠀⠃⠁⠀⠀⢸⡇⣃⡁⢸⠁⣼⢧⢸⠙⡟⢷⣕⡌⠒⠤⣀⠀⠀⠀⠀⠀]],
[[⣿⣿⣿⣿⣿⡇⢸⠀⣧⠀⠸⣷⠘⣄⣾⠇⠀⠿⠛⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣈⣁⠉⣁⣀⣀⢀⡁⠀⠀⢸⡄⡏⣡⢟⣿⣿⠸⠀⠄⠸⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀]],
[[⣿⣿⢻⣿⣿⡇⢸⡆⢹⡄⠀⢹⣧⣻⡻⣇⠀⠀⢰⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⠟⢁⠠⠀⢸⠇⠀⠀⠸⠃⡗⣡⣾⡏⢿⠀⡇⡇⠀⠑⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
[[⣿⣿⣸⣿⣿⡇⢸⣷⡘⣷⡀⠈⣿⣿⣧⠈⠂⠀⠀⠉⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⣾⠀⠀⠀⣀⠀⣿⣿⢿⡇⢸⡄⠀⢩⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀]],
[[⣿⣿⢸⣿⣿⣿⠘⣿⣷⣹⣷⣄⠘⣎⢻⣇⠀⠔⢫⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡔⢸⠀⠀⠀⣿⢠⣿⡇⢸⡇⠀⢷⠀⠸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
[[⣿⣿⣿⣿⣿⣇⢿⣿⣿⣿⣿⡿⣏⠙⢿⠘⠒⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠊⢀⣼⠀⡄⢠⡏⢸⣿⣧⠘⣿⠀⠈⣇⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
[[⣿⣿⣿⣿⣿⣿⣾⣿⣿⣿⡿⢁⣿⠀⠸⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⠟⠁⢀⡏⠸⠀⣇⡆⣿⣿⣿⣇⣧⣿⡤⣶⣷⣸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
[[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢸⣇⠀⠸⡀⢸⡏⠓⣦⣤⣀⣀⠀⠀⠀⠀⠀⣀⣤⣾⣿⠟⠁⣠⠐⠁⠃⡆⢠⣾⢱⣿⡏⢉⣀⣠⣴⢤⣤⣬⣁⡒⠢⠤⣄⣀⡀⠀⠀⠀⠀⠀]],
[[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⣼⣿⠀⠀⠃⠘⡇⢀⣿⢸⣿⣿⣿⣿⣷⣶⣿⣿⣿⠟⠁⡠⠊⠀⠀⠀⣷⠁⢸⣟⣸⠿⠿⢧⡅⢱⣧⠀⡅⡇⠇⢳⠈⠁⠢⡀⠁⠀⠀⠀⠀⠀]],
[[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢃⣿⢸⡇⠀⠰⠀⣿⢸⣿⣿⣿⣿⣿⠟⢛⣩⣿⡏⠁⠔⠈⢀⣠⠄⠒⢸⡟⠀⣿⡇⡇⠀⠀⢸⠃⠘⣿⠀⡁⢀⢸⠈⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
[[⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⣼⣿⢸⣿⡀⠀⠀⢸⣿⣿⣿⡿⠋⠵⡽⠿⠛⠛⠋⠉⠉⠉⠁⡁⠀⠀⣿⡇⢠⣿⣹⠁⠀⠀⣿⠀⢰⢿⠀⠙⠘⢸⡀⣷⠀⠀⠀⠀⠀⠀⠀⠀]],
          "   ",
          "   ",
  [[_____        ___________              _____         __     __          _______     _______       _____    ______   _____             _____   ]],
  [[/      |_      \          \        _____\    \_      /  \   /  \        /      /|   |\      \    /      |_ |\     \ |     |       _____\    \  ]],
  [[/         \      \    /\    \      /     /|     |    /   /| |\   \      /      / |   | \      \  /         \\ \     \|     |      /    / \    | ]],
  [[|     /\    \      |   \_\    |    /     / /____/|   /   //   \\   \    |      /  |___|  \      ||     /\    \\ \           |     |    |  /___/| ]],
  [[|    |  |    \     |      ___/    |     | |____|/   /    \_____/    \   |      |  |   |  |      ||    |  |    \\ \____      |  ____\    \ |   || ]],
  [[|     \/      \    |      \  ____ |     |  _____   /    /\_____/\    \  |       \ \   / /       ||     \/      \\|___/     /| /    /\    \|___|/ ]],
  [[|\      /\     \  /     /\ \/    \|\     \|\    \ /    //\_____/\\    \ |      |\\/   \//|      ||\      /\     \   /     / ||    |/ \    \      ]],
  [[| \_____\ \_____\/_____/ |\______|| \_____\|    |/____/ |       | \____\|\_____\|\_____/|/_____/|| \_____\ \_____\ /_____/  /|\____\ /____/|     ]],
  [[| |     | |     ||     | | |     || |     /____/||    | |       | |    || |     | |   | |     | || |     | |     | |     | / | |   ||    | |     ]],
  [[ \|_____|\|_____||_____|/ \|_____| \|_____|    |||____|/         \|____| \|_____|\|___|/|_____|/  \|_____|\|_____| |_____|/   \|___||____|/      ]],
  [[                                          |____|/                                                                                                 ]],


          "Welcome to Neovim!",
        },
      }
    })
  end,
},

-- NvimTree for file tree browsing
{
  'nvim-tree/nvim-tree.lua',
  dependencies = {
    'nvim-tree/nvim-web-devicons', -- For file icons
  },
  config = function()
    require("nvim-tree").setup({
      view = {
        width = 40,  -- Set a default width
        adaptive_size = true,   -- Enable adaptive size
        side = "right",
      },
      renderer = {
        icons = {
          show = {
            file = true,         -- Enable icons for files
            folder = true,       -- Enable icons for folders
            folder_arrow = true, -- Enable icons for folder arrows
            git = true,          -- Enable icons for git statuses
          },
          glyphs = {
            default = "", -- Default file icon
            symlink = "",
            folder = {
              default = "",
              open = "",
              empty = "",
              empty_open = "",
              symlink = "",
              symlink_open = "",
            },
            git = {
              unstaged = "✗",
              staged = "✓",
              unmerged = "",
              renamed = "➜",
              untracked = "★",
              deleted = "",
              ignored = "◌",
            },
          },
        },
      },
      filters = {
        dotfiles = true, -- Show dotfiles
      },
    })

    -- Keybinding to toggle NvimTree
    vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

    -- Automatically open NvimTree and Dashboard
    vim.api.nvim_create_autocmd({ "VimEnter" }, {
  callback = function()
    -- Close NvimTree temporarily
    require("nvim-tree.api").tree.close()

    -- Delay to ensure the Dashboard opens after NvimTree is closed
    vim.defer_fn(function()
      -- Open the Dashboard
      vim.cmd("Dashboard")

      -- After opening the Dashboard, reopen NvimTree on the side
      vim.defer_fn(function()
        require("nvim-tree.api").tree.open()
        -- Ensure NvimTree is on the right side
        vim.cmd("wincmd L")
        vim.cmd("vertical resize 40")  -- Set the width of the NvimTree window
      end, 100) -- Another delay to ensure proper layout
    end, 100) -- Delay before opening the Dashboard
  end,
})

  end,
},





  { 'nvim-lua/plenary.nvim' }, 

  -- Add Harpoon for fast file navigation
  {
    'ThePrimeagen/harpoon',
    requires = { 'nvim-lua/plenary.nvim' }, -- Required by Harpoon
    config = function()
      require("harpoon").setup()

      -- Keybindings for Harpoon
      local mark = require('harpoon.mark')
      local ui = require('harpoon.ui')

      vim.keymap.set('n', '<leader>ha', mark.add_file, { noremap = true, silent = true }) -- Add file to Harpoon
      vim.keymap.set('n', '<leader>hh', ui.toggle_quick_menu, { noremap = true, silent = true }) -- Open Harpoon quick menu
      vim.keymap.set('n', '<leader>hn', ui.nav_next, { noremap = true, silent = true }) -- Navigate to next file in Harpoon
      vim.keymap.set('n', '<leader>hp', ui.nav_prev, { noremap = true, silent = true }) -- Navigate to previous file in Harpoon
    end,
  },

  
  -- Add your preferred plugins
  --{ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" },

  {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",  -- Automatically install/update treesitter parsers
    config = function()
      require("nvim-treesitter.configs").setup({
        -- List of parsers to install
        ensure_installed = { "javascript", "typescript", "html", "css", "lua" }, -- Add your required languages here

        highlight = {
          enable = true,                -- Enable syntax highlighting
        },
        indent = {
          enable = true,                -- Enable indentation based on Treesitter
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },
        textobjects = {
          enable = true,                -- Enable text objects
        },
      })
    end,
  },



  -- Mason setup for LSP and related tools
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "ts_ls", "lua_ls" }, -- Add servers you want to install
        automatic_installation = true,
      })
    end,
  },

  -- LSP configuration and Autocompletion
  { "neovim/nvim-lspconfig" }, -- LSP configuration
  { "hrsh7th/nvim-cmp" }, -- Main completion plugin
  { "hrsh7th/cmp-nvim-lsp" }, -- LSP completion source for nvim-cmp
  { "hrsh7th/cmp-buffer" }, -- Buffer completion source
  { "hrsh7th/cmp-path" }, -- Path completion source
  { "L3MON4D3/LuaSnip" }, -- Snippet engine
  { "saadparwaiz1/cmp_luasnip" }, -- Snippet completion source

  -- Add cmp-dotenv for .env file autocompletion
  {
    "SergioRibera/cmp-dotenv",
    requires = { "hrsh7th/nvim-cmp" },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        -- Add cmp-dotenv as a source for nvim-cmp
        sources = cmp.config.sources({
          { name = "nvim_lsp" },  -- LSP completion source
          { name = "luasnip" },   -- Snippet completion source
          { name = "buffer" },    -- Buffer completion source
          { name = "path" },      -- Path completion source
          { name = "dotenv",
          -- Defaults
          option = {
            path = '.',
            load_shell = true,
            item_kind = cmp.lsp.CompletionItemKind.Variable,
            eval_on_confirm = false,
            show_documentation = true,
            show_content_on_docs = true,
            documentation_kind = 'markdown',
            dotenv_environment = '.*',
            file_priority = function(a, b)
              -- Prioritizing local files
              return a:upper() < b:upper()
            end,
          } },    -- .env file completion source
        }),
      })
    end,
  },

  -- Telescope for fuzzy finding
  { "nvim-telescope/telescope.nvim" }, -- Fuzzy Finder

  -- Hop.nvim for easy motion navigation
  {
    'smoka7/hop.nvim',
    version = "*",
    config = function()
      require('hop').setup({
        multi_windows = true,
        keys = 'etovxqpdygfblzhckisuran',
        uppercase_labels = true,
      })
      vim.keymap.set({ 'n', 'v', 'x', 'o' }, '<leader>fj', function()
        require('hop').hint_words()
      end, { noremap = true, silent = true })
    end,
  },

  -- Lualine for statusbar
  {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true },
    config = function()
      require('lualine').setup({
        options = {
          theme = 'auto', -- Auto theme detection or set your preferred theme like 'gruvbox', 'dracula', etc.
          section_separators = '',
          component_separators = '',
        },
        sections = {
          lualine_a = {'mode'}, -- Displays current mode (e.g., normal, insert, visual)
          lualine_b = {'branch'}, -- Shows the Git branch
          lualine_c = {'filename'}, -- Displays the current filename
          lualine_x = {'filetype'}, -- Shows encoding, file format, and file type
          lualine_y = {'location'}, -- Shows the line and column number 
          lualine_z = {clock} -- Shows the time
        },
        inactive_sections = {
          lualine_a = {'filename'},
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {},
        -- Here is where we add the extension to hide Lualine from the Nvim tree
        extensions = { 'nvim-tree' } -- Disables Lualine in Nvim-tree
      })
    end,
  },

  -- Add the cyberdream theme
  {
    'scottmckendry/cyberdream.nvim',
    config = function()
      -- Apply the cyberdream theme
      vim.cmd('colorscheme cyberdream')

      -- Set transparent background
      vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'LineNr', { bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'StatusLine', { bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'VertSplit', { bg = 'NONE' })
    end,
  },
})

-- LSP Setup
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Function to attach completion and diagnostics when language server attaches to buffer
local on_attach = function(client, bufnr)
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
end

-- Loop through the servers listed in ensure_installed
local servers = { "pyright", "ts_ls", "lua_ls" }

for _, server in ipairs(servers) do
  if server == "lua_ls" then
    lspconfig.lua_ls.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = { globals = { "vim" } },
          workspace = { library = vim.api.nvim_get_runtime_file("", true) },
          telemetry = { enable = false },
        },
      },
    })
  else
    lspconfig[server].setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })
  end
end

-- Autocompletion setup
local cmp = require("cmp")

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }, {
    { name = "buffer" },
  }),
})

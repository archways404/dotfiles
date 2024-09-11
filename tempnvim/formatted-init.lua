-- Set Space as the leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.showmode = false

-- Set global indentation settings
vim.opt.expandtab = true       -- Use spaces instead of tabs
vim.opt.shiftwidth = 2         -- Number of spaces per indentation level
vim.opt.tabstop = 2            -- Number of spaces per tab
vim.opt.smartindent = true     -- Enable smart indentation

-- Keybindings for different terminal layouts and instances
vim.keymap.set('n', '<leader>th', ':ToggleTerm direction=horizontal<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>tv', ':ToggleTerm direction=vertical<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>tf', ':ToggleTerm direction=float<CR>', { noremap = true, silent = true })

-- Key mapping to open Glow in normal mode
vim.api.nvim_set_keymap('n', '<leader>gm', ':Glow<CR>', { noremap = true, silent = true })

-- Toggle comment keybinding
vim.api.nvim_set_keymap('n', '<leader>c', ':lua require("Comment.api").toggle_current_linewise()<CR>', { noremap = true, silent = true })

-- Automatically open NvimTree on VimEnter
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  callback = function()
    require("nvim-tree.api").tree.open()
  end,
})

-- [ FUNCTIONS ]
local function clock()
  return os.date('%H:%M %p')  -- This will return time in the format HH:MM AM/PM
end

-- Set up lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- Latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- LazyVim and additional plugins
  { "folke/lazy.nvim", event = "VeryLazy" },

  -- Comment.nvim for easy commenting
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- Which-key for keybindings helper
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup()
    end,
  },

  -- Nvim-surround for text surroundings
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end,
  },

  -- TreeSJ for code block manipulation
  {
    "Wansmer/treesj",
    requires = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("treesj").setup({
        use_default_keymaps = false, -- Disable default keymaps
      })
      vim.api.nvim_set_keymap('n', '<leader>ts', ':TSJSplit<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>tj', ':TSJJoin<CR>', { noremap = true, silent = true })
    end,
  },

  -- Glow for Markdown preview
  {
    "ellisonleao/glow.nvim",
    config = true, -- Enable default configuration
    cmd = "Glow",  -- Make the command available
  },

  -- Tailwind Tools for Tailwind CSS helpers
  {
    "luckasRanarison/tailwind-tools.nvim",
    config = function()
      require("tailwind-tools").setup()
      vim.api.nvim_set_keymap('n', '<leader>tc', ':TailwindColorToggle<CR>', { noremap = true, silent = true })
    end,
  },

  -- Indentation highlighting with IBL
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      local indent_highlight = {
        "RainbowRed", "RainbowYellow", "RainbowBlue", "RainbowOrange", "RainbowViolet", "RainbowCyan",
      }
      local hooks = require "ibl.hooks"
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
        vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
        vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
        vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
        vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
        vim.api.nvim_set_hl(0, "ScopeGreen", { fg = "#98C379", bold = true })
      end)
      require("ibl").setup({
        indent = { char = "┊", highlight = indent_highlight },
        scope = { enabled = true, highlight = { "ScopeGreen" } },
        whitespace = { highlight = indent_highlight },
      })
      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
    end,
  },

  -- CCC for color picker and highlighter
  {
    "uga-rosa/ccc.nvim",
    config = function()
      require("ccc").setup({ highlighter = { auto_enable = true, lsp = true } })
      vim.api.nvim_set_keymap('n', '<leader>cp', ":CccPick<CR>", { noremap = true, silent = true })
    end,
  },

  -- Mini.nvim for essential features
  {
    "echasnovski/mini.nvim",
    version = "*",
    config = function()
      require("mini.comment").setup()
      require("mini.pairs").setup()
      require("mini.surround").setup()
      require("mini.indentscope").setup({ draw = { delay = 100 }, symbol = "┊" })
      require("mini.bufremove").setup()
    end,
  },

  -- ToggleTerm for terminal management
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<C-\>]],
        hide_numbers = true,
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = false,
        persist_size = true,
        close_on_exit = true,
        direction = "horizontal",
        size = function(term) return term.direction == "horizontal" and 10 or vim.o.columns * 0.4 end,
      })
      local Terminal = require('toggleterm.terminal').Terminal
      local terminal1 = Terminal:new({ id = 1 })
      local terminal2 = Terminal:new({ id = 2 })
      local terminal3 = Terminal:new({ id = 3 })
      function _toggle_terminal1() terminal1:toggle() end
      function _toggle_terminal2() terminal2:toggle() end
      function _toggle_terminal3() terminal3:toggle() end
      vim.api.nvim_set_keymap("n", "<leader>t1", "<cmd>lua _toggle_terminal1()<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("n", "<leader>t2", "<cmd>lua _toggle_terminal2()<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("n", "<leader>t3", "<cmd>lua _toggle_terminal3()<CR>", { noremap = true, silent = true })
      vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })
    end,
  },

  -- Prettier for formatting on save
  {
    "jose-elias-alvarez/null-ls.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = { null_ls.builtins.formatting.prettier },
        on_attach = function(client, bufnr)
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

  -- NvimTree for file tree browsing
  {
    'nvim-tree/nvim-tree.lua',
    requires = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30, side = "left" },
        renderer = { highlight_opened_files = "icon", indent_markers = { enable = true } },
        filters = { dotfiles = false },
      })
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
    end,
  },

  -- Harpoon for fast file navigation
  {
    'ThePrimeagen/harpoon',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
      require("harpoon").setup()
      local mark = require('harpoon.mark')
      local ui = require('harpoon.ui')
      vim.keymap.set('n', '<leader>ha', mark.add_file, { noremap = true, silent = true })
      vim.keymap.set('n', '<leader>hh', ui.toggle_quick_menu, { noremap = true, silent = true })
      vim.keymap.set('n', '<leader>hn', ui.nav_next, { noremap = true, silent = true })
      vim.keymap.set('n', '<leader>hp', ui.nav_prev, { noremap = true, silent = true })
    end,
  },

  -- Treesitter for syntax highlighting and more
  {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "javascript", "typescript", "html", "css", "lua" },
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },
        textobjects = { enable = true },
      })
    end,
  },

  -- Mason for LSP management
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
        ensure_installed = { "pyright", "ts_ls", "lua_ls" },
        automatic_installation = true,
      })
    end,
  },

  -- LSP configuration and Autocompletion
  { "neovim/nvim-lspconfig" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },

  -- .env file autocompletion
  {
    "SergioRibera/cmp-dotenv",
    requires = { "hrsh7th/nvim-cmp" },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
          { name = "dotenv", option = { path = '.', load_shell = true } },
        }),
      })
    end,
  },

  -- Telescope for fuzzy finding
  { "nvim-telescope/telescope.nvim", tag = "0.1.0" },

  -- Hop for easy motion navigation
  {
    'smoka7/hop.nvim',
    version = "*",
    config = function()
      require('hop').setup({ multi_windows = true, keys = 'etovxqpdygfblzhckisuran', uppercase_labels = true })
      vim.keymap.set({ 'n', 'v', 'x', 'o' }, '<leader>fj', function() require('hop').hint_words() end, { noremap = true, silent = true })
    end,
  },

  -- Lualine for status bar
  {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true },
    config = function()
      require('lualine').setup({
        options = { theme = 'auto', section_separators = '', component_separators = '' },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch' },
          lualine_c = { 'filename' },
          lualine_x = { 'filetype' },
          lualine_y = { 'location' },
          lualine_z = { clock },
        },
        inactive_sections = { lualine_a = { 'filename' }, lualine_b = {}, lualine_c = {}, lualine_x = {}, lualine_y = {}, lualine_z = {} },
      })
    end,
  },

  -- Cyberdream theme
  {
    'scottmckendry/cyberdream.nvim',
    config = function()
      vim.cmd('colorscheme cyberdream')
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

local on_attach = function(client, bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
end

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
    lspconfig[server].setup({ on_attach = on_attach, capabilities = capabilities })
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

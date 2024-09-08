-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use { 'nvim-telescope/telescope.nvim', tag = '0.1.8', 
  requires = { {'nvim-lua/plenary.nvim'} } }

  use { 'rose-pine/neovim', as = 'rose-pine' }

  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
  }

  use ('nvim-treesitter/playground')
  use ('theprimeagen/harpoon')
  use ('mbbill/undotree')
  use ('tpope/vim-fugitive')

  use {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    requires = {
      {'williamboman/mason.nvim'},
      {'williamboman/mason-lspconfig.nvim'},
      {'neovim/nvim-lspconfig'},
      {'hrsh7th/nvim-cmp'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'L3MON4D3/LuaSnip'},
    }
  }

  use { 'github/copilot.vim' }

  use {
  'nvim-tree/nvim-tree.lua',
  requires = {
    'nvim-tree/nvim-web-devicons',
  },
  }

  use {
  'nvim-lualine/lualine.nvim',
  requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }

  use ('lukas-reineke/indent-blankline.nvim')

  use {
  'numToStr/Comment.nvim',
  config = function()
    require('Comment').setup {
      -- You can customize mappings or leave it as default
      -- Mappings: `gcc` to comment a line, `gc` in visual mode to comment a block
    }
  end
  }

  use {
  'iamcco/markdown-preview.nvim',
  run = 'cd app && npm install', -- Ensure you have Node.js installed
  setup = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  ft = { "markdown" },
  }

  use ('lewis6991/impatient.nvim')
  require('impatient')

  use {
  'windwp/nvim-autopairs',
  config = function()
    require('nvim-autopairs').setup {}
  end
  }

  use {"akinsho/toggleterm.nvim", tag = '*', config = function()
    require("toggleterm").setup()
  end}

    
end)
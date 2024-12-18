return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
    { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
    { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
    { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
    { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    { "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
    { "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
  },
  opts = {
    options = {
      -- stylua: ignore
      close_command = function(n) Snacks.bufdelete(n) end,
      -- stylua: ignore
      right_mouse_command = function(n) Snacks.bufdelete(n) end,
      diagnostics = "nvim_lsp",
      always_show_bufferline = false,
      diagnostics_indicator = function(_, _, diag)
        local icons = LazyVim.config.icons.diagnostics
        local ret = (diag.error and icons.Error .. diag.error .. " " or "")
          .. (diag.warning and icons.Warn .. diag.warning or "")
        return vim.trim(ret)
      end,
      offsets = {
        {
          filetype = "neo-tree",
          text = "Neo-tree",
          highlight = "Directory",
          text_align = "left",
        },
      },
      ---@param opts bufferline.IconFetcherOpts
      get_element_icon = function(opts)
        return LazyVim.config.icons.ft[opts.filetype]
      end,
    
      show_close_icon = false, -- Remove close button
      show_buffer_close_icons = false, -- Remove buffer close icons
      highlights = {
        fill = { fg = nil, bg = nil }, -- No background for the entire bufferline
        background = { fg = nil, bg = nil }, -- Dimmed foreground for unselected buffers
        buffer_selected = {
          fg = "#FFFFFF", -- Bright white for selected buffer text
          bg = nil, -- No background
          underline = true, -- Underline selected buffer
          sp = "#1666C7", -- Blue underline color
        },
        separator = { fg = nil, bg = nil }, -- No separators between buffers
        separator_selected = { fg = "#1666C7", bg = nil }, -- Blue separator for the selected buffer
        tab = { fg = "#7F849C", bg = nil }, -- Dimmed foreground for inactive tabs
        tab_selected = { 
          fg = "#FFFFFF", -- Bright white for selected buffer text
          bg = nil, -- No background
          underline = true, -- Underline selected buffer
          sp = "#1666C7", -- Blue underline color
          },
        close_button = { fg = nil, bg = nil }, -- Invisible close button
        close_button_selected = { fg = nil, bg = nil },
      },
    },
  },
  config = function(_, opts)
    require("bufferline").setup(opts)
    -- Fix bufferline when restoring a session
    vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
      callback = function()
        vim.schedule(function()
          pcall(nvim_bufferline)
        end)
      end,
    })
  end,
}
return {
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
}

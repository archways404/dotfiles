require("toggleterm").setup({
    open_mapping = [[<C-t>]],
    direction = 'horizontal',  
    shade_terminals = true,
    persist_size = true,
    persist_mode = true, -- if set to true (default) the previous terminal mode will be remembered
    shell = vim.o.shell,
    size = 10,
    auto_scroll = true, -- automatically scroll to the bottom on terminal output
    start_in_insert = false,

    winbar = {
      enabled = true,  -- Displays a winbar
      name_formatter = function(term)  -- Optional custom name for each terminal
        return "Terminal: " .. term.id
      end,
    },

})

-- Function to set keymaps for terminal
function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

-- Keymap to toggle terminals using count
vim.api.nvim_set_keymap('n', '<C-t>', '<Cmd>exe v:count1 . "ToggleTerm"<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-t>', '<Esc><Cmd>exe v:count1 . "ToggleTerm"<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<C-h>', '<cmd>lua require("toggleterm").toggle_all()<CR>', { noremap = true, silent = true })



local current_terminal_index = 1

function _G.cycle_focus_terminal()
  local terminals = require("toggleterm.terminal").get_all()
  local num_terminals = #terminals

  -- If no terminals are open, do nothing
  if num_terminals == 0 then return end

  -- Cycle through open terminals
  for i = 1, num_terminals do
    current_terminal_index = (current_terminal_index % num_terminals) + 1
    local term = terminals[current_terminal_index]
    if term:is_open() then
      term:focus()
      return
    end
  end
end

-- Keymap to cycle focus between open terminals
vim.api.nvim_set_keymap('n', '<C-n>', '<cmd>lua cycle_focus_terminal()<CR>', { noremap = true, silent = true })
require('lualine').setup {
  options = {
    icons_enabled = true,
    --theme = 'auto', -- Automatically adjust the status line color based on your theme
    theme = 'onedark',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {}
  },
  sections = {
    lualine_a = {'mode'},
    --lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_b = {'branch'},
    lualine_c = {'filename'},
    --lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_x = {'filetype'},
    lualine_z = {'location'}
  },
}

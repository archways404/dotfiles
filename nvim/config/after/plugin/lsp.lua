local lsp_zero = require('lsp-zero')

-- Initialize the lsp variable properly
local lsp = lsp_zero.preset("recommended")

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {
    "cssls",
    "html",
    "jsonls",
    "tsserver",
    "eslint",
    "rust_analyzer",
    "lua_ls",
    "pyright",
    "clangd",
    "bashls"
  },
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
  },
})

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  ['<C-Space>'] = cmp.mapping.complete(),
})

lsp.set_preferences({
  sign_icons = { }
})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.setup()

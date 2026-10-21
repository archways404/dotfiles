-- Offline contract test for the installer bootstrap, with package operations stubbed.
vim.g.dotfiles_bootstrap_test = true
local installed, seen, fail = {}, {}, nil
package.loaded.lazy = { load = function() end }
package.loaded['mason-registry'] = {
  refresh = function(callback) callback(true) end,
  get_package = function(name)
    seen[name] = true
    return {
      is_installing = function() return false end,
      is_installed = function() return installed[name] == true end,
      install = function(_, _, callback)
        installed[name] = name ~= fail
        callback(installed[name])
      end,
    }
  end,
}
package.loaded['mason-lspconfig.mappings'] = {
  get_mason_map = function() return { lspconfig_to_package = { lua_ls='lua-language-server', disabled='should-not-install', external='also-not-installed' } } end,
}
local parsers = {}
package.loaded['nvim-treesitter'] = {
  install = function(languages) return { wait = function() parsers = languages end } end,
  get_installed = function() return parsers end,
}
_G.LazyVim = { opts = function(name)
  if name == 'nvim-lspconfig' then return { servers = { lua_ls={}, disabled={enabled=false}, external={mason=false} } } end
  if name == 'mason.nvim' then return { ensure_installed={'stylua'} } end
  if name == 'nvim-treesitter' then return { ensure_installed={'lua','javascript'} } end
end }
local bootstrap = dofile('scripts/bootstrap_nvim.lua')
bootstrap()
assert(installed['lua-language-server'])
assert(not seen['should-not-install'] and not seen['also-not-installed'])
assert(#parsers == 2)
installed, fail = {}, 'stylua'
local success, error = pcall(bootstrap)
assert(not success and tostring(error):find('stylua', 1, true), 'package failure must prevent success')
print('Bootstrap package selection, parser wait and failure handling passed.')
vim.cmd('qa!')

-- Invoked by the installer after restoring the plugin lockfile.
local function bootstrap()
  vim.api.nvim_exec_autocmds('User', { pattern = 'VeryLazy' })
  require('lazy').load({ plugins = { 'mason.nvim', 'mason-lspconfig.nvim', 'nvim-lspconfig', 'nvim-treesitter' } })
  local registry = require('mason-registry')
  local refreshed, refresh_ok = false, false
  registry.refresh(function(success) refreshed, refresh_ok = true, success end)
  assert(vim.wait(120000, function() return refreshed end, 100), 'Mason registry refresh timed out')
  assert(refresh_ok, 'Mason registry refresh failed; check network access')
  local tools = { 'prettier', 'stylua', 'shfmt', 'shellcheck', 'rust-analyzer', 'codelldb', 'debugpy' }
  local mapping = require('mason-lspconfig.mappings').get_mason_map().lspconfig_to_package
  for name, config in pairs(LazyVim.opts('nvim-lspconfig').servers or {}) do
    if name ~= '*' and config ~= false and (type(config) ~= 'table' or (config.enabled ~= false and config.mason ~= false)) and mapping[name] then
      tools[#tools + 1] = mapping[name]
    end
  end
  vim.list_extend(tools, LazyVim.opts('mason.nvim').ensure_installed or {})
  local seen, failures = {}, {}
  for _, name in ipairs(tools) do
    if not seen[name] then
      seen[name] = true
      local ok, package = pcall(registry.get_package, name)
      if not ok then
        failures[#failures + 1] = name .. ': not in registry'
      else
        if package:is_installing() then
          assert(vim.wait(600000, function() return not package:is_installing() end, 100), name .. ': existing installation timed out')
        end
        if not package:is_installed() then
          print('Installing language tool: ' .. name)
          local done, installed = false, false
          package:install({}, function(success) done, installed = true, success end)
          assert(vim.wait(600000, function() return done end, 100), name .. ': installation timed out')
          if not installed then failures[#failures + 1] = name .. ': installation failed (see :MasonLog)' end
        end
      end
    end
  end
  local treesitter = require('nvim-treesitter')
  local languages = LazyVim.opts('nvim-treesitter').ensure_installed or { 'lua', 'javascript', 'typescript', 'tsx' }
  print('Installing syntax parsers...')
  treesitter.install(languages):wait(600000)
  assert(vim.wait(600000, function()
    local installed = treesitter.get_installed()
    for _, language in ipairs(languages) do if not vim.tbl_contains(installed, language) then return false end end
    return true
  end, 100), 'Some syntax parsers did not finish installing. Run :TSLog.')
  assert(#failures == 0, table.concat(failures, '\n'))
  print('Plugins, language tools and syntax parsers are ready.')
end
if vim.g.dotfiles_bootstrap_test then return bootstrap end
local ok, error = xpcall(bootstrap, debug.traceback)
if ok then vim.cmd('qa!') else print(error); vim.cmd('cquit 1') end

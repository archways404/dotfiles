-- Same physical P / L + two adjacent home-row keys on US and Swedish layouts.
local M = {}
local saved = {}
local layouts = {
  us = { p = 'k', l = 'h', [';'] = 'j', ["'"] = 'l' },
  se = { p = 'k', l = 'h', ['ö'] = 'j', ['ä'] = 'l' },
}
local descriptions = { k = 'up', h = 'left', j = 'down', l = 'right' }
local function restore(buf)
  if not saved[buf] then return end
  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_call(buf, function()
      for _, entry in ipairs(saved[buf]) do
        local current = vim.fn.maparg(entry.key, entry.mode, false, true)
        if current.buffer == 1 and current.desc == entry.desc then
          vim.keymap.del(entry.mode, entry.key, { buffer = buf })
          if entry.old.buffer == 1 then vim.fn.mapset(entry.mode, false, entry.old) end
        end
      end
    end)
  end
  saved[buf] = nil
end
function M.attach(buf)
  restore(buf)
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= '' then return end
  saved[buf] = {}
  local layout = require('config.keyboard').get()
  vim.api.nvim_buf_call(buf, function()
    local keys = vim.tbl_extend('force', layouts[layout], { h = '<Nop>', j = '<Nop>', k = '<Nop>' })
    for key, rhs in pairs(keys) do
      for _, mode in ipairs({'n','x'}) do
        local desc = 'Physical cluster: ' .. (descriptions[rhs] or 'old movement disabled')
        saved[buf][#saved[buf]+1] = { key=key, mode=mode, desc=desc, old=vim.fn.maparg(key,mode,false,true) }
        -- No remapping: right movement must not recurse through the cluster's l mapping.
        vim.keymap.set(mode,key,rhs,{buffer=buf,silent=true,desc=desc})
      end
    end
  end)
end
function M.refresh()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then M.attach(buf) end
  end
end
function M.setup()
  local group = vim.api.nvim_create_augroup('dotfiles_cluster',{clear=true})
  vim.api.nvim_create_autocmd({'BufEnter','FileType','TermOpen'},{group=group,callback=function(event) M.attach(event.buf) end})
  vim.api.nvim_create_autocmd('BufWipeout',{group=group,callback=function(event) saved[event.buf]=nil end})
  vim.api.nvim_create_autocmd('User',{group=group,pattern='DotfilesKeyboardChanged',callback=M.refresh})
  -- US ; and apostrophe are movement keys; retain their original commands here.
  vim.keymap.set('n', '<leader>m;', ';', { desc = 'Repeat last f/t character search' })
  vim.keymap.set('n', "<leader>m'", "'", { desc = 'Jump to mark (then mark letter)' })
  M.refresh()
end
return M

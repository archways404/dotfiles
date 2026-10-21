local M = {}
local scroll_keys = { ["<Up>"] = { "20<C-y>", "Scroll up 20 lines" }, ["<Down>"] = { "20<C-e>", "Scroll down 20 lines" } }
local function scrolling(buf, enabled)
  for key, info in pairs(scroll_keys) do
    for _, mode in ipairs({ "n", "x" }) do
      local mapping = vim.fn.maparg(key, mode, false, true)
      if enabled then
        vim.keymap.set(mode, key, info[1], { buffer = buf, silent = true, desc = info[2] })
      elseif mapping.buffer == 1 and mapping.desc == info[2] then
        vim.keymap.del(mode, key, { buffer = buf })
      end
    end
  end
end
function M.attach(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  vim.api.nvim_buf_call(buf, function() scrolling(buf, vim.bo[buf].buftype == "") end)
end
function M.setup()
  vim.api.nvim_create_autocmd({ "BufEnter", "FileType", "TermOpen" }, {
    group = vim.api.nvim_create_augroup("dotfiles_movement", { clear = true }),
    callback = function(event) M.attach(event.buf) end,
  })
  M.attach(vim.api.nvim_get_current_buf())
end
return M

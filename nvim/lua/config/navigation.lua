local M = {}
local last_editor
local function is_editor(win)
  return win and vim.api.nvim_win_is_valid(win)
    and vim.bo[vim.api.nvim_win_get_buf(win)].buftype == ""
    and vim.api.nvim_win_get_config(win).relative == ""
end
function M.explorer()
  return Snacks.picker.get({ source = "explorer" })[1]
end
function M.focus_editor(picker)
  picker = picker or M.explorer()
  local win = picker and picker.main or last_editor
  if not is_editor(win) then win = last_editor end
  if not is_editor(win) then
    for _, candidate in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if is_editor(candidate) then win = candidate; break end
    end
  end
  if is_editor(win) then vim.api.nvim_set_current_win(win) end
end
function M.root()
  local win = vim.api.nvim_get_current_win()
  if not is_editor(win) then
    local picker = M.explorer()
    win = picker and picker.main or last_editor
  end
  local buf = is_editor(win) and vim.api.nvim_win_get_buf(win) or vim.api.nvim_get_current_buf()
  return LazyVim.root({ buf = buf })
end
function M.focus_explorer()
  local picker = M.explorer()
  if picker then
    local root = M.root()
    if picker:cwd() ~= root then picker:set_cwd(root) end
    picker:focus("list")
  else
    Snacks.explorer({ cwd = M.root() })
  end
end
function M.toggle_focus()
  if is_editor(vim.api.nvim_get_current_win()) then M.focus_explorer() else M.focus_editor() end
end
function M.toggle_explorer()
  local picker = M.explorer()
  if picker then picker:close() else M.focus_explorer() end
end
function M.setup()
  vim.api.nvim_create_autocmd("WinEnter", {
    group = vim.api.nvim_create_augroup("dotfiles_navigation", { clear = true }),
    callback = function() if is_editor(vim.api.nvim_get_current_win()) then last_editor = vim.api.nvim_get_current_win() end end,
  })
  if is_editor(vim.api.nvim_get_current_win()) then last_editor = vim.api.nvim_get_current_win() end
end
return M

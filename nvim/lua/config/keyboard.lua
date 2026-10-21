-- Machine preferences live in stdpath("state"), outside the shared repository.
local M = {}
local path = vim.fn.stdpath("state") .. "/dotfiles-keyboard.json"
local aliases = { ["+"] = "$", ["ö"] = "[", ["ä"] = "]", ["Ö"] = "{", ["Ä"] = "}", ["¤"] = "$", ["€"] = "$", ["§"] = "`" }
local modes = { "n", "x", "o" }
local current = "us"
local function valid(value) return value == "us" or value == "se" end

function M.set(layout, persist)
  if not valid(layout) then
    vim.notify("Use :KeyboardLayout us or :KeyboardLayout se", vim.log.levels.ERROR)
    return false
  end
  for lhs, rhs in pairs(aliases) do
    if current == "se" then
      for _, mode in ipairs(modes) do pcall(vim.keymap.del, mode, lhs) end
    end
    if layout == "se" then
      vim.keymap.set(modes, lhs, rhs, { remap = true, desc = rhs .. " (Swedish layout)" })
    end
  end
  current = layout
  vim.g.dotfiles_keyboard = layout
  vim.api.nvim_exec_autocmds("User", { pattern = "DotfilesKeyboardChanged", data = { layout = layout } })
  if persist then
    vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
    vim.fn.writefile({ vim.json.encode({ layout = layout }) }, path)
    vim.notify("Keyboard layout: " .. layout .. " (saved for this machine)")
  end
  return true
end

function M.get() return current end

function M.setup()
  local layout = "us"
  if vim.fn.filereadable(path) == 1 then
    local ok, settings = pcall(function() return vim.json.decode(table.concat(vim.fn.readfile(path), "\n")) end)
    if ok and type(settings) == "table" and valid(settings.layout) then layout = settings.layout end
  end
  -- Explicit per-process override, useful when switching terminal profiles.
  if valid(vim.env.NVIM_KEYBOARD) then layout = vim.env.NVIM_KEYBOARD end
  M.set(layout, false)
  vim.api.nvim_create_user_command("KeyboardLayout", function(args)
    if args.args == "" then
      vim.ui.select({ "us", "se" }, { prompt = "Keyboard layout (current: " .. current .. ")" }, function(choice)
        if choice then M.set(choice, true) end
      end)
    else
      M.set(args.args, true)
    end
  end, { nargs = "?", complete = function() return { "us", "se" } end, desc = "Switch US/Swedish keyboard helpers" })
end

return M

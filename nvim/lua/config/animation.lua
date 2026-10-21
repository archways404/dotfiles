-- Quiet, asynchronous power detection. Unknown power state uses the battery cap.
local M = { profile = "auto", fps = 60, external = nil }
local timer, job
local stopped = false
function M.parse_macos(text)
  if text:find("'AC Power'", 1, true) then return true end
  if text:find("'Battery Power'", 1, true) then return false end
end
function M.parse_windows(text)
  local status = tonumber(vim.trim(text))
  if status == 1 then return true elseif status == 0 then return false end
end
function M.linux_power(supplies)
  local battery, online, charging = false, false, false
  for _, supply in ipairs(supplies) do
    if supply.type == "Battery" then
      battery = true
      if supply.status == "Discharging" then return false end
      charging = charging or supply.status == "Charging"
    else
      online = online or supply.online == "1"
    end
  end
  if online or charging or not battery then return true end
end
function M.apply(external)
  M.external = external
  M.fps = (M.profile == "performance" or (M.profile == "auto" and external == true)) and 120 or 60
  if _G.Snacks then Snacks.config.animate.fps = M.fps end
  local smear = package.loaded["smear_cursor"]
  if smear then smear.time_interval = M.fps == 120 and 8 or 17 end
end
local function read(path)
  local file = io.open(path, "r")
  if not file then return "" end
  local value = vim.trim(file:read("*a"))
  file:close()
  return value
end
function M.refresh()
  if stopped or job then return end
  local system = vim.uv.os_uname().sysname
  local command, parse
  if system == "Darwin" then
    command, parse = { "/usr/bin/pmset", "-g", "batt" }, M.parse_macos
  elseif system == "Windows_NT" then
    command = { "powershell.exe", "-NoProfile", "-NonInteractive", "-Command",
      "Add-Type -AssemblyName System.Windows.Forms; [Console]::Write([int][System.Windows.Forms.SystemInformation]::PowerStatus.PowerLineStatus)" }
    parse = M.parse_windows
  elseif system == "Linux" then
    local supplies = {}
    for _, path in ipairs(vim.fn.glob("/sys/class/power_supply/*", false, true)) do
      supplies[#supplies + 1] = { type = read(path .. "/type"), status = read(path .. "/status"), online = read(path .. "/online") }
    end
    -- WSL cannot generally see the host's battery through sysfs.
    local external = M.linux_power(supplies)
    if #supplies == 0 and (vim.env.WSL_DISTRO_NAME or vim.env.WSL_INTEROP) then external = nil end
    M.apply(external)
    return
  else
    M.apply(nil)
    return
  end
  job = vim.system(command, { text = true, timeout = 3000, env = { LC_ALL = "C" } }, function(result)
    vim.schedule(function()
      job = nil
      if not stopped then
        local external
        if result.code == 0 then external = parse(result.stdout or "") end
        M.apply(external)
      end
    end)
  end)
end
function M.set_profile(profile)
  if not vim.tbl_contains({ "auto", "battery", "performance" }, profile) then return false end
  M.profile = profile
  M.apply(M.external)
  return true
end
function M.setup()
  stopped = false
  local group = vim.api.nvim_create_augroup("dotfiles_animation", { clear = true })
  vim.api.nvim_create_user_command("AnimationProfile", function(args)
    if args.args ~= "" and not M.set_profile(args.args) then
      vim.notify("Use :AnimationProfile auto, battery, or performance", vim.log.levels.ERROR)
      return
    end
    M.refresh()
    vim.notify(("Animations: %s · %d FPS target"):format(M.profile, M.fps))
  end, { nargs = "?", complete = function() return { "auto", "battery", "performance" } end,
    desc = "Animation FPS profile (auto follows external power)" })
  vim.api.nvim_create_autocmd("FocusGained", { group = group, callback = M.refresh })
  vim.api.nvim_create_autocmd("User", { group = group, pattern = "LazyLoad", callback = function() M.apply(M.external) end })
  vim.api.nvim_create_autocmd("VimLeavePre", { group = group, callback = function()
    stopped = true
    if timer then timer:stop(); timer:close(); timer = nil end
    if job then pcall(function() job:kill(15) end) end
  end })
  if timer then timer:stop(); timer:close() end
  timer = assert(vim.uv.new_timer())
  timer:start(60000, 60000, vim.schedule_wrap(M.refresh))
  timer:unref()
  M.apply(M.external)
  M.refresh()
end
return M

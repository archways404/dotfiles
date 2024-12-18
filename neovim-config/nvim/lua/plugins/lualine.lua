return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function()
    return {
      options = {
        icons_enabled = true,
        theme = {
          normal = {
            a = {bg = '#1666c7', fg = '#000000', gui = 'bold'},
            b = {bg = nil, fg = '#00ff00'},
            c = {bg = nil, fg = '#ffffff'},
            x = {bg = nil, fg = '#ffffff'},
            y = {bg = nil, fg = '#ffffff'},
            z = {bg = nil, fg = '#ffffff'}
          },
          insert = {
            a = {bg = '#0eb50e', fg = '#000000', gui = 'bold'},
            b = {bg = nil, fg = '#00ff00'},
            c = {bg = nil, fg = '#ffffff'},
            x = {bg = nil, fg = '#ffffff'},
            y = {bg = nil, fg = '#ffffff'},
            z = {bg = nil, fg = '#ffffff'}
          },
          visual = {
            a = {bg = '#b51010', fg = '#000000', gui = 'bold'},
            b = {bg = nil, fg = '#00ff00'},
            c = {bg = nil, fg = '#ffffff'},
            x = {bg = nil, fg = '#ffffff'},
            y = {bg = nil, fg = '#ffffff'},
            z = {bg = nil, fg = '#ffffff'}
          },
          replace = {
            a = {bg = '#ff0000', fg = '#000000', gui = 'bold'},
            b = {bg = nil, fg = '#00ff00'},
            c = {bg = nil, fg = '#ffffff'},
            x = {bg = nil, fg = '#ffffff'},
            y = {bg = nil, fg = '#ffffff'},
            z = {bg = nil, fg = '#ffffff'}
          },
          command = {
            a = {bg = '#9516c7', fg = '#000000', gui = 'bold'},
            b = {bg = nil, fg = '#00ff00'},
            c = {bg = nil, fg = '#ffffff'},
            x = {bg = nil, fg = '#ffffff'},
            y = {bg = nil, fg = '#ffffff'},
            z = {bg = nil, fg = '#ffffff'}
          },
          inactive = {
            a = {bg = '#00ff00', fg = '#000000', gui = 'bold'},
            b = {bg = nil, fg = '#00ff00'},
            c = {bg = nil, fg = '#ebdbb2'},
            x = {bg = nil, fg = '#ffffff'},
            y = {bg = nil, fg = '#ffffff'},
            z = {bg = nil, fg = '#ffffff'}
          },
        },
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = { "snacks_dashboard", "neo-tree" }, -- Disable lualine for dashboard and NvimTree
          winbar = {},
        },
        ignore_focus = { "snacks_dashboard", "neo-tree" }, -- Also ignore focus for these filetypes
        always_divide_middle = true,
        globalstatus = false,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = {
          function()
            return os.date("%I:%M %p")
          end,
        },
        lualine_y = {},
        lualine_z = {
          function()
            local command = ""
            local sysname = vim.loop.os_uname().sysname
            if sysname == "Darwin" then
              command = "pmset -g batt | grep -Eo '\\d+%' | head -1"
            elseif sysname == "Linux" then
              command = "acpi -b | grep -Eo '\\d+%' | head -1"
            elseif sysname == "Windows_NT" then
              command = [[powershell -Command "(Get-WmiObject Win32_Battery).EstimatedChargeRemaining"]]
            else
              return " N/A"
            end
            local handle = io.popen(command)
            if handle then
              local result = handle:read("*a"):match("(%d+)")
              handle:close()
              if result then
                local battery_level = tonumber(result)
                local hl_group = "BatteryStatus"
                local battery_icon = ""
                if battery_level > 90 then
                  battery_icon = ""
                elseif battery_level > 80 then
                  battery_icon = ""
                elseif battery_level > 60 then
                  battery_icon = ""
                elseif battery_level > 40 then
                  battery_icon = ""
                elseif battery_level > 20 then
                  battery_icon = ""
                else
                  battery_icon = ""
                end
                if sysname == "Linux" then
                  local charging = io.popen("acpi -b | grep -i 'charging'")
                  if charging:read("*a") ~= "" then
                    battery_icon = ""
                  end
                  charging:close()
                elseif sysname == "Darwin" then
                  local charging = io.popen("pmset -g batt | grep -i 'charging'")
                  if charging:read("*a") ~= "" then
                    battery_icon = ""
                  end
                  charging:close()
                end
                if battery_level > 75 then
                  vim.api.nvim_set_hl(0, hl_group, { fg = "#00ff00", bg = nil })
                elseif battery_level > 25 then
                  vim.api.nvim_set_hl(0, hl_group, { fg = "#ffff00", bg = nil })
                else
                  vim.api.nvim_set_hl(0, hl_group, { fg = "#ff0000", bg = nil })
                end
                return "%#" .. hl_group .. "#" .. battery_icon .. " " .. result .. "%" .. "%*"
              end
            end
            return " N/A"
          end,
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = { "nvim-tree", "quickfix" },
    }
  end,
}

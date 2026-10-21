local M = {}
function M.setup()
  vim.api.nvim_create_user_command("Overview", function()
    local entries = {
      { "Animation power profile               :AnimationProfile", function()
        vim.ui.select({ "auto", "battery", "performance" }, { prompt = "Animation profile" }, function(choice)
          if choice then vim.cmd.AnimationProfile(choice) end
        end)
      end },
      { "Explorer / editor focus               Space e", function() require("config.navigation").toggle_focus() end },
      { "Find files in current project         Space Space", function() Snacks.picker.files({ cwd = require("config.navigation").root() }) end },
      { "Folding / block controls              Space z", function() require("which-key").show({ keys = "<leader>z" }) end },
      { "Commenting / function navigation      Space c", function() require("which-key").show({ keys = "<leader>c" }) end },
      { "Search all shortcuts                  Space sk", function() Snacks.picker.keymaps() end },
      { "Search commands                       Space sC", function() Snacks.picker.commands() end },
      { "Customization toggles                 Space u", function() require("which-key").show({ keys = "<leader>u" }) end },
      { "US / Swedish keyboard                 :KeyboardLayout", function() vim.cmd.KeyboardLayout() end },
      { "Plugins and updates                   :Lazy", function() vim.cmd.Lazy() end },
      { "Optional features / languages         :LazyExtras", function() vim.cmd.LazyExtras() end },
      { "Language servers / formatters         :Mason", function() vim.cmd.Mason() end },
      { "Check this machine                    :checkhealth", function() vim.cmd.checkhealth() end },
      { "Setup guide and customization files", function() vim.cmd.edit(vim.fn.stdpath("config") .. "/README.md") end },
      { "Browse configuration files", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end },
    }
    vim.ui.select(entries, {
      prompt = "Neovim overview · " .. require("config.keyboard").get():upper() .. " keyboard",
      format_item = function(item) return item[1] end,
    }, function(item) if item then item[2]() end end)
  end, { desc = "Find actions, shortcuts and setup customizations" })
end
return M

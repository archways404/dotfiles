return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- Icons support

  config = function()
    -- Load the "material" theme and ensure it exists
    local success, custom_material = pcall(require, "lualine.themes.material")
    if not success then
      print("Error: lualine.themes.material not found")
      return
    end

    -- Define brighter custom colors
    local colors = {
      normal = "#61afef", -- Brighter Blue
      insert = "#3afa00", -- Brighter Green
      visual = "#bb05f2", -- Brighter Purple
      replace = "#fa0000", -- Brighter Red
      command = "#fc6f03", -- Yellow-Gold for Command mode
    }

    -- Apply custom colors
    for mode, color in pairs(colors) do
      if custom_material[mode] and custom_material[mode].a then
        custom_material[mode].a.bg = color
      end
    end

    -- Function to apply transparency safely to all sections except lualine_a
    local function set_transparent(mode)
      if custom_material[mode] then
        -- Keep `a` section with custom color, make `b` and `c` transparent
        if custom_material[mode].b then custom_material[mode].b.bg = "NONE" end
        if custom_material[mode].c then custom_material[mode].c.bg = "NONE" end
      end
    end

    -- Apply transparency to all modes except `lualine_a`
    for _, mode in pairs({ "normal", "insert", "visual", "replace", "command", "inactive" }) do
      set_transparent(mode)
    end

    -- Setup Lualine with the modified theme
    require("lualine").setup({
      options = {
        theme = custom_material, -- Use modified theme
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
        icons_enabled = true, -- Enable fancy icons
        globalstatus = true, -- One statusline for all splits
      },
      sections = {
        lualine_a = { "mode" }, -- Keep this with custom colors
        lualine_b = { "branch" }, -- Git & LSP info
        lualine_c = {
          {
            "filename",
            path = 1, -- Show relative path
            symbols = {
              modified = " ●", -- Indicator for unsaved changes
              readonly = " ", -- Lock icon for readonly files
              unnamed = "[No Name]",
            },
          },
        },
        lualine_x = { "diagnostics" },
        lualine_y = {
          {
            "filetype",
            icon_only = true, -- Show only the filetype icon
            colored = true, -- Color the icon based on filetype
          },
        }, -- Show percentage progress
        lualine_z = {
          {
            function()
              return "Ln " .. vim.fn.line(".") -- Show current line number
            end,
          },
        },
      },
      extensions = { "quickfix", "nvim-tree", "fzf", "lazy" }, -- Extra UI elements
    })
  end
}
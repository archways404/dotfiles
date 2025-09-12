return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-fzf-native.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
    "nvim-tree/nvim-web-devicons", -- Icons for files
  },
  build = "make",
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local builtin = require("telescope.builtin")
    local devicons = require("nvim-web-devicons")

    -- Function to extract **only** the top-level project folder
    local function format_path(opts, path)
      local home = vim.fn.expand("~")
      local github_dir = home .. "/Documents/GitHub/"

      -- Ensure we only process paths inside ~/Documents/GitHub/
      if not path:match("^" .. github_dir) then
        return path -- If not inside GitHub dir, return as is
      end

      -- Strip the `GitHub/` part to get the relative path
      local relative_path = path:gsub("^" .. github_dir, "")

      -- Extract the **FIRST** folder (top-level project root)
      local top_level_folder = relative_path:match("^([^/]+)") or "Other"

      -- Extract **ONLY** the filename
      local filename = path:match("[^/]+$")

      -- Get file icon
      local icon, hl = devicons.get_icon(filename, filename:match("%.[^%.]+$"), { default = true })

      -- Ensure it's **always the GitHub project root** showing
      return string.format("[%s] %s %s", top_level_folder, icon, filename)
    end

    telescope.setup({
      defaults = {
        prompt_prefix = "🔍 ",
        selection_caret = "❯ ",
        path_display = format_path, -- Custom grouping function
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = { preview_width = 0.55 },
          vertical = { mirror = false },
        },
        mappings = {
          i = {
            ["<C-u>"] = false,
            ["<C-d>"] = actions.delete_buffer,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true,
          follow = true,
          find_command = {
            "rg", "--files", "--hidden",
            "--glob", "!**/.git/*",
            "--glob", "!**/node_modules/*",
            "--glob", "!**/kicad_*/*",
            "--glob", "!**/build/*",
            "--glob", "!**/target/*"
          }
        },
        live_grep = {
          additional_args = function(_)
            return {
              "--hidden",
              "--glob", "!**/.git/*",
              "--glob", "!**/node_modules/*",
              "--glob", "!**/kicad_*/*",
              "--glob", "!**/build/*",
              "--glob", "!**/target/*"
            }
          end,
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    })

    -- Load extensions
    telescope.load_extension("fzf")
    telescope.load_extension("ui-select")

    -- 🔹 Keybindings inside `telescope.lua`
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find Help" })
  end
}

-- Layout-specific aliases are managed by :KeyboardLayout.
local map = vim.keymap.set

-- Quality of life
map("n", "<C-d>", "<C-d>zz", { desc = "Half-page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half-page up (centered)" })
map("n", "n", "nzzzv", { desc = "Next match (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev match (centered)" })
map("x", "<leader>P", [["_dP]], { desc = "Paste over without yanking" })

map("n", "<leader>?", "<cmd>Overview<cr>", { desc = "Setup overview / actions" })

require("config.clipboard").setup()

-- Project navigation and a persistent sidebar.
local navigation = require("config.navigation")
navigation.setup()
map("n", "<leader>e", navigation.toggle_focus, { desc = "Switch explorer / editor focus" })
map("n", "<leader>E", navigation.toggle_explorer, { desc = "Show / hide explorer" })
map("n", "<leader>fe", navigation.focus_explorer, { desc = "Focus project explorer" })
map("n", "<leader>we", navigation.focus_editor, { desc = "Focus editor" })
map("n", "<leader><space>", function() Snacks.picker.files({ cwd = navigation.root() }) end, { desc = "Find files in current project" })
map("n", "<leader>ff", function() Snacks.picker.files({ cwd = navigation.root() }) end, { desc = "Find files in current project" })
map("n", "<leader>/", function() Snacks.picker.grep({ cwd = navigation.root() }) end, { desc = "Search text in current project" })
map("n", "<leader>sg", function() Snacks.picker.grep({ cwd = navigation.root() }) end, { desc = "Search text in current project" })
map("n", "<leader>fr", function() Snacks.picker.recent({ cwd = navigation.root(), filter = { cwd = true } }) end, { desc = "Recent files in current project" })

-- Built-in commenting respects the filetype and mixed-language regions.
map("n", "<leader>cc", "gcc", { remap = true, desc = "Comment / uncomment line" })
map("x", "<leader>cc", "gc", { remap = true, desc = "Comment / uncomment selected lines" })

map("n", "<leader>zt", "za", { desc = "Toggle fold" })
map("n", "<leader>zo", "zO", { desc = "Expand this block recursively" })
map("n", "<leader>zc", "zC", { desc = "Collapse this block recursively" })
map("n", "<leader>zr", "zR", { desc = "Expand all folds" })
map("n", "<leader>zm", "zM", { desc = "Collapse all folds" })
map("n", "<leader>zj", "zj", { desc = "Next fold / block" })
map("n", "<leader>zk", "zk", { desc = "Previous fold / block" })
map("n", "<leader>cj", "]fzv", { remap = true, desc = "Next function" })
map("n", "<leader>ck", "[fzv", { remap = true, desc = "Previous function" })

require("config.movement").setup()

require("config.cluster").setup()

-- Caps-layer Home/End events from the OS remapper, also usable on full keyboards.
map({ "n", "x" }, "<Home>", "0", { desc = "Beginning of line" })
map({ "n", "x" }, "<End>", "$", { desc = "End of line" })
map({ "n", "x" }, "<C-Home>", "gg", { desc = "Top of file" })
map({ "n", "x" }, "<C-End>", "G", { desc = "Bottom of file" })

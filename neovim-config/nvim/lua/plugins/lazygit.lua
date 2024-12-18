-- nvim v0.8.0
return {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
        "LazyGit",
        "LazyGitConfig",
        "LazyGitCurrentFile",
        "LazyGitFilter",
        "LazyGitFilterCurrentFile",
    },

    keys = {
        { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
        { "<leader>gg :LazyGit<CR>", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit Dir" }
    },

    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim",
    },
    config = function()
        require("telescope").load_extension("lazygit")
    end,
}
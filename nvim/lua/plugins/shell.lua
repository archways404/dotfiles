-- Shell scripts: LSP (bashls) + linting (shellcheck) + formatting (shfmt).
-- LazyVim has no shell extra, so we wire it up here.
return {
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "shellcheck" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = { servers = { bashls = { filetypes = { "sh", "bash", "zsh" } } } },
  },
  {
    "stevearc/conform.nvim",
    opts = { formatters_by_ft = { sh = { "shfmt" }, bash = { "shfmt" }, zsh = { "shfmt" } } },
  },
}

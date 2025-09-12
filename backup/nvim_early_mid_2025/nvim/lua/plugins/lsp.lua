return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp", -- Completion for LSP
    "williamboman/mason.nvim", -- Install LSP servers easily
    "williamboman/mason-lspconfig.nvim", -- Bridge for Mason + LSPConfig
    "jose-elias-alvarez/null-ls.nvim", -- Linting & Formatting
    "jay-babu/mason-null-ls.nvim", -- Bridge Mason + Null-LS
  },
  config = function()
    local lspconfig = require("lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local null_ls = require("null-ls")

    -- 🛠 Setup Mason (for managing LSPs, Linters & Formatters)
    require("mason").setup()

    -- 🟢 Setup Mason-LSPConfig (auto-install LSPs)
    require("mason-lspconfig").setup({
      ensure_installed = { "lua_ls", "rust_analyzer", "ts_ls", "pyright", "clangd", "gopls", "tailwindcss" },
      automatic_installation = true,
    })

    -- 🔧 Setup Mason-Null-LS (auto-install formatters & linters)
    require("mason-null-ls").setup({
      ensure_installed = { "prettier", "stylua", "black", "clang-format" }, -- Auto-install formatters
      automatic_installation = true,
    })

    -- 🖊️ Setup Null-LS (for formatters & linters)
    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.stylua, -- Lua
        null_ls.builtins.formatting.prettier, -- JS/TS
        null_ls.builtins.formatting.black, -- Python
        null_ls.builtins.formatting.clang_format, -- C/C++
      }
    })

    -- 📌 Autocompletion Capabilities
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- 🟢 Setup LSP Servers
    local servers = {
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } }, -- Fix undefined `vim`
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      },
      rust_analyzer = {},
      ts_ls = {},
      pyright = {},
      gopls = {},
      clangd = {},
    }

    for server, config in pairs(servers) do
      lspconfig[server].setup({
        capabilities = capabilities,
        settings = config.settings,
      })
    end

    -- 🔹 Keybindings for LSP
    vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { desc = "Go to Definition" })
    vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { desc = "Show Hover" })
    vim.keymap.set("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", { desc = "Rename Symbol" })
    vim.keymap.set("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", { desc = "Code Actions" })
    vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", { desc = "Previous Diagnostic" })
    vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", { desc = "Next Diagnostic" })

    -- 🖊️ Format on Save
    vim.api.nvim_create_autocmd("BufWritePre", {
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end
}
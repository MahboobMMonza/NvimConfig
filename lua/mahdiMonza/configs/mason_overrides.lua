return {
  mason = {
    opts = {
      registries = {
        {
          name = "ghostty-ls",
          url = "https://github.com/MKindberg/ghostty-ls/releases",
          type = "github",
        },
      },
    },
  },
  mason_lspconfig = {
    ensure_installed = {
      "basedpyright",
      "lua_ls",
      "gopls",
      "tsc",
      "tailwindcss",
      "eslint",
      "jdtls",
      "rust_analyzer",
      "mpls",
      "ghostty-ls",
    },
    automatic_enable = {
      exclude = { "jdtls", "rust_analyzer" },
    },
  },
  mason_tool_installer = {
    ensure_installed = {
      "prettierd",
      "stylua",
      "clang-format",
      "ruff",
      "gofumpt",
      "golangci-lint",
      "delve",
      "codelldb",
      "cpptools",
      "debugpy",
    },
  },
}

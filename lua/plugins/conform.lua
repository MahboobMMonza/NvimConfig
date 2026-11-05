return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>fmt",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = false,
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_format" },
      javascript = { "prettierd" },
      typescript = { "prettierd" },
      javascriptreact = { "prettierd" },
      typescriptreact = { "prettierd" },
      html = { "prettierd" },
      css = { "prettierd" },
      json = { "prettierd" },
      yaml = { "prettierd" },
      markdown = { "mdformat", "markdown-toc", "injected" },
      go = { "gofumpt", "gofmt" },
      c = { "clang-format" },
      cpp = { "clang-format" },
      rust = { "rustfmt" },
      sh = { "shfmt" },
      zsh = { "shfmt" },
      bash = { "shfmt" },
      toml = { "taplo" },
      zig = { "zigfmt" },
    },
  },
}

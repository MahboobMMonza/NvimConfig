local lsat = require("mahdiMonza.configs.lsp_attach")

-- rust-tools.nvim is no longer maintained; rustaceanvim is the community
-- standard replacement. It manages rust-analyzer itself, so rust_analyzer
-- is excluded from mason-lspconfig"s automatic_enable.
return {
  {
    "mrcjkb/rustaceanvim",
    ft = "rust",
    init = function()
      -- rustaceanvim reads this before it initializes, so it has to be set
      -- in `init` (not in an ftplugin, which is sourced too late).
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(client, bufnr)
            lsat.on_attach.default(client, bufnr)
            vim.keymap.set("n", "K", function()
              vim.cmd.RustLsp({ "hover", "actions" })
            end, { buffer = bufnr, desc = "Rust: Hover Actions" })
            vim.keymap.set("n", "<leader>ca", function()
              vim.cmd.RustLsp("codeAction")
            end, { buffer = bufnr, desc = "Rust: Code Actions" })
          end,
        },
        tools = {
          hover_actions = {
            auto_focus = true,
          },
        },
      }
    end,
  },
  {
    "rust-lang/rust.vim",
    ft = "rust",
    init = function()
      vim.g.rustfmt_autosave = 1
    end,
  },
}

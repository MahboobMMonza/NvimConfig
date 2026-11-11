local M = {}

-- The `'*'` configuration below is applied to *every* server, including
-- ones installed after this file was sourced. Together with
-- mason-lspconfig's `automatic_enable`, installing a new server with
-- `:MasonInstall` is enough to get a working, default-configured client.
function M.setup(_, opts)
  vim.diagnostic.config(opts.diagnostics or {})
  local mason_overrides = require("mahdiMonza.configs.mason_overrides")
  require("mahdiMonza.configs.lsp_progress_notif")
  require("mason").setup(mason_overrides.mason)

  require("mason-lspconfig").setup(mason_overrides.mason_lspconfig)

  require("mason-tool-installer").setup(mason_overrides.mason_tool_installer)

  local lsat = require("mahdiMonza.configs.lsp_attach")
  local server_overrides = require("mahdiMonza.configs.lsp_server_overrides")
  local lsp = vim.lsp

  lsp.config("*", {
    capabilities = lsat.capabilities(),
  })

  for server, override in pairs(server_overrides) do
    lsp.config(server, override)
  end
end

return M

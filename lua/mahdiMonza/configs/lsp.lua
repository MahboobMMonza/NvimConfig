local M = {}

-- The `'*'` configuration below is applied to *every* server, including
-- ones installed after this file was sourced. Together with
-- mason-lspconfig's `automatic_enable`, installing a new server with
-- `:MasonInstall` is enough to get a working, default-configured client.
function M.setup(_, opts)
	vim.diagnostic.config(opts.diagnostics or {})
	require("mahdiMonza.configs.lsp_progress_notif")
	require("mason").setup()

	require("mason-lspconfig").setup({
		ensure_installed = {
			"pyright",
			"lua_ls",
			"gopls",
			"tsc",
			"tailwindcss",
			"eslint",
			"jdtls",
			"rust_analyzer",
			"mpls",
			},
		automatic_enable = {
			exclude = { "jdtls", "rust_analyzer" },
		},
	})

	require("mason-tool-installer").setup({
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
	})

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

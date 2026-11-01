-- LSP Configuration & Plugins
--
-- nvim-lspconfig ships an `lsp/<server>.lua` file for every supported
-- server. `vim.lsp.config()` merges those automatically, so a server that
-- is installed later already comes with a usable default configuration.
local lsp_cfg = require("mahdiMonza.configs.lsp")

return {
	"neovim/nvim-lspconfig",
	opts = {
		diagnostics = {
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "",
					[vim.diagnostic.severity.WARN] = "",
					[vim.diagnostic.severity.HINT] = "",
					[vim.diagnostic.severity.INFO] = "",
				},
			},
			source = true,
		},
	},
	dependencies = {
		-- Automatically install LSPs to stdpath for neovim
		"mason-org/mason.nvim",
		"mason-org/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"saghen/blink.cmp",
		"p00f/clangd_extensions.nvim",
	},
	config = lsp_cfg.setup,
}

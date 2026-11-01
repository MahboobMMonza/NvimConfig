local lsat = require("mahdiMonza.configs.lsp_attach")

return {
	lua_ls = {
		settings = {
			Lua = {
				workspace = { checkThirdParty = false },
				telemetry = { enable = false },
				completion = { callSnippet = "Replace" },
			},
		},
	},

	gopls = {
		settings = {
			gopls = {
				completeUnimported = true,
				usePlaceholders = true,
				analyses = { unusedparams = true },
				staticcheck = true,
				gofumpt = true,
			},
		},
	},

	pyright = {
		settings = {
			python = {
				analysis = {
					typeCheckingMode = "basic",
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
					diagnosticMode = "workspace",
				},
			},
		},
	},

	-- clangd's signature help is noisy and duplicates the native one.
	clangd = {
		cmd = {
			"clangd",
			"--query-driver=/opt/homebrew/bin/*g++-*",
			-- "--compile-commands-dir=${workspaceFolder}/build",
			"--header-insertion=never",
		},
	},

	eslint = {
		settings = {
			rulesCustomizations = {
				{
					rule = "*no-unused-vars",
					severity = "off",
				},
			},
		},
	},

	marksman = {
		settings = {
			markdown = {
				completion = {
					wiki = {
						style = "file-stem",
					},
				},
			},
		},
	},

	mpls = {
		cmd = {
			"mpls",
			"--no-auto",
			"--theme",
			"tokyonight",
			"--enable-emoji",
			"--enable-footnotes",
		},
		filetypes = { "markdown" },
		root_markers = { ".marksman.toml", ".git" },
	},
}

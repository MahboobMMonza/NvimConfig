return {
	-- Provides the `crates` completion source and the crate upgrade keymap.
	"saecki/crates.nvim",
	dependencies = {
		"hrsh7th/nvim-cmp",
	},
	ft = { "rust", "toml" },
	opts = {
		on_attach = function(_, bufnr)
			vim.keymap.set(
				"n",
				"<leader>U",
				require("crates").upgrade_all_crates,
				{ buffer = bufnr, desc = "Upgrade all Crates" }
			)
		end,
	},
	config = function(_, opts)
		local crates = require("crates")
		crates.setup(opts)
		-- Register the `crates` cmp source.
		pcall(function()
			require("crates.completion.cmp").setup()
		end)
	end,
}

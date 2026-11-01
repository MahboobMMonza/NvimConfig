return {
	"folke/snacks.nvim",
	event = "VeryLazy",
	keys = {
		{
			"<leader>sf",
			function()
				Snacks.picker.files()
			end,
			desc = "Search Files",
		},
		{
			"<leader>gf",
			function()
				Snacks.picker.git_files()
			end,
			desc = "Git Files",
		},
		{
			"<leader>sg",
			function()
				Snacks.picker.grep()
			end,
			desc = "Live Grep",
		},
		{
			"<leader>sw",
			function()
				Snacks.picker.grep_word()
			end,
			desc = "Grep Word",
		},
		{
			"<leader>sd",
			function()
				Snacks.picker.diagnostics()
			end,
			desc = "Diagnostics",
		},
		{
			"<leader><space>",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>?",
			function()
				Snacks.picker.recent()
			end,
			desc = "Recent Files",
		},
		{
			"<leader>/",
			function()
				Snacks.picker.lines()
			end,
			desc = "Fuzzy in Buffer",
		},
		{
			"<leader>gg",
			function()
				Snacks.lazygit()
			end,
			desc = "Open LazyGit",
		},
		{
			"<leader>hn",
			function()
				Snacks.notifier.show_history()
			end,
			desc = "Show All History",
		},
		{
			"<leader>he",
			function()
				Snacks.notifier.show_history({ filter = "error" })
			end,
			desc = "Show Error History",
		},
		{
			"<leader>hw",
			function()
				Snacks.notifier.show_history({ filter = "warn" })
			end,
			desc = "Show Warning History",
		},
		{
			"<leader>ks",
			function()
				Snacks.picker.keymaps()
			end,
			desc = "Search Keybinds",
		}
	},
	opts = {
		lazygit = {},
		picker = {
			enabled = true,
			ui_select = { enabled = true },
			win = {
				list = { wo = { foldcolumn = "0" } },
				preview = { wo = { foldcolumn = "0" } },
				input = { wo = { foldcolumn = "0" } },
			},
		},
		notifier = {
			enabled = true,
			timeout = 3000,
			top_down = false,
			margin = {
				bottom = 2,
			},
			style = "fancy",
		},
		input = {},
	},
}

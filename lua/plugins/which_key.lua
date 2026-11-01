return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		delay = 300,
		spec = {
		  { '<leader>d', group = 'Debug' },
		  { '<leader>x', group = 'Trouble/Diagnostics' },
		},
	},
}

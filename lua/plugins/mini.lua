local surround_opts = {
	mappings = {
		add = "ys",
		delete = "ds",
		replace = "cs",
		find = "",
		find_left = "",
		highlight = "",
		suffix_last = "",
		suffix_next = "",
	},
	search_method = "cover_or_next",
}

return {
	"nvim-mini/mini.nvim",
	version = false,
	config = function()
		require("mini.surround").setup(surround_opts)
		require("mini.input").setup()
		vim.keymap.set("n", "yss", "ys_", { desc = "Surround line", remap = true, silent = true })
		vim.keymap.set("x", "S", function()
			MiniSurround.add("visual")
		end, {
			remap = true,
			silent = true,
			desc = "Surround visual",
		})
		vim.keymap.del("x", "ys")
		MiniSurround.user_input = function(prompt, text)
			return MiniInput.get({ prompt = prompt, { init_keys = text } })
		end
	end,
}

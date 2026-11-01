local function link_if_absent(group, link_to)
	if vim.fn.hlexists(group) == 0 then
		vim.api.nvim_set_hl(0, group, { link = link_to, default = true })
	end
end

return {
	"nvim-mini/mini.nvim",
	version = false,
	dependencies = { "folke/snacks.nvim" },
	opts = {
		surround = {
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
		},
	},
	config = function(_, opts)
		local ui_input_orig = vim.ui.input
		require("mini.surround").setup(opts.surround)
		local input = require("mini.input")

		link_if_absent("SnacksInputNormal", "Normal")
		link_if_absent("SnacksInputBorder", "DiagnosticInfo")
		link_if_absent("SnacksInputTitle", "DiagnosticInfo")
		link_if_absent("SnacksInputIcon", "DiagnosticHint")

		local sign_ns = vim.api.nvim_create_namespace("mini_input_icon")

		local snacks_like_view = input.gen_view.floatwin({
			style = "TM", -- top-center
			adjust_config = function(state, config)
				local prompt = state.opts.prompt or ""
				return {
					relative = "editor",
					anchor = "NW",
					row = 2,
					col = math.floor((vim.o.columns - 60) / 2), -- center a 60-col window
					width = 60,
					height = 1,
					border = "rounded",
					title = prompt,
					title_pos = "center",
					style = "minimal",
				}
			end,
		})
		-- 3. Use it as the global view handler
		input.setup({
			handlers = {
				view = function(state)
					snacks_like_view(state)
					local win_id = state.data.floatwin_win_id
					local buf_id = state.data.floatwin_buf_id
					if win_id and vim.api.nvim_win_is_valid(win_id) then
						vim.api.nvim_set_option_value(
							"winhighlight",
							"NormalFloat:SnacksInputNormal,FloatBorder:SnacksInputBorder,FloatTitle:SnacksInputTitle",
							{ win = win_id }
						)
						vim.api.nvim_set_option_value("signcolumn", "yes:2", { win = win_id })
						-- vim.api.nvim_set_option_value("foldcolumn", "2", { win = win_id })
					end
					if buf_id and vim.api.nvim_buf_is_valid(buf_id) then
						vim.api.nvim_buf_clear_namespace(buf_id, sign_ns, 0, -1)
						vim.api.nvim_buf_set_extmark(buf_id, sign_ns, 0, 0, {
							sign_text = " ",
							sign_hl_group = "SnacksInputIcon",
						})
					end
				end,
			},
		})

		-- Re-assert snacks as UI input
		vim.ui.input = ui_input_orig

		vim.keymap.set("n", "yss", "ys_", { desc = "Surround line", remap = true, silent = true })
		vim.keymap.set("x", "S", function()
			MiniSurround.add("visual")
		end, {
			remap = true,
			silent = true,
			desc = "Surround visual",
		})
		vim.keymap.del("x", "ys")
		---@diagnostic disable-next-line: duplicate-set-field
		MiniSurround.user_input = function(prompt, text)
			return MiniInput.get({ prompt = prompt, init_keys = text })
		end
	end,
}

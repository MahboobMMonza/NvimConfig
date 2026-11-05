require("mahdiMonza.set")
require("mahdiMonza.remap")
require("mahdiMonza.lazy")

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

local leaveGroup = augroup("leaveGroup", { clear = true })
autocmd("VimLeave", {
	group = leaveGroup,
	callback = function()
		vim.o.guicursor = "a:ver25-blinkwait400-blinkon1200-blinkoff1200"
	end,
})

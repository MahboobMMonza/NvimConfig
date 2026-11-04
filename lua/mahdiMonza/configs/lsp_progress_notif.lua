local search_hl = vim.api.nvim_get_hl(0, { name = "Search", link = false })
local cursor_hl = vim.api.nvim_get_hl(0, { name = "CursorLine", link = false })

local fill_hl = { fg = search_hl.fg, bg = search_hl.bg }
local empty_hl = { fg = cursor_hl.fg, bg = cursor_hl.bg }

vim.api.nvim_set_hl(0, "FormatProgressDone", fill_hl)
vim.api.nvim_set_hl(0, "FormatProgressTodo", empty_hl)

local linked_hls = {
	LspProgressSpinner = "Constant", -- spinner fg
	LspProgressTitle = "NonText", -- title fg
	LspProgressClient = "Title", -- client name fg
	-- FormatProgressDone = "Search", -- filled bar bg
	-- FormatProgressTodo = "CursorLine", -- empty bar bg
}

for g, link in pairs(linked_hls) do
	vim.api.nvim_set_hl(0, g, { link = link, default = true })
end

local function spin()
	local spinner = { frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }, interval = 80 }
	local ms = vim.uv.hrtime() / 1000000
	local frame = math.floor(ms / spinner.interval) % #spinner.frames
	return spinner.frames[frame + 1]
end
local function progress_chunks(p)
	if p.kind == "end" then
		return {
			{ " ", "LspProgressSpinner" },
			{ (p.title or "") .. " ", "LspProgressTitle" },
			{ (p.client .. " "), "LspProgressClient" },
		}
	end
	local width, done = 20, math.floor(((p.percentage or 0) / 100) * 20)
	local chunks = {}
	if p.percentage then
		chunks[#chunks + 1] = { (" "):rep(done), "FormatProgressDone" }
		chunks[#chunks + 1] = { (" "):rep(width - done) .. " ", "FormatProgressTodo" }
		if p.message then
			chunks[#chunks + 1] = { p.message .. " ", "LspProgressTitle" }
		end
		chunks[#chunks + 1] = { ("(%d%%) "):format(p.percentage), "LspProgressTitle" }
	end
	chunks[#chunks + 1] = { spin() .. " ", "LspProgressSpinner" }
	chunks[#chunks + 1] = { (p.title or "") .. " ", "LspProgressTitle" }
	chunks[#chunks + 1] = { p.client .. " ", "LspProgressClient" }
	return chunks
end

local state, timer = {}, nil

local message_id = nil
local function render()
	local lines = {}
	for _, p in pairs(state) do
		vim.list_extend(lines, progress_chunks(p))
	end
	lines[#lines + 1] = { " ", nil }

	message_id = vim.api.nvim_echo(lines, false, {
		id = message_id,
		title = nil,
		source = "lsp-progress",
		kind = "progress",
		status = "running",
	})
end

vim.api.nvim_create_autocmd("LspProgress", {
	callback = function(ev)
		local d = ev.data
		local normalized = (d.params.value.title or "progress"):gsub("%s*%(%d+%%%)", ""):gsub("%s+[0-9]+/%d+.*", "")
		-- local id = d.client_id .. "." .. d.params.token
		local id = d.client_id .. ":" .. normalized
		state[id] = vim.tbl_deep_extend("force", state[id] or {
			client = (vim.lsp.get_client_by_id(d.client_id) or {}).name or ("lsp-" .. d.client_id),
		}, d.params.value)
		if d.params.value.kind == "end" then
			state[id].percentage = 100
			vim.defer_fn(function()
				state[id] = nil
			end, 100)
		end
		if not timer then
			timer = vim.uv.new_timer()
			timer:start(
				0,
				80,
				vim.schedule_wrap(function()
					render()
					if vim.tbl_isempty(state) then
						timer:stop()
						timer = nil
					end
				end)
			)
		end
	end,
})

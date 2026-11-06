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
}

for g, link in pairs(linked_hls) do
  vim.api.nvim_set_hl(0, g, { link = link, default = true })
end
local function spin()
  local spinner = {
    frames = {
      "⠋",
      "⠙",
      "⠹",
      "⠸",
      "⠼",
      "⠴",
      "⠦",
      "⠧",
      "⠇",
      "⠏",
    },
    interval = 80,
  }
  local ms = vim.uv.hrtime() / 1000000
  local frame = math.floor(ms / spinner.interval) % #spinner.frames
  return spinner.frames[frame + 1]
end
local function progress_chunks(p)
  local width, done = 20, math.floor(((p.percentage or 0) / 100) * 20)
  local msg_line = p.message and p.message .. " " or ""
  if p.kind == "end" then
    if p.percentage then
      return {
        { (" "):rep(width), "FormatProgressDone" },
        { " " .. msg_line, "LspProgressTitle" },
        { "(100%) ", "LspProgressTitle" },
        { " ", "LspProgressSpinner" },
        { (p.title or "") .. " ", "LspProgressTitle" },
        { (p.client or "lsp"), "LspProgressClient" },
      }
    else
      return {
        { msg_line, "LspProgressTitle" },
        { " ", "LspProgressSpinner" },
        { (p.title or "") .. " ", "LspProgressTitle" },
        { (p.client or "lsp"), "LspProgressClient" },
      }
    end
  end
  local chunks = {}
  if p.percentage then
    chunks[#chunks + 1] = { (" "):rep(done), "FormatProgressDone" }
    chunks[#chunks + 1] = { (" "):rep(width - done), "FormatProgressTodo" }
    chunks[#chunks + 1] = { " " .. msg_line, "LspProgressTitle" }
    chunks[#chunks + 1] =
      { ("(%d%%) "):format(p.percentage), "LspProgressTitle" }
  else
    chunks[#chunks + 1] = { msg_line, "LspProgressTitle" }
  end
  chunks[#chunks + 1] = { spin() .. " ", "LspProgressSpinner" }
  chunks[#chunks + 1] = { (p.title or "") .. " ", "LspProgressTitle" }
  chunks[#chunks + 1] = { (p.client or "lsp"), "LspProgressClient" }
  return chunks
end

local function strip_msg_border()
  local ui2 = require("vim._core.ui2")
  local win = ui2.wins and ui2.wins.msg
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_set_config(win, { border = "none" })
  end
end

local border_stripped = false
local state, timer = {}, nil
local last_chunks = {}

local function render(id)
  local p = state[id]
  if not p then
    last_chunks[id] = nil
    return
  end
  local lines = progress_chunks(p)
  if vim.deep_equal(lines, last_chunks[id]) then
    return
  end
  last_chunks[id] = lines
  if not border_stripped then
    strip_msg_border()
    border_stripped = true
  end
  -- lines[#lines + 1] = { "\u{200B}", "Normal" }
  if #lines == 0 then
    return
  end

  if p.kind == "end" then
    vim.api.nvim_echo(lines, false, {
      id = "lsp-progress." .. id,
      title = nil,
      source = "lsp-progress",
      kind = "progress",
      status = "success",
      -- percent = 100,
    })
  else
    vim.api.nvim_echo(lines, false, {
      id = "lsp-progress." .. id,
      title = nil,
      source = "lsp-progress",
      kind = "progress",
      status = "running",
      -- percent = (p.percentage or 0),
    })
  end
end

local progress_augroup =
  vim.api.nvim_create_augroup("lsp_progress", { clear = true })
vim.api.nvim_create_autocmd("LspProgress", {
  group = progress_augroup,
  callback = function(ev)
    vim.fn.writefile(
      { vim.inspect(ev) },
      vim.fn.stdpath("log") .. "/lsp_progress.log",
      "a"
    )
    local d = ev.data
    local coarse = (d.params.value.title or "progress"):match("^(S+ %S+)")
    local id = tostring(d.client_id) .. ":" .. (coarse or "progress")
    state[id] = vim.tbl_deep_extend("force", state[id] or {
      client = (vim.lsp.get_client_by_id(d.client_id) or {}).name
        or ("lsp-" .. d.client_id),
    }, d.params.value)
    --[[ if d.params.value.kind ~= "end" and state[id].percentage then
			state[id].percentage = math.min(state[id].percentage, 99)
		end ]]
    if d.params.value.kind == "end" then
      state[id].percentage = 100
      local ids = vim.tbl_keys(state)
      for _, s in ipairs(ids) do
        render(s)
      end
      last_chunks[id] = nil
      state[id] = nil
      vim.defer_fn(function()
        state[id] = nil
      end, 100)
    end
    if not timer then
      timer = vim.uv.new_timer()
      if not timer then
        return
      end
      timer:start(
        0,
        80,
        vim.schedule_wrap(function()
          if not timer then
            return
          end
          local ids = vim.tbl_keys(state)
          for _, s in ipairs(ids) do
            render(s)
          end
          if vim.tbl_isempty(state) then
            timer:stop()
            timer = nil
          end
        end)
      )
    end
  end,
})

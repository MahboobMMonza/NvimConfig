local search_hl = vim.api.nvim_get_hl(0, { name = "Search", link = false })
-- local conceal_hl = vim.api.nvim_get_hl(0, { name = "Conceal", link = false })

local fill_hl = { fg = search_hl.fg, bg = search_hl.bg }
-- local empty_hl = { fg = conceal_hl.fg, bg = conceal_hl.bg }

vim.api.nvim_set_hl(0, "LspProgressDone", fill_hl)
-- vim.api.nvim_set_hl(0, "LspProgressTodo", empty_hl)

local linked_hls = {
  LspProgressTodo = "Conceal",
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

local function trim_progress_text(text)
  if type(text) ~= "string" then return nil end
  text = text:gsub("^%s+", ""):gsub("%s+$", "")
  if text == "" then return nil end
  return text
end

local function progress_percent_from_text(text)
  text = trim_progress_text(text)
  if not text then return nil end
  local numerator, denominator = text:match("(%d+)%s*/%s*(%d+)")
  if not numerator or not denominator then return nil end
  numerator = tonumber(numerator)
  denominator = tonumber(denominator)
  if type(numerator) ~= "number" or type(denominator) ~= "number" or denominator == 0 then
    return nil
  end
  return math.floor((numerator / denominator) * 100)
end

local function progress_report_percent(value)
  if type(value) ~= "table" then return nil end
  if type(value.percentage) == "number" then return value.percentage end
  if type(value.percentage) == "string" then
    local n = tonumber(value.percentage)
    if n then return n end
  end
  return progress_percent_from_text(value.message)
    or progress_percent_from_text(value.title)
end

local function progress_chunks(p)
  local width, done = 20, math.floor(((p.percentage or 0) / 100) * 20)
  local msg_line = p.message and p.message or ""
  if p.kind == "end" then
    if p.percentage ~= nil then
      return {
        { (" "):rep(width), "LspProgressDone" },
        { " " .. msg_line, "LspProgressTitle" },
        { "(100%) ", "LspProgressTitle" },
        { " ", "LspProgressSpinner" },
        { (p.title or "") .. " ", "LspProgressTitle" },
        { (p.client or "lsp"), "LspProgressClient" },
      }
    else
      return {
        { msg_line .. " ", "LspProgressTitle" },
        { " ", "LspProgressSpinner" },
        { (p.title or "") .. " ", "LspProgressTitle" },
        { (p.client or "lsp"), "LspProgressClient" },
      }
    end
  end
  local chunks = {}
  if p.percentage ~= nil then
    local show_msg = #msg_line > 20
    local bar_text = show_msg and (" "):rep(width) or (" "):rep(math.max(0, width - #msg_line)) .. msg_line
    local done_text = bar_text:sub(1, done)
    local todo_text = bar_text:sub(done + 1)
    local pct_pad = p.percentage < 10 and 2 or p.percentage < 100 and 1 or 0
    chunks[#chunks + 1] = { done_text, "LspProgressDone" }
    chunks[#chunks + 1] = { todo_text, "LspProgressTodo" }
    if show_msg then
      chunks[#chunks + 1] = { " " .. msg_line .. " ", "LspProgressTitle" }
    else
      chunks[#chunks + 1] = { " ", "LspProgressTitle" }
    end
    chunks[#chunks + 1] =
      { (" "):rep(pct_pad) .. ("(%d%%) "):format(p.percentage), "LspProgressTitle" }
  else
    chunks[#chunks + 1] = { msg_line .. " ", "LspProgressTitle" }
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
  local view = p
  if type(p.children) == "table" and next(p.children) then
    local selected
    local highest = -1
    for _, report in pairs(p.children) do
      local pct = (type(report) == "table" and report.percentage or 0) or 0
      if pct >= highest then
        selected = report
        highest = pct
      end
    end
    if type(selected) == "table" then
      view = {
        kind = selected.kind or p.kind or "report",
        title = p.title,
        client = p.client,
        percentage = selected.percentage or p.percentage,
        message = selected.message,
      }
    end
  end
  local lines = progress_chunks(view)
  if vim.deep_equal(lines, last_chunks[id]) then
    return
  end
  last_chunks[id] = lines
  if not border_stripped then
    strip_msg_border()
    border_stripped = true
  end
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
      vim.split(vim.inspect(ev), "\n"),
      vim.fn.stdpath("log") .. "/lsp_progress.log",
      "a"
    )
    local d = ev.data
    if type(d) ~= "table" or type(d.params) ~= "table" or type(d.params.value) ~= "table" then
      return
    end
    local value = d.params.value
    local parent_key = tostring(d.client_id or "?")
      .. ":" .. ((value.title or "progress"):gsub("^%s+", ""):gsub("%s+$", ""))
    state[parent_key] = state[parent_key] or {
      client = (vim.lsp.get_client_by_id(d.client_id) or {}).name
        or ("lsp-" .. tostring(d.client_id)),
      title = value.title,
      children = {},
    }

    local token = tostring(d.params.token or "default")
    state[parent_key].children[token] = vim.tbl_deep_extend("force", state[parent_key].children[token] or {}, value)
    local reported = progress_report_percent(value)
    if reported ~= nil then
      state[parent_key].percentage = math.max(
        state[parent_key].percentage or 0,
        reported
      )
    end
    --[[ if d.params.value.kind ~= "end" and state[id].percentage then
			state[id].percentage = math.min(state[id].percentage, 99)
		end ]]
    if value.kind == "end" then
      state[parent_key].children[token] = nil
      state[parent_key].kind = "end"
      if state[parent_key].percentage ~= nil then
        state[parent_key].percentage = 100
      end
      if vim.tbl_isempty(state[parent_key].children) then
        vim.defer_fn(function()
          state[parent_key] = nil
        end, 80)
      end
      last_chunks[parent_key] = nil
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

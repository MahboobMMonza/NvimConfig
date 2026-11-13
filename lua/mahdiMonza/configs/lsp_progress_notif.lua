local search_hl = vim.api.nvim_get_hl(0, { name = "Search", link = false })
local fill_hl = { fg = search_hl.fg, bg = search_hl.bg }

vim.api.nvim_set_hl(0, "LspProgressDone", fill_hl)

local linked_hls = {
  LspProgressTodo = "Conceal",
  LspProgressSpinner = "Constant", -- spinner fg
  LspProgressTitle = "NonText", -- title fg
  LspProgressClient = "Title", -- client name fg
}

for g, link in pairs(linked_hls) do
  vim.api.nvim_set_hl(0, g, { link = link, default = true })
end

local spinners = {
  dots = {
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
  },
}
local function spin(spin_pattern)
  spin_pattern = type(spin_pattern) == "string" and spin_pattern or "dots"
  local spinner = spinners[spin_pattern] or spinners["dots"]
  local ms = vim.uv.hrtime() / 1000000
  local frame = math.floor(ms / spinner.interval) % #spinner.frames
  return spinner.frames[frame + 1]
end

local function trim_progress_text(text)
  if type(text) ~= "string" then
    return nil
  end
  text = text:gsub("^%s+", ""):gsub("%s+$", "")
  if text == "" then
    return nil
  end
  return text
end

local function progress_percent_from_text(text)
  text = trim_progress_text(text)
  if not text then
    return nil
  end
  local numerator, denominator = text:match("(%d+)%s*/%s*(%d+)")
  if not numerator or not denominator then
    return nil
  end
  numerator = tonumber(numerator)
  denominator = tonumber(denominator)
  if
    type(numerator) ~= "number"
    or type(denominator) ~= "number"
    or denominator == 0
  then
    return nil
  end
  return math.floor((numerator / denominator) * 100)
end

local function progress_report_percent(value)
  if type(value) ~= "table" then
    return nil
  end
  if type(value.percentage) == "number" then
    return value.percentage
  end
  if type(value.percentage) == "string" then
    local n = tonumber(value.percentage)
    if n then
      return n
    end
  end
  return progress_percent_from_text(value.message)
    or progress_percent_from_text(value.title)
end

local function progress_fraction(value)
  if type(value) ~= "table" then
    return nil
  end
  local numerator, denominator =
    value.fraction and value.fraction.num or nil,
    value.fraction and value.fraction.den or nil
  if not numerator or not denominator then
    local fraction_text = type(value.message) == "string" and value.message
      or value.title
    numerator, denominator = fraction_text:match("(%d+)%s*/%s*(%d+)")
    numerator, denominator = tonumber(numerator), tonumber(denominator)
  end
  if not numerator or not denominator then
    return nil
  end
  return {
    str = numerator .. "/" .. denominator,
    num = numerator,
    den = denominator,
  }
end

local function progress_chunks(p, spin_pattern)
  local width, done = 20, math.floor(((p.percentage or 0) / 100) * 20)
  local msg_line = p.message and p.message or ""
  if p.kind == "end" then
    if p.percentage ~= nil then
      local fraction_text = p.fraction and type(p.fraction.str) == "string"
          and p.fraction.str
          and p.fraction.str ~= ""
          and p.fraction.str
        or msg_line
      local bar_text = #fraction_text <= width
          and ("%s%s"):format(
            (" "):rep(math.max(0, width - #fraction_text)),
            fraction_text
          )
        or fraction_text:sub(-width)
      return {
        { bar_text, "LspProgressDone" },
        { " (100%) ", "LspProgressTitle" },
        { "✓ ", "LspProgressSpinner" },
        { (p.title or "") .. " ", "LspProgressTitle" },
        { (p.client or "lsp"), "LspProgressClient" },
      }
    else
      return {
        { msg_line .. " ", "LspProgressTitle" },
        { "✓ ", "LspProgressSpinner" },
        { (p.title or "") .. " ", "LspProgressTitle" },
        { (p.client or "lsp"), "LspProgressClient" },
      }
    end
  end
  local chunks = {}
  if p.percentage ~= nil then
    local show_msg = #msg_line > 20
    local bar_text = show_msg and (" "):rep(width)
      or (" "):rep(math.max(0, width - #msg_line)) .. msg_line
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
    chunks[#chunks + 1] = {
      (" "):rep(pct_pad) .. ("(%d%%) "):format(p.percentage),
      "LspProgressTitle",
    }
  else
    chunks[#chunks + 1] = { msg_line .. " ", "LspProgressTitle" }
  end
  chunks[#chunks + 1] = { spin(spin_pattern) .. " ", "LspProgressSpinner" }
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

local safe_log = (function()
  local logger =
    { enabled = true, path = vim.fn.stdpath("log") .. "/lsp_progress.log" }

  return function(msg)
    if not logger.enabled then
      return
    end
    pcall(function()
      if not msg then
        vim.fn.writefile("<empty-msg>\n", logger.path, "a")
      end
      if type(msg) == "string" then
        vim.fn.writefile(msg .. "\n", logger.path, "a")
        return
      end
      local data = msg and vim.inspect(msg)
      data = (data or ""):gsub("\0", "\n")
      vim.fn.writefile(data .. "\n", logger.path, "a")
    end)
  end
end)()

local state, timer = {}, nil
local last_chunks = {}
local tracked = {}
local timer_generation = 0

local function clear_progress(ids)
  for _, id in ipairs(ids or {}) do
    state[id] = nil
    last_chunks[id] = nil
    pcall(vim.api.nvim_echo, {}, false, {
      id = "lsp-progress." .. id,
    })
  end
end

local function clear_buffer_progress(buf)
  local ids = {}
  for key in pairs(state) do
    if key:match(":buf_" .. tostring(buf) .. "$") then
      ids[#ids + 1] = key
    end
  end
  clear_progress(ids)
end

local function close_timer_handle(handle)
  if type(handle) ~= "userdata" or handle:is_closing() then
    return
  end
  pcall(function()
    handle:stop()
    handle:close()
  end)
end

local function clear_all_progress()
  clear_progress(vim.tbl_keys(state))
  tracked = {}
  close_timer_handle(timer)
  timer = nil
end

local leave_group =
  vim.api.nvim_create_augroup("progress_leave", { clear = true })
vim.api.nvim_create_autocmd({ "VimLeavePre", "BufWinLeave", "BufDelete" }, {
  group = leave_group,
  callback = function(ev)
    local event_name = ev.event or ""
    if tracked[ev.buf] == nil then
      return
    end
    tracked[ev.buf] = nil
    -- This buffer's reports are gone the moment the buffer/window leaves;
    -- clear them even when another tracked buffer is still active.
    clear_buffer_progress(ev.buf)

    -- Only tracked buffers should be allowed to end this progress session.
    -- Preview/tree/unrelated buffers must not cancel a still-active report.
    local remaining = 0
    for buf, active in pairs(tracked) do
      if active and vim.api.nvim_buf_is_valid(buf) then
        remaining = remaining + 1
      end
    end

    if event_name ~= "VimLeavePre" and remaining > 0 then
      return
    end

    tracked = {}
    clear_all_progress()
    if event_name == "VimLeavePre" or remaining == 0 then
      state = {}
      last_chunks = {}
      timer = nil
    end
  end,
})

local function render(id, spin_pattern)
  if not state then
    return
  end
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
        fraction = progress_fraction(selected) or p.fraction,
      }
    end
  end
  local lines = progress_chunks(view, spin_pattern)
  if vim.deep_equal(lines, last_chunks[id]) then
    return
  end
  last_chunks[id] = lines
  pcall(strip_msg_border)
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
      percent = nil,
    })
  else
    vim.api.nvim_echo(lines, false, {
      id = "lsp-progress." .. id,
      title = nil,
      source = "lsp-progress",
      kind = "progress",
      status = "running",
      percent = nil,
    })
  end
end

local progress_augroup =
  vim.api.nvim_create_augroup("lsp_progress", { clear = true })
vim.api.nvim_create_autocmd("LspProgress", {
  group = progress_augroup,
  callback = function(ev)
    if not state then
      return
    end
    tracked[ev.buf] = true
    local d = ev.data
    if
      type(d) ~= "table"
      or type(d.params) ~= "table"
      or type(d.params.value) ~= "table"
    then
      safe_log("LSP progress invalid event: " .. vim.inspect(ev))
      return
    end
    local value = d.params.value
    safe_log(
      string.format(
        "LSP progress: client=%s, title=%s, message=%s, token=%s, percentage=%s, kind=%s",
        tostring(d.client_id or "?"),
        tostring(value.title or "n/a"),
        tostring(value.message or "n/a"),
        tostring(d.params.token or "default"),
        tostring(progress_report_percent(value)),
        tostring(value.kind or "unknown")
      )
    )
    local parent_key = tostring(d.client_id or "?")
      .. ":"
      .. ((value.title or "progress"):gsub("^%s+", ""):gsub("%s+$", ""))
      .. ":buf_"
      .. tostring(ev.buf or "x")
    state[parent_key] = state[parent_key]
      or {
        client = (vim.lsp.get_client_by_id(d.client_id) or {}).name
          or ("lsp-" .. tostring(d.client_id)),
        title = value.title,
        children = {},
      }

    local token = tostring(d.params.token or "default")
    state[parent_key].children[token] = vim.tbl_deep_extend(
      "force",
      state[parent_key].children[token] or {},
      value
    )
    local reported = progress_report_percent(value)
    if reported ~= nil then
      state[parent_key].percentage =
        math.max(state[parent_key].percentage or 0, reported)
    end
    local reported_fraction = progress_fraction(value)
    if reported_fraction ~= nil then
      state[parent_key].fraction = reported_fraction
    end

    if value.kind == "end" then
      state[parent_key].children[token] = nil
      if vim.tbl_isempty(state[parent_key].children) then
        state[parent_key].kind = "end"
        if state[parent_key].percentage ~= nil then
          state[parent_key].percentage = 100
        end
        if state[parent_key].fraction and state[parent_key].fraction.den ~= nil then
          state[parent_key].fraction.str = string.format(
            "%d/%d",
            state[parent_key].fraction.den,
            state[parent_key].fraction.den
          )
        end
        state[parent_key].expires_at = (vim.uv.hrtime() / 1000000) + 80
        last_chunks[parent_key] = nil
      else
        -- At least one token is still reporting under the same parent, so
        -- don't let this finished child make the whole line look completed.
        local active_pct = nil
        for _, child in pairs(state[parent_key].children) do
          local child_pct = progress_report_percent(child)
          if child_pct ~= nil then
            active_pct = math.max(active_pct or 0, child_pct)
          end
        end
        state[parent_key].percentage = active_pct
      end
    end
    if not timer then
      timer = vim.uv.new_timer()
      if not timer then
        safe_log("LSP progress: failed to create timer")
        return
      end
      timer_generation = timer_generation + 1
      local handle = timer
      local my_generation = timer_generation
      -- Timer callback: every 80ms update the current task, then expire
      -- completed parents and shut the whole loop down cleanly.
      timer:start(
        0,
        80,
        vim.schedule_wrap(function()
          -- A queued callback from an older timer must never act on a newly
          -- created timer after a restart or teardown.
          if
            my_generation ~= timer_generation
            or timer ~= handle
            or handle:is_closing()
          then
            return
          end
          if type(state) ~= "table" then
            return
          end

          -- Mark expired parents as inactive without aborting the loop.
          -- `pcall` makes sure a malformed state entry cannot starve
          -- every following progress task.
          -- Apply the 80ms completion grace before rendering so both regular
          -- progress and empty-state cleanup see the same state table.
          local now = vim.uv.hrtime() / 1000000
          local ids = vim.tbl_keys(state)
          local expired = {}
          for _, id in ipairs(ids) do
            local p = state[id]
            if
              type(p) == "table"
              and type(p.expires_at) == "number"
              and now >= p.expires_at
            then
              expired[#expired + 1] = id
            end
          end
          clear_progress(expired)

          local active_ids = vim.tbl_keys(state)
          for _, id in ipairs(active_ids) do
            local ok, err = pcall(render, id, "dots")
            if not ok then
              safe_log("LSP progress render failed: " .. tostring(err))
            end
          end

          if vim.tbl_isempty(state) then
            timer_generation = timer_generation + 1
            close_timer_handle(handle)
            if timer == handle then
              timer = nil
            end
            -- Let UI2 drop the last progress line instead of leaving a
            -- completed/stale status bar behind.
            clear_progress(ids)
          end
        end)
      )
    end
  end,
})

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
  check = "✓",
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

local sp_pat = "dots"

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
local function spin(spin_pattern, kind)
  if kind == "end" then
    return spinners.check
  end
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

local function progress_num_den(text)
  text = trim_progress_text(text)
  if not text then
    return nil
  end
  local num_div, den_div = text:match("(%d+)%s*/%s*(%d+)")
  local num_of, den_of = text:match("(%d+)%s*of%s*(%d+)")
  local num, den = num_div and num_div or num_of, den_div and den_div or den_of
  if not num or not den then
    return nil, nil
  end
  num = tonumber(num)
  den = tonumber(den)
  return num, den
end

local function progress_percent_from_text(text)
  local num, den = progress_num_den(text)
  if type(num) ~= "number" or type(den) ~= "number" or den == 0 then
    return nil
  end
  return math.floor((num / den) * 100)
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
end

local function has_fractional(text)
  return progress_percent_from_text(text) ~= nil
end

local function progress_fraction(value)
  if type(value) ~= "table" then
    return nil
  end
  local fraction_text = type(value.message) == "string" and value.message or ""
  if not has_fractional(fraction_text) then
    return nil
  end
  return fraction_text
end

local function interpolate_progress_fraction(fraction_text)
  -- Always guaranteed to be a valid fractional because fraction_text exists
  return fraction_text:gsub("([^%d]*)(%d+)([^%d]*)(%d+)([^%d]*)", "%1%4%3%4%5")
end

local function progress_chunks(p, spin_pattern)
  -- NOTE: any empty string/nil value text for a chunk WILL DISCARD ALL PREVIOUS
  -- CHUNKS
  safe_log(vim.inspect(p))
  local done = math.floor(((p.percentage or 0) / 100) * p.bar_width)
  local fraction_text = type(p.fraction) == "string" and p.fraction or ""
  local fraction_len = vim.fn.strdisplaywidth(fraction_text)
  local msg_line = p.message
      and not has_fractional(p.message)
      and p.message .. " "
    or ""
  local bar_text = ("%s%s"):format(
    (" "):rep(math.max(0, p.bar_width - fraction_len)),
    fraction_text
  )
  --[[ if p.kind == "end" then
    if p.percentage ~= nil then
      if msg_line == "" then
        return {
          { bar_text, "LspProgressDone" },
          { " (100%) ", "LspProgressTitle" },
          { "✓ ", "LspProgressSpinner" },
          { (p.title or "") .. " ", "LspProgressTitle" },
          { (p.client or "lsp"), "LspProgressClient" },
        }
      else
        return {
          { bar_text, "LspProgressDone" },
          { " (100%) ", "LspProgressTitle" },
          { msg_line, "LspProgressTitle" },
          { "✓ ", "LspProgressSpinner" },
          { (p.title or "") .. " ", "LspProgressTitle" },
          { (p.client or "lsp"), "LspProgressClient" },
        }
      end
    else
      return {
        { msg_line .. " ", "LspProgressTitle" },
        { "✓ ", "LspProgressSpinner" },
        { (p.title or "") .. " ", "LspProgressTitle" },
        { (p.client or "lsp"), "LspProgressClient" },
      }
    end
  end ]]
  local chunks = {}
  if p.percentage ~= nil then
    local show_msg = #msg_line > 0
    local done_text = bar_text:sub(1, done)
    local todo_text = bar_text:sub(done + 1)
    local pct_pad = p.percentage < 10 and 3 or p.percentage < 100 and 2 or 1
    chunks[#chunks + 1] = { done_text, "LspProgressDone" }
    if #todo_text > 0 then
      chunks[#chunks + 1] = { todo_text, "LspProgressTodo" }
    end
    chunks[#chunks + 1] = {
      (" "):rep(pct_pad) .. ("(%d%%)"):format(p.percentage),
      "LspProgressTitle",
    }
    if show_msg then
      chunks[#chunks + 1] = { " " .. msg_line, "LspProgressTitle" }
    else
      chunks[#chunks + 1] = { " ", "LspProgressTitle" }
    end
  elseif #msg_line > 0 then
    chunks[#chunks + 1] = { msg_line, "LspProgressTitle" }
  end
  chunks[#chunks + 1] =
    { spin(spin_pattern, p.kind) .. " ", "LspProgressSpinner" }
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

local state, timer = {}, nil
local tracked = {}
local timer_generation = 0

local function clear_progress(ids)
  for _, id in ipairs(ids or {}) do
    state[id] = nil
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
      timer = nil
    end
  end,
})


local function bar_width(prev_width, text)
  local len = vim.fn.strdisplaywidth(text)
  if not prev_width then
    return math.max(20, len + 5)
  end
  return len > prev_width and len + 5 or prev_width
end

local function render(id, spin_pattern)
  if not state then
    return
  end
  local p = state[id]
  if not p then
    return
  end
  local view = p
  -- Parallel processes from same parent source, choose highest percent report
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
  view.fraction = progress_fraction(view.message) or p.fraction
  view.bar_width = bar_width(view.bar_width, view.fraction)
  view.message = view.message or nil
  --[[ if view.kind == "end" then
    safe_log(string.format("View: %s\np: %s\n", vim.inspect(view), vim.inspect(p)))
  end ]]
  local lines = progress_chunks(view, spin_pattern)
  pcall(strip_msg_border)
  if #lines == 0 then
    return
  end

  if p.kind == "end" then
    -- vim.notify(string.format("%s", vim.inspect(lines)), vim.log.levels.TRACE)
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

    safe_log(
      string.format(
        "LSP progress: client=%s, title=%s, message=%s, token=%s, percentage=%s, fraction=%s, kind=%s",
        tostring(d.client_id or "?"),
        tostring(value.title or "n/a"),
        tostring(value.message or "n/a"),
        tostring(d.params.token or "default"),
        tostring(progress_report_percent(value)),
        tostring(state[parent_key].fraction or "n/a"),
        tostring(value.kind or "unknown")
      )
    )

    if value.kind == "end" then
      state[parent_key].children[token] = nil
      if vim.tbl_isempty(state[parent_key].children) then
        state[parent_key].kind = "end"
        if state[parent_key].percentage ~= nil then
          state[parent_key].percentage = 100
        end
        if state[parent_key].fraction then
          state[parent_key].fraction =
            interpolate_progress_fraction(state[parent_key].fraction)
        end
        state[parent_key].expires_at = (vim.uv.hrtime() / 1000000)
          + spinners[sp_pat].interval
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
            local ok, err = pcall(render, id, sp_pat)
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

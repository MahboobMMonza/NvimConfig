-- Small floating-window text input used by the DAP configurations.
-- It is intentionally self contained so that it works without any UI plugin
-- and does not depend on `vim.ui.input` being overridden by someone else.
local M = {}

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local function close(win, bufnr)
  if vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end

-- Common prefix of a list of strings.
local function common_prefix(items)
  local prefix = items[1] or ""
  for _, item in ipairs(items) do
    while #prefix > 0 and item:sub(1, #prefix) ~= prefix do
      prefix = prefix:sub(1, -2)
    end
  end
  return prefix
end

--- Show a single line floating input.
---@param opts table|nil { prompt = string, default = string, completion = 'file' }
---@param on_done fun(value: string|nil) called with nil when the input is cancelled
function M.input(opts, on_done)
  opts = opts or {}
  local prompt = opts.prompt or "Input: "
  local default = opts.default or ""
  local completion = opts.completion

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].filetype = "dap_input"

  local width = math.min(vim.o.columns - 6, math.max(40, #prompt + 40))
  local win = vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    row = math.max(0, math.floor((vim.o.lines - 3) / 2)),
    col = math.max(0, math.floor((vim.o.columns - width) / 2)),
    width = width,
    height = 1,
    style = "minimal",
    title = " " .. prompt .. " ",
    title_pos = "center",
  })

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { default })
  vim.api.nvim_win_set_cursor(win, { 1, #default })

  local finished = false
  local function finish(value)
    if finished then
      return
    end
    finished = true
    close(win, bufnr)
    on_done(value)
  end

  vim.keymap.set({ "n", "i" }, "<CR>", function()
    finish(vim.api.nvim_get_current_line())
  end, { buffer = bufnr, nowait = true, silent = true })

  vim.keymap.set({ "n", "i" }, "<Esc>", function()
    finish(nil)
  end, { buffer = bufnr, nowait = true, silent = true })

  vim.keymap.set({ "n", "i" }, "<C-c>", function()
    finish(nil)
  end, { buffer = bufnr, nowait = true, silent = true })

  if completion == "file" then
    local group = augroup("MahdiDapInput", { clear = true })
    autocmd("TextChanged", {
      group = group,
      buffer = bufnr,
      callback = function()
        local value = vim.api.nvim_get_current_line()
        local matches = vim.fn.getcompletion(value, "file")
        if #matches == 0 then
          return
        end
        local prefix = common_prefix(matches)
        if #prefix > #value then
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { prefix })
          vim.api.nvim_win_set_cursor(win, { 1, #prefix })
        end
      end,
    })
  end

  vim.cmd("startinsert")
end

return M

local v = vim
v.g.mapleader = " "

local map = function(modes, motion, operation, opts)
  v.keymap.set(modes, motion, operation, opts)
end

map("n", "<leader>n", function()
  v.cmd("enew")
end, { desc = "New file" })
v.g.maplocalleader = ","

-- Write remap
map("n", "<leader>zz", v.cmd.w)

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
map(
  { "n", "v" },
  "<Space>",
  "<Nop>",
  {
    silent = true,
    noremap = true,
    desc = "Set space to be <Nop> for leader key",
  }
)
map(
  { "n", "v" },
  "Y",
  "yg$",
  { noremap = true, desc = "Yank from cursor to end of line" }
)

-- Remap for dealing with word wrap
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Remap to visually move selected text up and down and format it correctly
map(
  "v",
  "J",
  ":m '>+1<CR>gv=gv",
  { desc = "Move the current selection down one line", silent = true }
)
map(
  "v",
  "K",
  ":m '<-2<CR>gv=gv",
  { desc = "Move the current selection up one line", silent = true }
)

-- Don't move cursor when joining lines
map("n", "J", "mzJ`z")

-- Remap H and L to go to the effective beginnings and endings of the current line
map("n", "H", "^", { noremap = true })
map("n", "L", "$", { noremap = true })

-- Remap to re-center cursor when moving up half blocks
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Remap to continually paste same text after overwrite pastes
map("x", "<leader>p", '"_dP')

-- Remap to re-center cursor when searching for next occurrences
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Remap to yank to system register
map({ "n", "v" }, "<leader>y", '"+y')
map({ "n" }, "<leader>Y", '"+Y')

-- Easier way to paste from system keyboard
map({ "n", "v" }, "<leader>sps", '"+p')
map({ "n", "v" }, "<leader>Sps", '"+P')

-- Don't leave visual mode after indenting
map("v", ">", ">gv^")
map("v", "<", "<gv^")

map(
  "v",
  ".",
  ":normal .<CR>",
  { silent = true, desc = "Apply previous command to selected text" }
)

-- Navigate buffers
map("n", "]b", "<CMD>bn<CR>", { desc = "Next buffer" })
map("n", "[b", "<CMD>bp<CR>", { desc = "Previous buffer" })

-- Diagnostic keymaps
map("n", "<leader>e", function()
  local fl_bufnr = vim.diagnostic.open_float({ scope = "cursor" })
  if fl_bufnr then
    vim.bo[fl_bufnr].filetype = "markdown"
  end
end, { desc = "Open Diagnostic Message in Floating Window" })
map(
  "n",
  "<leader>q",
  vim.diagnostic.setloclist,
  { desc = "Add Current Diagnostic Message to Location List" }
)

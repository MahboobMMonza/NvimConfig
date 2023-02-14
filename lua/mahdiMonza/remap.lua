local v = vim
local remap = function(modes, motion, operation, opts)
  if type(modes) == "string" then
    modes = { modes }
  end
  if opts == nil then
    v.keymap.set(modes, motion, operation)
  else
    v.keymap.set(modes, motion, operation, opts)
  end
end

v.g.mapleader = ' '
v.g.maplocalleader = ' '

-- Write remap
remap('n', '<leader>zz', v.cmd.w)

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
remap({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
remap({ 'n', 'v' }, 'Y', 'yg$') -- Remap Y to do yg$ instead of synonym for yy

-- Remap for dealing with word wrap
remap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
remap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Remap to visually move selected text up and down and format it correctly
remap('v', 'J', ":m '>+1<CR>gv=gv")
remap('v', 'K', ":m '<-2<CR>gv=gv")

-- Remap to re-center cursor when moving up half blocks
remap('n', '<C-d>', '<C-d>zz')
remap('n', '<C-u>', '<C-u>zz')

-- Remap to continually paste same text after overwrite pastes
remap('x', '<leader>p', '"_dP')

-- Remap to re-center cursor when moving up half blocks
remap('n', 'n', 'nzzzv')
remap('n', 'N', 'Nzzzv')

-- Remap to yank to system register
remap({ 'n', 'v' }, '<leader>y', '"+y')
remap({ 'n' }, '<leader>Y', '"+Y')

-- Easier way to paste from system keyboard
remap({ 'n', 'v' }, '<leader>sps', '"+p')
remap({ 'n', 'v' }, '<leader>Sps', '"+P')

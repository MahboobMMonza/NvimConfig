local v = vim
local remap = function(modes, motion, operation, opts)
  v.keymap.set(modes, motion, operation, opts)
end

v.g.mapleader = ' '
v.g.maplocalleader = ' '

-- Write remap
remap('n', '<leader>zz', v.cmd.w)

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
remap({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true, noremap = true, desc = 'Set space to be <Nop> for leader key' })
remap({ 'n', 'v' }, 'Y', 'yg$', { noremap = true, desc = 'Yank from cursor to end of line' })

-- Remap for dealing with word wrap
remap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
remap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Remap to visually move selected text up and down and format it correctly
remap('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move the current selection down one line', silent = true })
remap('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move the current selection up one line', silent = true })

-- Don't move cursor when joining lines
remap('n', 'J', 'mzJ`z')

-- Remap H and L to go to the effective beginnings and endings of the current line
remap('n', 'H', '^', { noremap = true })
remap('n', 'L', '$', { noremap = true })

-- Remap to re-center cursor when moving up half blocks
remap('n', '<C-d>', '<C-d>zz')
remap('n', '<C-u>', '<C-u>zz')

-- Remap to continually paste same text after overwrite pastes
remap('x', '<leader>p', '"_dP')

-- Remap to re-center cursor when searching for next occurrences
remap('n', 'n', 'nzzzv')
remap('n', 'N', 'Nzzzv')

-- Remap to yank to system register
remap({ 'n', 'v' }, '<leader>y', '"+y')
remap({ 'n' }, '<leader>Y', '"+Y')

-- Easier way to paste from system keyboard
remap({ 'n', 'v' }, '<leader>sps', '"+p')
remap({ 'n', 'v' }, '<leader>Sps', '"+P')

-- Don't leave visual mode after indenting
remap('v', '>', '>gv^')
remap('v', '<', '<gv^')

remap('v', '.', ':normal .<CR>', { silent = true, desc = 'Apply previous command to selected text' })

-- Navigate buffers
remap('n', ']b', '<CMD>bn<CR>', { desc = 'Next buffer' })
remap('n', '[b', '<CMD>bp<CR>', { desc = 'Previous buffer' })

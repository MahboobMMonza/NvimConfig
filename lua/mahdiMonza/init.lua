require('mahdiMonza.set')
require('mahdiMonza.remap')

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = augroup('YankHighlight', { clear = true })
autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Remove trailing whitespace on write ]]
local MahdiGroup = augroup('MahdiGroup', {})
autocmd({"BufWritePre"}, {
  group = MahdiGroup,
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

require('mahdiMonza.set')
require('mahdiMonza.remap')
require('mahdiMonza.packer')

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

local leaveGroup = augroup("leaveGroup", { clear = true })
autocmd("VimLeave", {
  command = "set gcr=a:ver25-blinkwait400-blinkon1200-blinkoff1200",
group = leaveGroup,
})

-- autocmd VimLeave * call system('printf "\e[5 q" > $TTY')

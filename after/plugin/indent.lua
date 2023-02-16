-- Enable `lukas-reineke/indent-blankline.nvim`
-- See `:help indent_blankline.txt`
local colours = require('onedark.colors')
vim.api.nvim_set_hl(0, 'IndentBlanklineContextChar', { fg = colours.purple, nocombine = true })
-- vim.cmd(string.format([[ hi! IndentBlanklineContextChar guifg=%s  gui=nocombine ]], colours.purple))
require('indent_blankline').setup({
  show_current_context = true,
  show_trailing_blankline_indent = false,
  -- char_highlight_list = {
  --   "IndentBlanklineIndent4",
  -- }
})

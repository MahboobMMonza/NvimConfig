return {
  'navarasu/onedark.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('onedark').setup({
      style = 'darker',
      highlights = { IndentBlanklineContextChar = { fg = '$purple', fmt = 'nocombine' } },
      ending_tildes = false,
    })
    require('onedark').load()
  end
}

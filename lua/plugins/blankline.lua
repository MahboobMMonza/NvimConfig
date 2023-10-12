return {
  'lukas-reineke/indent-blankline.nvim',
  dependencies = { 'navarasu/onedark.nvim' },
  main = 'ibl',
  opts = {
    -- show_trailing_blankline_indent = false,
    whitespace = { remove_blankline_trail = false },
    scope = {
      show_start = false,
      show_end = false,
      -- highlight = {'Purple'},
    }
  }
}

return {
  'folke/which-key.nvim',
  config = true,
  init = function()
    vim.o.timeout, vim.o.timeoutlen = true, 300
  end,
  event = 'VeryLazy'
}

return {
  'theHamsta/nvim-dap-virtual-text',
  dependencies = {
    'mfussenegger/nvim-dap',
    'nvim-treesitter/nvim-treesitter'
  },
  build = function()
    vim.cmd([[TSUpdate]])
  end,
  config = true
}

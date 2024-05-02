return {
  'leoluz/nvim-dap-go',
  ft = 'go',
  dependencies = { 'williamboman/mason.nvim', 'mfussenegger/nvim-dap', },
  opts = false,
  config = function()
    require('dap-go').setup({
      delve = {
        path = vim.fn.exepath('dlv'),
        initialize_timeout_sec = 20,
        port = '${port}',
        args = {},
      },
    })
  end
}

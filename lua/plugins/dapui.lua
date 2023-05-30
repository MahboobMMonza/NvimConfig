local maps = function(mode, keys, func, desc)
  if desc then
    desc = 'LSP: ' .. desc
  end

  vim.keymap.set(mode, keys, func, { desc = desc, noremap = true })
end

return {
  'rcarriga/nvim-dap-ui',
  dependencies = {
    'mfussenegger/nvim-dap',
  },
  config = function()
    local dap, dapui = require('dap'), require('dapui')
    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close
    maps('n', '<leader>dut', dapui.toggle, 'DAP UI Toggle')
    dapui.setup()
  end
}

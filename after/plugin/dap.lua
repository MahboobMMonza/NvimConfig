local v = vim
local dap, dapui, dapvt = require('dap'), require('dapui'), require('nvim-dap-virtual-text')

local function signs(name, sign, thl)
  v.fn.sign_define(name, { text = sign, texthl = thl, linehl = '', numhl = '' })
end

local maps = function(mode, keys, func, desc)
  if desc then
    desc = 'LSP: ' .. desc
  end

  v.keymap.set(mode, keys, func, { desc = desc, noremap = true })
end

dapui.setup()
dapvt.setup()

dap.listeners.after.event_initialized['dapui_config'] = function()
  dapui.open()
end

-- dap.listeners.after.event_terminated['dapui_config'] = function()
--   dapui.close()
-- end
--
-- dap.listeners.after.event_exited['dapui_config'] = function()
--   dapui.close()
-- end

-- dap.configurations.java = {
--   {
--     type = 'java',
--     request = 'attach',
--     name = 'Attach to remote process',
--     hostName = 'localhost',
--     port = '8000',
--   },
--   {
--     type = 'java',
--     request = 'launch',
--     name = 'Launch this file with args',
--     program = '${file}',
--     args = function()
--       return coroutine.create(function(dap_run_co)
--         vim.ui.input({ prompt = 'Args: ' }, function(argstr)
--           coroutine.resume(dap_run_co, argstr)
--         end)
--       end)
--     end,
--   }
-- }

signs('DapBreakpoint', '', 'DiagnosticSignHint')
signs('DapBreakpointCondition', '󰟃', 'DiagnosticSignWarn')
signs('DapLogPoint', '󰸥', 'DiagnosticSignInfo')
signs('DapBreakpointRejected', '󰅙', 'DiagnosticSignError')

maps('n', '<leader>dg', dap.continue, 'DAP Forwards Continue')
maps('n', '<leader>dG', dap.reverse_continue, 'DAP Reverse Continue')
maps('n', '<leader>df', dap.step_over, 'DAP Step Over')
maps('n', '<leader>do', dap.step_out, 'DAP Step Out')
maps('n', '<leader>di', function() dap.step_into({ askForTargets = true }) end, 'DAP Step Into')
maps('n', '<leader>db', dap.toggle_breakpoint, 'DAP Toggle Breakpoint')
maps('n', '<leader>dC', dap.clear_breakpoints, 'DAP Clear Breakpoints')
maps('n', '<leader>dS', dap.step_back, 'DAP Step Back')
maps('n', '<leader>dB', function() dap.set_breakpoint(vim.fn.input("Condition: ")) end,
  'DAP Set Conditional Breakpoint (input condition)')
maps('n', '<leader>dv', function() dap.set_breakpoint(vim.fn.input("Condition: "), vim.fn.input("Hits: ")) end,
  'DAP Set Conditional Breakpoint (input condition)')
maps('n', '<leader>dV', function() dap.set_breakpoint(vim.fn.input("Condition: "), vim.fn.input("Hits: "), vim.fn.input("Log: ")) end,
  'DAP Set Conditional Breakpoint (input condition)')
maps('n', '<leader>dl', function() dap.set_breakpoint(nil, nil, vim.fn.input("Log: ")) end,
  'DAP Set Log Breakpoint (input condition)')
maps('n', '<leader>de',
  function() dap.set_exception_breakpoints(vim.fn.split(vim.fn.input("Exception Types: "), " ", false)) end,
  'DAP Set Exception Breakpoint (input condition)')
maps('n', '<leader>dt',  dap.terminate, 'DAP Terminate')
maps('n', '<leader>dc',  dapui.close, 'DAP UI Close')
maps('n', '<leader>dr',  dap.repl.open, 'DAP REPL Open')

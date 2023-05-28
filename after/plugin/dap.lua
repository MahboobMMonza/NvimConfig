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

local function arginp(prompt)
  return coroutine.create(function(dap_run_co)
    vim.ui.input({ prompt = prompt }, function(argstr)
      coroutine.resume(dap_run_co, argstr)
    end)
  end)
end

dapui.setup()
dapvt.setup()

dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close

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
maps('n', '<leader>dB', function() dap.set_breakpoint(arginp("Condition: ")) end,
  'DAP Set Conditional Breakpoint (input condition)')
maps('n', '<leader>dv', function() dap.set_breakpoint(arginp("Condition: "), arginp("Hits: ")) end,
  'DAP Set Conditional Breakpoint (input condition)')
maps('n', '<leader>dV',
  function() dap.set_breakpoint(arginp("Condition: "), arginp("Hits: "), arginp("Log: ")) end,
  'DAP Set Complete Conditional Breakpoint (input conditions)')
maps('n', '<leader>dl', function() dap.set_breakpoint(nil, nil, arginp("Log: ")) end,
  'DAP Set Log Breakpoint (input condition)')
maps('n', '<leader>de',
  function() dap.set_exception_breakpoints(vim.fn.split(vim.fn.input("Exception Types: "), " ", false)) end,
  'DAP Set Exception Breakpoint (input condition)')
maps('n', '<leader>dt', dap.terminate, 'DAP Terminate')
maps('n', '<leader>dut', dapui.toggle, 'DAP UI Toggle')
maps('n', '<leader>dr', dap.repl.open, 'DAP REPL Open')

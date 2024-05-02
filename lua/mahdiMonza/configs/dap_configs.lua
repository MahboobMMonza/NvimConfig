local config_struct = {}

-- Auxiliary functions
config_struct.get_exec_path = function(prompt)
  return coroutine.create(function(dap_run_co)
    vim.ui.input({ prompt = prompt, completion = 'file' }, function(exepath)
      coroutine.resume(dap_run_co, vim.fn.getcwd() .. '/' .. exepath)
    end)
  end)
end

config_struct.get_address = function(prompt)
  return coroutine.create(function(dap_run_co)
    vim.ui.input({ prompt = prompt, completion = 'file' }, function(addr)
      coroutine.resume(dap_run_co, addr)
    end)
  end)
end

config_struct.arginp = function(prompt)
  return coroutine.create(function(dap_run_co)
    vim.ui.input({ prompt = prompt }, function(args)
      coroutine.resume(dap_run_co, args)
    end)
  end)
end

-- Configurations
config_struct.adapters = {}
config_struct.configurations = {}
config_struct.adapters.cppdbg = {
  id = 'cppdbg',
  type = 'executable',
  command = vim.fn.exepath('OpenDebugAD7'),
}

config_struct.configurations.c_cpp = {
  {
    name = 'Launch file',
    type = 'cppdbg',
    request = 'launch',
    program = config_struct.get_exec_path('Path to executable: ' .. vim.fn.getcwd() .. '/'),
    cwd = '${workspaceFolder}',
    args = config_struct.arginp('Args: '),
    stopAtEntry = true,
    setupCommands = {
      {
        text = '-enable-pretty-printing',
        description = 'enable pretty printing',
        ignoreFailures = false,
      }
    },
  },
  {
    name = 'Attatch to gdbserver',
    type = 'cppdbg',
    request = 'launch',
    MIMode = 'gdb',
    miDebuggerServerAddress = config_struct.get_address('Server Address: '),
    miDebuggerPath = '/usr/bin/gdb',
    cwd = '${workspaceFolder}',
    args = config_struct.arginp('Args: '),
    program = config_struct.get_exec_path('Path to executable: ' .. vim.fn.getcwd() .. '/'),
    stopAtEntry = true,
    setupCommands = {
      {
        text = '-enable-pretty-printing',
        description = 'enable pretty printing',
        ignoreFailures = false,
      }
    },
  }
}

return config_struct

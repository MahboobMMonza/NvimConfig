local dap = require('dap')
local configs_struct = require('mahdiMonza.configs.dap_configs')

dap.adapters.cppdbg = configs_struct.adapters.cppdbg
dap.configurations.cpp = configs_struct.configurations.c_cpp
dap.configurations.c = configs_struct.configurations.c_cpp

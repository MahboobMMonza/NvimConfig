local dap_go = require('dap-go')
local v = vim

local maps = function(mode, keys, func, desc)
  if desc then
    desc = 'LSP: ' .. desc
  end

  v.keymap.set(mode, keys, func, { desc = desc, noremap = true })
end

maps('n', '<leader>dtm', dap_go.debug_test, 'Test nearest method')
maps('n', '<leader>dtl', dap_go.debug_last_test, 'Rerun last test')

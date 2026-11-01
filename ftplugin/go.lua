local v = vim

local maps = function(mode, keys, func, desc)
  if desc then
    desc = "DAP: " .. desc
  end

  v.keymap.set(mode, keys, func, { desc = desc, noremap = true })
end

-- Deferred by one tick: the ftplugin is sourced before the plugin manager
-- has loaded the `dap-go` plugin for this filetype.
v.schedule(function()
  local ok, dap_go = pcall(require, "dap-go")
  if not ok then
    return
  end

  maps("n", "<leader>dtm", dap_go.debug_test, "Test nearest method")
  maps("n", "<leader>dtl", dap_go.debug_last_test, "Rerun last test")
end)

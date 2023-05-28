local mapper = require('mahdiMonza.configs.lsp_mappings')
local navic = require('nvim-navic')

local M = {}

M.setup_navic = function()
  navic.setup({
    lsp = {
      auto_attach = false,
      preference = nil,
    },
    highlight = true,
  })
end


M.on_attach = function(client, bufnr)
  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end
  -- Shortcut for setting LSP keymaps
  mapper.set_maps(bufnr)
end

M.maps = mapper.maps

return M

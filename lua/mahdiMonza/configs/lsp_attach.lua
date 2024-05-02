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

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities = require('cmp_nvim_lsp').default_capabilities(M.capabilities)

M.on_attach = {}

M.on_attach.default = function(client, bufnr)
  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end
  -- Shortcut for setting LSP keymaps
  mapper.set_maps(bufnr)
end

local metatable = {
  __index = function(t)
    return t.default
  end
}

setmetatable(M.on_attach, metatable)

M.on_attach.clangd = function(client, bufnr)
  M.on_attach.default(client, bufnr)
  client.server_capabilities.signatureHelpProvider = false
  -- Shortcut for setting LSP keymaps
  mapper.set_maps(bufnr)
end

M.maps = mapper.maps

return M

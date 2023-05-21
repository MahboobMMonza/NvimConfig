local navic = require('nvim-navic')
local replh = require('nvim-dap-repl-highlights')
-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local mapper = require('mahdiMonza.configs.lspmappings')
replh.setup()

navic.setup({
  lsp = {
    auto_attach = false,
    preference = nil,
  },
  highlight = true,
})

local on_attach = function(client, bufnr)
  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end
  -- Shortcut for setting LSP keymaps
  mapper.set_maps(bufnr)
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
  jdtls = {},
}

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Setup mason so it can manage external tooling
require('mason').setup()

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

-- local java_config = require('ftplugin.java').config
for _, server_name in ipairs(mason_lspconfig.get_installed_servers()) do
  if (server_name ~= 'jdtls') then
    local config = {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
    }

    require('lspconfig')[server_name].setup(config)
  end
end

require('fidget').setup()

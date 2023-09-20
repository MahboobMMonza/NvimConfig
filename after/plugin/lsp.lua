local replh = require('nvim-dap-repl-highlights')
local lsat = require('mahdiMonza.configs.lsp_attach')
local lsp = vim.lsp

replh.setup()
lsat.setup_navic()

lsp.handlers['textDocument/hover'] = lsp.with(lsp.handlers.hover, { border = 'rounded' })
lsp.handlers['textDocument/signatureHelp'] = lsp.with(lsp.handlers.signature_help, { border = 'rounded' })

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local server_overrides = {
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      completion = {
        callSnippet = "Replace"
      }
    },
  },
}

-- Setup mason so it can manage external tooling
require('mason').setup()

-- Ensure the servers above are installed
local mason_lspconfig = require('mason-lspconfig')

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(server_overrides),
}

local excl_servers = { ['jdtls'] = true, ['rust_analyzer'] = true }

-- local java_config = require('ftplugin.java').config
for _, server_name in ipairs(mason_lspconfig.get_installed_servers()) do
  if (not excl_servers[server_name]) then
    local config = {
      capabilities = lsat.capabilities,
      on_attach = (server_name ~= 'clangd' and { lsat.on_attach } or { lsat.clangd_on_attach })[1],
      settings = server_overrides[server_name],
    }

    require('lspconfig')[server_name].setup(config)
  end
end

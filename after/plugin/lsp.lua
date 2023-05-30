local replh = require('nvim-dap-repl-highlights')
local lsat = require('mahdiMonza.configs.lsp_attach')

replh.setup()
lsat.setup_navic()
-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.

--[[ local on_attach = function(client, bufnr)
  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end
  -- Shortcut for setting LSP keymaps
  mapper.set_maps(bufnr)
end ]]

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local server_overrides = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- tsserver = {},
  --[[ rust_analyzer = {
    cmd = {
      "rustup", "run", "stable", "rust-analyzer",
    }
  } ]]

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

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Setup mason so it can manage external tooling
require('mason').setup()

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(server_overrides),
}

local excl_servers = {'jdtls', 'rust_analyzer'}

-- local java_config = require('ftplugin.java').config
for _, server_name in ipairs(mason_lspconfig.get_installed_servers()) do
  if (not excl_servers[server_name]) then
    local config = {
      capabilities = capabilities,
      on_attach = lsat.on_attach,
      settings = server_overrides[server_name],
    }

    require('lspconfig')[server_name].setup(config)
  end
end

require('fidget').setup()

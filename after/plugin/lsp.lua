local replh = require('nvim-dap-repl-highlights')
local lsat = require('mahdiMonza.configs.lsp_attach')
local lsp = vim.lsp

replh.setup()
lsat.setup_navic()

lsp.handlers['textDocument/hover'] = lsp.buf.hover({ border = 'rounded' })
lsp.handlers['textDocument/signatureHelp'] = lsp.buf.signature_help({ border = 'rounded' }) -- Enable the following language servers Feel free to add/remove any LSPs that you want here. They will automatically be installed.
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
  gopls = {
    settings = {
      gopls = {
        completeUnimported = true,
        usePlaceholders = true,
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
        gofumpt = true,
      },
    },
  },
  ts_ls = {},
  tailwindcss = {},
  eslint = {},
  prettierd = {},
}

-- Setup mason so it can manage external tooling
-- require('mason').setup()

-- Ensure the servers above are installed
local mason_lspconfig = require('mason-lspconfig')
local mason_tools = require('mason-tool-installer')

mason_lspconfig.setup()

mason_tools.setup({
  ensure_installed = vim.tbl_keys(server_overrides),
})

-- manually do the exclusion until I get a better chance to look this over
local excl_servers = { ['jdtls'] = true, ['rust_analyzer'] = true }

-- local java_config = require('ftplugin.java').config
for _, server_name in ipairs(mason_lspconfig.get_installed_servers()) do
  if (not excl_servers[server_name]) then
    local config = {
      capabilities = lsat.capabilities,
      on_attach = lsat.on_attach[server_name],
      settings = server_overrides[server_name],
    }

    vim.lsp.config[server_name] = config
    vim.lsp.enable(server_name)
  end
end

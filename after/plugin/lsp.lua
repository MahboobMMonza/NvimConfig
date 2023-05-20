-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- Shortcut for setting LSP keymaps
  local maps = function(mode, keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc, noremap = true })
  end

  maps('n', '<leader>rn', vim.lsp.buf.rename, 'Rename')
  maps('n', '<leader>ca', vim.lsp.buf.code_action, 'Code Action')
  maps('x', '<leader>ca', ':vim.lsp.buf.code_action()<cr>', 'Ranged Code Action')
  maps('n', 'gd', vim.lsp.buf.definition, 'Goto Definition')
  maps('n', '<leader>gr', require('telescope.builtin').lsp_references, 'Goto References')
  maps('n', '<leader>gI', vim.lsp.buf.implementation, 'Goto Implementation')
  maps('n', '<leader>D', vim.lsp.buf.type_definition, 'Type Definition')
  maps('n', '<leader>ds', require('telescope.builtin').lsp_document_symbols, 'Document Symbols')
  maps('n', '<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace Symbols')

  -- See `:help K` for why this keymap
  maps('n', 'K', vim.lsp.buf.hover, 'Hover Documentation')
  maps('n', '<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  maps('n', 'gD', vim.lsp.buf.declaration, 'Goto Declaration')
  maps('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, 'Workspace Add Folder')
  maps('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, 'Workspace Remove Folder')
  maps('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, 'Workspace List Folders')

  -- Create a command `:fmt` local to the LSP buffer
  maps('n', '<leader>fmt', function(_)
    if vim.lsp.buf.format then
      vim.lsp.buf.format()
    elseif vim.lsp.buf.formatting then
      vim.lsp.buf.formatting()
    end
  end, 'Format current buffer')
end

local replh = require('nvim-dap-repl-highlights')
replh.setup()
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

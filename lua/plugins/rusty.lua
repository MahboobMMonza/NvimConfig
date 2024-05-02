local lsat = require('mahdiMonza.configs.lsp_attach')

return {
  {
    'simrat39/rust-tools.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
      'nvim-lua/plenary.nvim',
      'mfussenegger/nvim-dap',
      'williamboman/mason.nvim',
    },
    ft = 'rust',
    config = function()
      local mason_registry = require('mason-registry')

      local codelldb = mason_registry.get_package('codelldb')
      local extension_path = codelldb:get_install_path() .. '/extension/'
      local codelldb_path = extension_path .. 'adapter/codelldb'
      local liblldb_path = extension_path .. 'lldb/lib/liblldb.so'
      require('rust-tools').setup(
        {
          server = {
            on_attach = function(_, bufnr)
              lsat.on_attach.default(_, bufnr)
              vim.keymap.set('n', '<leader>k', require('rust-tools').hover_actions.hover_actions,
                { buffer = bufnr, desc = 'Rust-Tools Hover Actions' })
              vim.keymap.set('n', '<leader>ga', require('rust-tools').code_action_group.code_action_group,
                { buffer = bufnr, desc = 'Rust-Tools Code Action Group' })
            end,
            capabilities = lsat.capabilities,
            checkOnSave = {
              allFeatures = true,
              overrideCommand = {
                'cargo', 'clippy', '--workspace', '--message-format=json',
                '--all-targets', '--all-features'
              }
            }
          },
          tools = {
            hover_actions = {
              auto_focus = true,
            }
          },
          dap = {
            adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
          },
        }
      )
    end,
  },
  {
    'rust-lang/rust.vim',
    ft = 'rust',
    init = function()
      vim.g.rustfmt_autosave = 1
    end
  },
  {
    'saecki/crates.nvim',
    ft = { 'rust', 'toml' },
    opts = {
      on_attach = function(_, bufnr)
        vim.keymap.set('n', '<leader>u', require('crates').upgrade_all_crates,
          { buffer = bufnr, desc = 'Upgrade all Crates' })
      end
    },
    config = function(_, opts)
      local crates = require('crates')
      crates.setup(opts)
      crates.show()
    end,
  }
}

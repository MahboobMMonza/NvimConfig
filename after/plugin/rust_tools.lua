local rt = require('rust-tools')

rt.setup({
  server = {
    on_attach = function(_, bufnr)
      vim.keymap.set('n', '<leader>ha', rt.hover_actions.hover_actions,
        { buffer = bufnr, desc = 'Rust Tool Hover Actions' })
      vim.keymap.set('n', '<leader>gc', rt.code_action_group.code_action_group,
        { buffer = bufnr, desc = 'Rust Tool Code Action Groups' })
    end
  },
  dap = {
    adapter = {
      type = 'executable',
      command = 'lldb-vscode',
      name = 'rt_lldb',
    },
  }
})

require('fidget').setup()

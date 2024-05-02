local function my_on_attach(bufnr)
  local api = require('nvim-tree.api')

  local function opts(desc)
    return { desc = 'Nvim Tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  api.config.mappings.default_on_attach(bufnr)

  vim.keymap.set('n', 'O', '', { buffer = bufnr })
  vim.keymap.del('n', 'O', { buffer = bufnr })
  vim.keymap.set('n', '<2-RightMouse>', '', { buffer = bufnr })
  vim.keymap.del('n', '<2-RightMouse>', { buffer = bufnr })
  vim.keymap.set('n', 'D', '', { buffer = bufnr })
  vim.keymap.del('n', 'D', { buffer = bufnr })
  vim.keymap.set('n', 'E', '', { buffer = bufnr })
  vim.keymap.del('n', 'E', { buffer = bufnr })

  vim.keymap.set('n', 'A', api.tree.expand_all, opts('Expand All'))
  vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
  vim.keymap.set('n', 'C', api.tree.change_root_to_node, opts('CD'))
  vim.keymap.set('n', 'P', function()
    local node = api.tree.get_node_under_cursor()
    print(node.absolute_path)
  end, opts('Print Node Path'))

  vim.keymap.set('n', '<leader>z', api.node.run.system, opts('Run System'))
end

return {
  'nvim-tree/nvim-tree.lua',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  version = '*',
  config = function()
    local v = vim
    local remap = function(modes, motion, operation, opts)
      if type(modes) == "string" then
        modes = { modes }
      end
      v.keymap.set(modes, motion, operation, opts)
    end
    require('nvim-tree').setup({
      on_attach = my_on_attach,
      sort_by = "case_sensitive",
      view = {
        adaptive_size = true,
      },
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = true,
      },
    })
    -- Keymap to open nvim-tree easily
    remap('n', '<leader>pf', ':NvimTreeFocus<CR>', { desc = 'Nvim Tree Focus' })
    remap('n', '<leader>pvt', ':NvimTreeToggle<CR>', { desc = 'Nvim Tree Toogle' })
    remap('n', '<leader>pvf', ':NvimTreeFindFile<CR>', { desc = 'Nvim Tree Find File' })
    remap('n', '<leader>pvc', ':NvimTreeCollapse<CR>', { desc = 'Nvim Tree Collapse All' })
  end
}

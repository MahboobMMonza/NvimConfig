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
      sort_by = "case_sensitive",
      view = {
        adaptive_size = true,
        mappings = {
          list = {
            { key = "u", action = "dir_up" },
          },
        },
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

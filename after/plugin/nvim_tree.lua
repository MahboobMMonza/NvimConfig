require("nvim-tree").setup({
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

local v = vim
local remap = function(modes, motion, operation, opts)
  if type(modes) == "string" then
    modes = { modes }
  end
  v.keymap.set(modes, motion, operation, opts)
end

-- Keymap to open nvim-tree easily
remap('n', '<leader>pf', ':NvimTreeFocus<CR>')
remap('n', '<leader>pvt', ':NvimTreeToggle<CR>')
remap('n', '<leader>pvf', ':NvimTreeFindFile<CR>')
remap('n', '<leader>pvc', ':NvimTreeCollapse<CR>')
-- remap('n', '<leader>pv<CR>', ':NvimTreeFocus')


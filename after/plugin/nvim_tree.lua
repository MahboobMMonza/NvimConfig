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
  if opts == nil then
    v.keymap.set(modes, motion, operation)
  else
    v.keymap.set(modes, motion, operation, opts)
  end
end

-- Keymap to open nvim-tree easily
remap('n', '<leader>pv<CR>', ':NvimTreeFocus<CR>')
remap('n', '<leader>pvt', ':NvimTreeToggle')
-- remap('n', '<leader>pv<CR>', ':NvimTreeFocus')


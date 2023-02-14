-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
local builtin = require('telescope.builtin')
local v = vim

require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
v.keymap.set('n', '<leader>?', builtin.oldfiles, { desc = '[?] Find recently opened files' })
v.keymap.set('n', '<leader><space>', builtin.buffers, { desc = '[ ] Find existing buffers' })
v.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer]' })

v.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
v.keymap.set('n', '<leader>gf', builtin.git_files, { desc = '[S]earch [G]it files' })
v.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
v.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
v.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
v.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })


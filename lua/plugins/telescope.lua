-- Fuzzy Finder (files, lsp, etc)
return {
  -- Fuzzy Finder Algorithm which needs local dependencies to be built. Only load when `make` is available
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = vim.fn.executable 'make' == 1 },
  { 'nvim-telescope/telescope-ui-select.nvim' },
  { 'nvim-telescope/telescope-dap.nvim' },
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-fzf-native.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
      'nvim-telescope/telescope-dap.nvim' },
    config = function()
      local builtin = require('telescope.builtin')
      local v = vim
      local tels = require('telescope')
      local themes = require('telescope.themes')
      -- Set up telescope
      tels.setup({
        defaults = {
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
              ['<C-h>'] = 'which_key',
            },
          },
        },
        extensions = {
          ['ui-select'] = {
            themes.get_dropdown(themes.get_dropdown {
              winblend = 10,
              previewer = false,
            }),
          },
        },
      })
      -- Load fzf extension
      tels.load_extension('fzf')
      tels.load_extension('ui-select')
      tels.load_extension('dap')
      -- Additional mappings
      v.keymap.set('n', '<leader>?', builtin.oldfiles, { desc = '[?] Find recently opened files' })
      v.keymap.set('n', '<leader><space>', builtin.buffers, { desc = '[ ] Find existing buffers' })
      v.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        builtin.current_buffer_fuzzy_find(themes.get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer]' })

      v.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      v.keymap.set('n', '<leader>gf', builtin.git_files, { desc = '[S]earch [G]it files' })
      v.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      v.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch [W]ord' })
      v.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      v.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    end
  }
}

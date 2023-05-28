-- Additional plugins
return function(use)
  -- which-key
  use({
    'folke/which-key.nvim',
    config = function()
      require('which-key').setup()
    end
  })

  -- nvim Surround
  use({
    'kylechui/nvim-surround',
    tag = '*',
  })

  -- Nvim-Tree
  use({
    'nvim-tree/nvim-tree.lua',
    requires = {
      'nvim-tree/nvim-web-devicons',
    },
    tag = 'nightly',
  })

  use {
    'SmiteshP/nvim-navic',
    requires = 'neovim/nvim-lspconfig'
  }

  use {
    'simrat39/rust-tools.nvim',
    requires = {
      'neovim/nvim-lspconfig',
      'nvim-lua/plenary.nvim',
      'mfussenegger/nvim-dap'
    }
  }
end

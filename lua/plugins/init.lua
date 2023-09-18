return {
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      { 'j-hui/fidget.nvim', tag = 'legacy', config = true, },

      -- Additional lua configuration, makes nvim stuff amazing
      'folke/neodev.nvim',
    },
  },

  -- Git related plugins
  'tpope/vim-rhubarb',
  'tpope/vim-abolish',

  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  -- Add custom plugins to packer from ~/.config/nvim/lua/ext/plugins.lua
}

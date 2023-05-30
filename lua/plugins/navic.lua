return {
  'SmiteshP/nvim-navic',
  dependencies = { 'neovim/nvim-lspconfig' },
  opts = {
    lsp = {
      auto_attach = false,
      preference = nil,
    },
    highlight = true,
  }
}

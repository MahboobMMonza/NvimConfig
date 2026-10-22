return {
  'folke/lazydev.nvim',
  ft = 'lua',
  opts = {
    library = {
    },
    integrations = {
      lspconfig = true,
      cmp = true,
      coq = false,
    },
  },
}

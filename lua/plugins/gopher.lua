return {
  'olexsmir/gopher.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  opts = {
    commands = {
      go = 'go',
      gomodifytags = 'gomodifytags',
      gotests = '~/go/bin/gotests',
      impl = 'impl',
      iferr = 'iferr',
    },
  },
  build = ':silent! GoInstallDeps',
}

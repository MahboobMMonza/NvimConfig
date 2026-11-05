return {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      {
        path = "snacks.nvim",
        words = { "Snacks" },
      },
      "mini.nvim",
      "lazy.nvim",
    },
    integrations = {
      lspconfig = true,
      cmp = true,
      coq = false,
    },
  },
}

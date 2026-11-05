return {
  "folke/trouble.nvim",
  dependencies = "nvim-tree/nvim-web-devicons",
  opts = {},
  keys = {
    {
      "<leader>xx",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Diagnostics (Trouble)",
    },
    {
      "<leader>xq",
      "<cmd>Trouble qflist toggle<cr>",
      desc = "Quickfix (Trouble)",
    },
  },
}

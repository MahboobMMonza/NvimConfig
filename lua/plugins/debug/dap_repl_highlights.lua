return {
  -- DAP REPL highlighting for better readability
  "igorlfs/nvim-dap-repl-highlights",
  dependencies = {
    "mfussenegger/nvim-dap",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function ()
    -- require("dap-repl-highlights").setup({})
    require("nvim-treesitter").install({ "dap_repl" })
  end
}

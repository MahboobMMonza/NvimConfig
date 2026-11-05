return {
  -- DAP REPL highlighting for better readability
  "LiadOz/nvim-dap-repl-highlights",
  dependencies = {
    "mfussenegger/nvim-dap",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    local replh = require("nvim-dap-repl-highlights")
    replh.setup()

    -- The plugin ships the `dap_repl` grammar, but nvim-treesitter only knows
    -- about it after a `:TSUpdate`. Register it directly and install it.
    pcall(function()
      local parsers = require("nvim-treesitter.parsers")
      if not parsers.dap_repl then
        local source = debug.getinfo(replh.setup).source:sub(2)
        local root = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(source)))
        parsers.dap_repl = {
          install_info = { path = root },
        }
      end
      require("nvim-treesitter").install({ "dap_repl" })
    end)
  end,
}

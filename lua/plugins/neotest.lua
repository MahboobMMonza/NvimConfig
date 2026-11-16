return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/neotest-python",
    "nvim-neotest/neotest-go",
    "nvim-neotest/neotest-jest",
    "rcasia/neotest-java",
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-python"),
        require("neotest-go"),
        require("neotest-jest")({
          jestCommand = "npx jest",
          cwd = require("neotest-jest.jest-util").getJestRoot,
        }),
        require("rustaceanvim.neotest"),
        require("neotest-java"),
      },
    })
  end,
}

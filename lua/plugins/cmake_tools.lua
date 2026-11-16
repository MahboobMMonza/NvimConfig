return {
  "Civitasv/cmake-tools.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    { "akinsho/toggleterm.nvim", version = "*", config = true },
  },
  main = "cmake-tools",
  opts = {
    cmake_command = "cmake",
    cmake_use_preset = true,
    cmake_build_options = { "-j8" },
    cmake_generate_options = {
      "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
    },
    cmake_compile_commands_options = {
      action = "lsp",
      target = vim.loop.cwd,
    },
    cmake_use_scratch_buffer = true,
  },
}

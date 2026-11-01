return {
  "Civitasv/cmake-tools.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  main = "cmake-tools",
  opts = {
    cmake_command = "cmake",
    cmake_use_preset = true,
    cmake_build_options = { "-j8" },
    cmake_generate_options = {
      "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
    },
    cmake_build_directory = "build/${variant:buildType}",
    cmake_compile_commands_options = {
      action = "lsp",
      target = vim.loop.cwd,
    },
  },
}

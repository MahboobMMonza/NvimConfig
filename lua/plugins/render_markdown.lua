return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    file_types = { "markdown", "norg", "rmd", "org", "codecompanion" },
    restart_highlighter = true,
    completions = {
      lsp = { enabled = true },
      blink = { enabled = true },
    },
    overrides = {
      buftype = {
        nofile = {
          enabled = true,
          code = {
            disable_background = true,
          },
          anti_conceal = { enabled = false },
          render_modes = true,
        },
      },
    },
    code = {
      width = "block",
      right_pad = 1,
    },
    pipe_table = {
      style = "full",
      border_enabled = true,
      cell = "padded",
      preset = "round",
    },
  },
}

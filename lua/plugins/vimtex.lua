return {
  "lervag/vimtex",
  lazy = false, -- Absolute must. VimTeX handles its own lazy loading.
  init = function()
    -- Use main leader or local leader for VimTeX shortcuts (default is \)
    vim.g.maplocalleader = ","

    -- PDF Viewer configuration (e.g., 'sioyek' or 'skim' for macOS; 'zathura' for Linux)
    vim.g.vimtex_view_method = "zathura"

    -- LaTeX compilation options
    vim.g.vimtex_compiler_method = "latexmk"

    -- Continuous compilation (compile on save)
    vim.g.vimtex_compiler_latexmk = {
      options = {
        "-shell-escape",
        "-verbose",
        "-file-line-error",
        "-synctex=1",
        "-interaction=nonstopmode",
      },
    }

    -- Filter out annoying warnings from the Quickfix window
    vim.g.vimtex_quickfix_ignore_filters = {
      "Underfull \\\\hbox",
      "Overfull \\\\hbox",
      "Underfull \\\\vbox",
      "Overfull \\\\vbox",
      "LaTeX Warning: Something's wrong--perhaps a missing \\\\item",
      "LaTeX Warning: Font shape",
      "Package hyperref Warning: Token not allowed in a PDF string",
      "Package hyperref Warning: Composite letter field ",
      "Package biblatex Warning: Data source",
    }
  end,
}

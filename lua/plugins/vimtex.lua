return {
  "lervag/vimtex",
  lazy = false, -- Absolute must. VimTeX handles its own lazy loading.
  init = function()
    -- Use global local leader (set in remap.lua) to avoid late override warnings
    -- PDF Viewer configuration (e.g., "sioyek" or "skim" for macOS; "zathura" for Linux)
    if vim.fn.has("mac") == 1 then
      vim.g.vimtex_view_method = "skim"
    else
      vim.g.vimtex_view_method = "zathura"
    end

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

    -- LaTeX syntax highlighting / conceal
    vim.g.vimtex_syntax_conceal = {
      accents = 1,
      ligatures = 1,
      cites = 1,
      fancy = 1,
      greek = 1,
      math_bounds = 1,
      math_delimiters = 1,
      math_fracs = 1,
      math_super_sub = 1,
      math_symbols = 1,
      sections = 0,
      styles = 1,
    }

    -- Folding
    vim.g.vimtex_fold_enabled = 1
    vim.g.vimtex_fold_manual = 0

    -- TOC
    vim.g.vimtex_toc_config = {
      name = "TOC",
      layers = { "content", "todo", "include" },
      split_width = 50,
      todo_sorted = 0,
      show_help = 1,
      show_numbers = 1,
    }

    -- SyncTeX / qf
    vim.g.vimtex_qf_mode = 0  -- use quickfix automatically
    vim.g.vimtex_quickfix_open_on_warning = 0
    vim.g.vimtex_view_automatic = 1

    -- Indent
    vim.g.vimtex_indent_enabled = 1
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

local langs = {
  "c",
  "cpp",
  "go",
  "java",
  "lua",
  "markdown",
  "markdown_inline",
  "ghostty",
  "python",
  "rust",
  "typescript",
  "javascript",
  "vimdoc",
  "bash",
  "zsh",
  "json",
  "yaml",
  "toml",
  "sql",
  "query",
  "vim",
  "tsx",
  "html",
  "css",
  "dockerfile",
  "make",
  "cmake",
  "proto",
  "regex",
  "swift",
  "html_tags",
  "ecma",
  "latex",
}

return {
  {
    -- Highlight, edit, and navigate code
    --
    -- The `main` branch of nvim-treesitter is a rewrite that targets
    -- Neovim 0.12+: it provides parsers, queries and the install machinery.
    -- Highlighting, indentation and text objects are enabled explicitly.
    "nvim-treesitter/nvim-treesitter",
    -- The rewrite does not support lazy loading.
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")

      -- Install the parsers we use. This is a no-op when they are present.
      ts.install(langs)

      -- Highlighting: provided by Neovim, enabled per filetype.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup(
          "MahdiTreesitter",
          { clear = true }
        ),
        pattern = langs,
        callback = function(args)
          vim.treesitter.start(args.buf)
        end,
      })

      -- Indentation: provided by nvim-treesitter, python keeps its own.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup(
          "MahdiTreesitterIndent",
          { clear = true }
        ),
        pattern = langs,
        callback = function(args)
          if vim.bo[args.buf].filetype == "python" then
            return
          end
          local lang =
            vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
          if lang and vim.treesitter.query.get(lang, "indents") then
            vim.bo[args.buf].indentexpr =
              "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}

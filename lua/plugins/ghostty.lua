return {
  -- 1. Ghostty's bundled vimfiles (syntax, omni-completion, ftdetect)
  {
    dir = (vim.env.GHOSTTY_RESOURCES_DIR or "") .. "/../vim/vimfiles",
    lazy = false,
    name = "ghostty-vimfiles",
    cond = vim.env.GHOSTTY_RESOURCES_DIR ~= nil,
  },

  -- 2. Tree-sitter grammar (standalone plugin, NOT via ensure_installed)
  {
    "bezhermoso/tree-sitter-ghostty",
    build = "make nvim_install",
  },

  -- 3. Validation on save
  {
    "isak102/ghostty.nvim",
    ft = "ghostty",
    config = true,
  },
}

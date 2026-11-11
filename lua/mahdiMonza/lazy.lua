-- Install Lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
local lazy = require("lazy")

lazy.setup({
  spec = { { import = "plugins" } },
  ui = {
    border = "rounded",
  },
  install = { colorscheme = { "onedark" } },
  checker = { enabled = true },
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    lazy.sync({ show = false })
  end,
})

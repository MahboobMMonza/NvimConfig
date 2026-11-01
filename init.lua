vim.loader.enable()
-- Expose an RPC socket for remote tools (Skim/nvr), but never fail if it's
-- already in use by another running Neovim instance.
pcall(vim.fn.serverstart, "/tmp/nvim.pipe")
require("mahdiMonza")

vim.loader.enable()
-- Expose an RPC socket for remote tools (Skim/nvr), but never fail if it's
-- already in use by another running Neovim instance.
pcall(vim.fn.serverstart, "/tmp/nvim.pipe")
require("mahdiMonza")
local ui = require("vim._core.ui2")
ui.enable({
  enable = true,
  msg = {
    target = "cmd",
    targets = {
      progress = "msg",
    },
  },
})

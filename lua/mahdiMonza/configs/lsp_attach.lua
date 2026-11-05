local mapper = require("mahdiMonza.configs.lsp_mappings")

local M = {}

local default_hooks = {}

M.register_base_hook = function(hook)
  table.insert(default_hooks, hook)
end

---@return table
function M.capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok, blink = pcall(require, "blink.cmp")
  if ok then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end
  return capabilities
end

M.lsp_attach_server_cfgs = {
  -- clangd's signature help is noisy and duplicates the native one.
  clangd = function(client, _)
    client.server_capabilities.signatureHelpProvider = false
  end,
  -- Mpls mapping to open a preview window
  mpls = function(_, bufnr)
    mapper.maps("n", "<leader>mp", function()
      vim.cmd("LspMplsOpenPreview")
    end, "Open Markdown Preview", bufnr)
  end,
}

-- Default handler, used for every server that has no specific handler.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspAttach", { clear = true }),
  callback = function(args)
    -- Common functionality for all LSPs
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    local bufnr = args.buf
    if client.server_capabilities.documentSymbolProvider then
      pcall(function()
        require("nvim-navic").setup({ lsp = { auto_attach = true } })
      end)
    end
    -- Shortcut for setting LSP keymaps
    mapper.set_maps(bufnr)
    -- Inlay hints
    if client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
    -- Code lens
    if client.server_capabilities.codeLensProvider then
      vim.lsp.codelens.enable(true, { bufnr = bufnr })
    end
    -- Linked ranges
    if client.server_capabilities.linkedEditingRangeProvider then
      vim.lsp.linked_editing_range.enable(true, { bufnr = bufnr })
    end
    -- Handling server-specific functionality
    local handler = M.lsp_attach_server_cfgs[client.name]
    if handler then
      handler(client, bufnr)
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    if vim.bo[args.buf].buftype == "nofile" then
      vim.diagnostic.enable(false, { bufnr = args.buf })
    end
  end,
})

M.maps = mapper.maps

return M

local M = {}
M.maps = function(mode, keys, func, desc, buf)
  if desc then
    desc = 'LSP: ' .. desc
  end

  vim.keymap.set(mode, keys, func, { buffer = buf, desc = desc, noremap = true })
end

M.set_maps = function(bufnr)
  M.maps('n', '<leader>rn', vim.lsp.buf.rename, 'Rename', bufnr)
  M.maps('n', '<leader>ca', vim.lsp.buf.code_action, 'Code Action', bufnr)
  M.maps('x', '<leader>ca', vim.lsp.buf.code_action, 'Ranged Code Action', bufnr)
  M.maps('n', 'gd', vim.lsp.buf.definition, 'Goto Definition', bufnr)
  M.maps('n', '<leader>gr', require('telescope.builtin').lsp_references, 'Goto References', bufnr)
  M.maps('n', '<leader>gI', vim.lsp.buf.implementation, 'Goto Implementation', bufnr)
  M.maps('n', '<leader>D', vim.lsp.buf.type_definition, 'Type Definition', bufnr)
  M.maps('n', '<leader>ds', require('telescope.builtin').lsp_document_symbols, 'Document Symbols', bufnr)
  M.maps('n', '<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace Symbols', bufnr)

  -- See `:help K` for why this keymap
  M.maps('n', 'K', vim.lsp.buf.hover, 'Hover Documentation', bufnr)
  M.maps('n', '<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation', bufnr)

  -- Lesser used LSP functionality
  M.maps('n', 'gD', vim.lsp.buf.declaration, 'Goto Declaration', bufnr)
  M.maps('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, 'Workspace Add Folder', bufnr)
  M.maps('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, 'Workspace Remove Folder', bufnr)
  M.maps('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, 'Workspace List Folders', bufnr)

  M.maps('n', '<leader>fmt', function(_)
    vim.lsp.buf.format()
  end, 'Format current buffer', bufnr)
end

return M

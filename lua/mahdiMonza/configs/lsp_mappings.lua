local M = {}

M.maps = function(mode, keys, func, desc, buf)
	if desc then
		desc = "LSP: " .. desc
	end

	vim.keymap.set(mode, keys, func, { buffer = buf, desc = desc, noremap = true })
end

M.set_maps = function(bufnr)
	M.maps("n", "<leader>rn", vim.lsp.buf.rename, "Rename", bufnr)
	M.maps("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action", bufnr)
	M.maps("x", "<leader>ca", vim.lsp.buf.code_action, "Ranged Code Action", bufnr)
	M.maps("n", "gd", function()
		Snacks.picker.lsp_definitions()
	end, "Goto Definition", bufnr)
	M.maps("n", "<leader>gr", function()
		Snacks.picker.lsp_references()
	end, "Goto References", bufnr)
	M.maps("n", "<leader>gI", function()
		Snacks.picker.lsp_implementations()
	end, "Goto Implementation", bufnr)
	M.maps("n", "<leader>gt", function()
		Snacks.picker.lsp_type_definitions()
	end, "Type Definition", bufnr)
	M.maps("n", "<leader>ds", function()
		Snacks.picker.lsp_symbols()
	end, "Document Symbols", bufnr)
	M.maps("n", "<leader>ws", function()
		Snacks.picker.lsp_workspace_symbols()
	end, "Workspace Symbols", bufnr)

	-- See `:help K` for why this keymap
	M.maps("n", "K", function()
		vim.lsp.buf.hover()
	end, "Hover Documentation", bufnr)
	M.maps("n", "<C-k>", function()
		vim.lsp.buf.signature_help()
	end, "Signature Documentation", bufnr)

	-- Lesser used LSP functionality
	M.maps("n", "gD", function()
		Snacks.picker.lsp_declarations()
	end, "Goto Declaration", bufnr)
	M.maps("n", "<leader>wa", function()
		local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
		if dir and dir ~= "" then
			vim.lsp.buf.add_workspace_folder(dir)
		end
	end, "Workspace Add Folder", bufnr)
	M.maps("n", "<leader>wr", function()
		local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
		if dir and dir ~= "" then
			vim.lsp.buf.remove_workspace_folder(dir)
		end
	end, "Workspace Remove Folder", bufnr)
	M.maps("n", "<leader>wl", function()
		local folders = vim.lsp.buf.list_workspace_folders()
		vim.ui.select(folders, { prompt = "Workspace folders:" }, function(_) end)
	end, "Workspace List Folders", bufnr)
	-- M.maps("n", "<leader>cl", vim.lsp.)
end

return M

local config_struct = {}

config_struct.get_exec_path = function(prompt)
	local input = require("mini.input")
	local value = input.get({ prompt = prompt, default = vim.fn.getcwd() .. "/" })
	if value == nil then
		return vim.fn.getcwd() .. "/"
	end
	return value ~= "" and value or (vim.fn.getcwd() .. "/")
end

config_struct.get_address = function(prompt)
	local input = require("mini.input")
	local value = input.get({ prompt = prompt, default = "" })
	return value ~= "" and value or nil
end

config_struct.arginp = function(prompt, completion)
	local input = require("mini.input")
	local value = input.get({ prompt = prompt, default = "" })
	if completion == "file" then
		return value ~= "" and value or "/dev/null"
	end
	local out = {}
	for token in (value or ""):gmatch("%S+") do
		table.insert(out, token)
	end
	return out
end
-- Locate the CodeLLDB adapter installed by Mason.
-- The old configuration pointed at `OpenDebugAD7`, which only exists on
-- Windows; codelldb works on every platform.
local function codelldb()
	local ok, registry = pcall(require, "mason-registry")
	if not ok then
		return nil
	end
	local package = registry.get_package("codelldb")
	if not package or not package:is_installed() then
		return nil
	end
	local install_path = package:get_install_path()
	local mason_data = vim.fn.stdpath("data") .. "/mason"
	local command = install_path .. "/extension/adapter/codelldb"
	local liblldb = vim.fn.glob(install_path .. "/extension/lldb/lib/liblldb.*", true, true)[1]
		or vim.fn.glob(mason_data .. "/opt/codelldb/lldb/lib/liblldb.*", true, true)[1]
	if vim.fn.executable(command) == 0 then
		command = vim.fn.exepath("codelldb")
	end
	if command == "" then
		return nil
	end
	return { command = command, liblldb = liblldb }
end

config_struct.adapters = {}
config_struct.configurations = {}

local codelldb_paths = codelldb()
config_struct.adapters.cppdbg = {
	id = "cppdbg",
	type = "executable",
	command = codelldb_paths and codelldb_paths.command or "codelldb",
	args = codelldb_paths and codelldb_paths.liblldb and { "--liblldb", codelldb_paths.liblldb } or nil,
}

local function launch_config()
	return {
		name = "Launch file",
		type = "cppdbg",
		request = "launch",
		program = function()
			return require("dap.utils").pick_file()
		end,
		cwd = "${workspaceFolder}",
		args = function()
			return config_struct.arginp("Args: ")
		end,
		stopAtEntry = true,
		setupCommands = {
			{
				text = "-enable-pretty-printing",
				description = "enable pretty printing",
				ignoreFailures = false,
			},
		},
	}
end

config_struct.configurations.c_cpp = {
	launch_config(),
	{
		name = "Launch file (stdin)",
		type = "cppdbg",
		request = "launch",
		program = function()
			pcall(function()
				require("telescope").load_extension("ui-select")
			end)
			return require("dap.utils").pick_file()
		end,
		cwd = "${workspaceFolder}",
		args = function()
			return config_struct.arginp("Args: ")
		end,
		stdio = {
			function()
				local value = (require("mini.input")).get({ prompt = "Stdio file: ", default = "" })
				return value ~= "" and value or "/dev/null"
			end,
			"/dev/stdout",
			"/dev/stderr",
		},
		stopAtEntry = true,
		setupCommands = {
			{
				text = "-enable-pretty-printing",
				description = "enable pretty printing",
				ignoreFailures = false,
			},
		},
	},
	{
		name = "Attach to gdbserver",
		type = "cppdbg",
		request = "launch",
		MIMode = "gdb",
		miDebuggerServerAddress = function()
			return config_struct.get_address("Server Address: ")
		end,
		miDebuggerPath = vim.fn.exepath("gdb") ~= "" and vim.fn.exepath("gdb") or "/usr/bin/gdb",
		cwd = "${workspaceFolder}",
		args = function()
			return config_struct.arginp("Args: ")
		end,
		program = function()
			pcall(function()
				require("telescope").load_extension("ui-select")
			end)
			return require("dap.utils").pick_file()
		end,
		stopAtEntry = true,
		setupCommands = {
			{
				text = "-enable-pretty-printing",
				description = "enable pretty printing",
				ignoreFailures = false,
			},
		},
	},
}

return config_struct

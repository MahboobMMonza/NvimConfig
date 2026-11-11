local config_struct = {}

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
  local liblldb = vim.fn.glob(
    install_path .. "/extension/lldb/lib/liblldb.*",
    true,
    true
  )[1] or vim.fn.glob(
    mason_data .. "/opt/codelldb/lldb/lib/liblldb.*",
    true,
    true
  )[1]
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
config_struct.adapters.codelldb = {
  id = "codelldb",
  type = "executable",
  command = codelldb_paths and codelldb_paths.command or "codelldb",
  args = codelldb_paths and codelldb_paths.liblldb and {
    "--liblldb",
    codelldb_paths.liblldb,
  } or nil,
}

config_struct.configurations.c_cpp = {
  {
    name = "Launch file",
    type = "codelldb",
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
    },
  },
  {
    name = "Launch file (stdin)",
    type = "codelldb",
    request = "launch",
    program = function()
      return require("dap.utils").pick_file()
    end,
    cwd = "${workspaceFolder}",
    args = function()
      return config_struct.arginp("Args: ")
    end,
    stdio = {
      function()
        local value = (require("mini.input")).get({
          prompt = "Stdio file: ",
          default = "",
        })
        return value ~= "" and value or "/dev/null"
      end,
      "/dev/stdout",
      "/dev/stderr",
    },
    stopAtEntry = true,
    setupCommands = {
    },
  },
  {
    name = "Attach to gdbserver",
    type = "codelldb",
    request = "attach",
    pid = function()
      local value = require("mini.input").get({ prompt = " PID: ", default = "" })
      return value ~= "" and tonumber(value) or nil
    end,
    stopAtEntry = true,
    setupCommands = {
    },
  },
}

return config_struct

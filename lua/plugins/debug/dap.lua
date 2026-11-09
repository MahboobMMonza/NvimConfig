-- dap.lua: DAP debugger integration for C/C++ and Python.
--
-- Ownership split:
--   - signs: gutter signs for breakpoints
--   - maps: helper to bind debug keys
--   - vim.ui.input: editor-standard prompt helper
--   - dap.adapters/configurations: language-specific launch setups
--   - noregister commands: helper tasks like loading .vscode/launch.json
local v = vim





-- Debug signs used in the gutter for breakpoints.
local function signs(name, sign, thl)
  v.fn.sign_define(name, { text = sign, texthl = thl, linehl = "", numhl = "" })
end

-- Utility for exposing key mappings with consistent DAP descriptions.
local maps = function(mode, keys, func, desc)
  if desc then
    desc = "DAP: " .. desc
  end

  v.keymap.set(mode, keys, func, { desc = desc, noremap = true })
end


-- Plugin spec registered to Lazy: supplies adapters, launch configs, and key mappings.
return {
  "mfussenegger/nvim-dap",
  config = function()
    local dap = require("dap")
    dap.set_log_level("TRACE")

    -- Launch configurations
    local configs_struct = require("mahdiMonza.configs.dap_configs")
    dap.adapters.cppdbg = configs_struct.adapters.cppdbg
    dap.configurations.cpp = configs_struct.configurations.c_cpp
    dap.configurations.c = configs_struct.configurations.c_cpp

    -- Python (debugpy) adapter and sane configs.
    dap.adapters.python = function(cb, config)
      if config.request == "attach" then
        cb({
          type = "server",
          port = config.port or 5678,
          host = config.host or "127.0.0.1",
        })
      else
        cb({
          type = "executable",
          command = "python",
          args = { "-m", "debugpy.adapter" },
        })
      end
    end
    dap.configurations.python = {
      {
        type = "python",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        pythonPath = function()
          local cwd = vim.fn.getcwd()
          if vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
            return cwd .. "/.venv/bin/python"
          elseif vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
            return cwd .. "/venv/bin/python"
          end
          return "python"
        end,
        args = function()
          local argstr = configs_struct.arginp("Args: ")
          if type(argstr) == "function" then
            argstr = argstr()
          end
          if not argstr or argstr == "" then
            return {}
          end
          return vim.split(argstr, " ", { trimempty = true })
        end,
      },
      {
        type = "python",
        request = "launch",
        name = "Launch module",
        module = function()
          return vim.fn.input("Module name: ")
        end,
        pythonPath = "python",
      },
      {
        type = "python",
        request = "attach",
        name = "Attach (port 5678)",
        connect = { host = "127.0.0.1", port = 5678 },
      },
    }

    signs("DapBreakpoint", "●", "DiagnosticSignHint")
    signs("DapBreakpointCondition", "󰟃", "DiagnosticSignWarn")
    signs("DapLogPoint", "󰸥", "DiagnosticSignInfo")
    signs("DapBreakpointRejected", "󰅙", "DiagnosticSignError")
    -- keybinds
    maps("n", "<leader>dg", dap.continue, "DAP Forwards Continue")
    maps("n", "<leader>dG", dap.reverse_continue, "DAP Reverse Continue")
    maps("n", "<leader>df", dap.step_over, "DAP Step Over")
    maps("n", "<leader>do", dap.step_out, "DAP Step Out")
    maps("n", "<leader>di", function()
      dap.step_into({ askForTargets = true })
    end, "DAP Step Into")
    maps("n", "<leader>db", dap.toggle_breakpoint, "DAP Toggle Breakpoint")
    maps("n", "<leader>dC", dap.clear_breakpoints, "DAP Clear Breakpoints")
    maps("n", "<leader>dS", dap.step_back, "DAP Step Back")
    maps("n", "<leader>dB", function()
      vim.ui.input({ prompt = "Condition: " }, function(condition)
        if condition and condition ~= "" then
          dap.set_breakpoint(condition)
        end
      end)
    end, "DAP Set Conditional Breakpoint (input condition)")
    maps("n", "<leader>dv", function()
      vim.ui.input({ prompt = "Condition: " }, function(condition)
        if not condition or condition == "" then
          return
        end
        vim.ui.input({ prompt = "Hits: " }, function(hits)
          dap.set_breakpoint(condition, (hits ~= "" and hits or nil))
        end)
      end)
    end, "DAP Set Conditional Breakpoint (input condition)")
    maps("n", "<leader>dV", function()
      vim.ui.input({ prompt = "Condition: " }, function(condition)
        if not condition or condition == "" then
          return
        end
        vim.ui.input({ prompt = "Hits: " }, function(hits)
          vim.ui.input({ prompt = "Log: " }, function(log)
            dap.set_breakpoint(
              condition,
              (hits ~= "" and hits or nil),
              (log ~= "" and log or nil)
            )
          end)
        end)
      end)
    end, "DAP Set Complete Conditional Breakpoint (input conditions)")
    maps("n", "<leader>dl", function()
      vim.ui.input({ prompt = "Log: " }, function(log)
        if log and log ~= "" then
          dap.set_breakpoint(nil, nil, log)
        end
      end)
    end, "DAP Set Log Breakpoint (input condition)")
    maps("n", "<leader>de", function()
      vim.ui.input({ prompt = "Exception Types: " }, function(types)
        if types and types ~= "" then
          dap.set_exception_breakpoints(
            vim.split(types, " ", { trimempty = true })
          )
        end
      end)
    end, "DAP Set Exception Breakpoint (input condition)")
    maps("n", "<leader>dtt", dap.terminate, "DAP Terminate")
    maps("n", "<leader>dr", dap.repl.open, "DAP REPL Open")

    -- Additional DAP QoL mappings (Snacks-friendly / no conflicts):
    maps("n", "<leader>dF", dap.run_to_cursor, "DAP Run to Cursor")
    maps("n", "<leader>dW", function()
      if dap.widgets then
        dap.widgets.hover()
      end
    end, "DAP Widgets (hover/evaluate)")

    -- Load the configurations of a `.vscode/launch.json` for the current
    -- project, so they can be picked like any other configuration.
    vim.api.nvim_create_user_command("DapLaunchJson", function()
      local ok, vscode = pcall(require, "dap.ext.vscode")
      if not ok then
        vim.notify(
          "nvim-dap does not provide dap.ext.vscode",
          vim.log.levels.WARN
        )
        return
      end
      local configs = vscode.getconfigs()
      if vim.tbl_isempty(configs) then
        vim.notify("No launch.json configurations found", vim.log.levels.WARN)
        return
      end
      dap.configurations.launch_json = configs
      vim.notify(("Loaded %d launch.json configurations"):format(#configs))
    end, { desc = "Load .vscode/launch.json configurations" })
  end,
}

return {
  "igorlfs/nvim-dap-view",
  dependencies = {
    "mfussenegger/nvim-dap",
  },
  event = { "BufReadPre", "VeryLazy" },
  opts = {
    winbar = {
      show = true,
      sections = {
        "watches",
        "scopes",
        "exceptions",
        "breakpoints",
        "threads",
        "repl",
        "console",
      },
      default_section = "watches",
      show_keymap_hints = true,
      controls = {
        enabled = true,
        position = "right",
        buttons = {
          "play",
          "step_into",
          "step_over",
          "step_out",
          "step_back",
          "run_last",
          "terminate",
          "disconnect",
        },
      },
    },
    windows = {
      size = 0.35,
      position = "left",
    },
    auto_toggle = true,
    switchbuf = "usetab,uselast",
    virtual_text = {
      enabled = true,
    },
  },
  config = function(_, opts)
    local ok, dap_view = pcall(require, "dap-view")
    if ok and type(dap_view.setup) == "function" then
      dap_view.setup(opts)
    end

    if not vim.g._dap_view_completion_facilitated then
      vim.g._dap_view_completion_facilitated = true

      local function is_dap_buffer(ft)
        return ft == "dap-repl"
          or vim.startswith(ft, "dapui_")
          or vim.startswith(ft, "dap-")
          or vim.startswith(ft, "dap-view")
          or vim.startswith(ft, "dap_view")
      end

      pcall(function()
        local blink_dap = require("blink-cmp-dap")
        local original_enabled = blink_dap.enabled
        blink_dap.enabled = function(self)
          local ft = vim.bo.filetype
          if is_dap_buffer(ft) then
            local current_session = require("dap").session()
            if
              current_session
              and current_session.capabilities.supportsCompletionsRequest
            then
              return true
            end
          end
          return type(original_enabled) == "function" and original_enabled(self)
            or false
        end
      end)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "dap*", "dap-view*" },
        group = vim.api.nvim_create_augroup(
          "dap_view_completion",
          { clear = true }
        ),
        callback = function(event)
          local ft = vim.bo[event.buf].filetype
          if not is_dap_buffer(ft) then
            return
          end
          pcall(function()
            if _G._dap_view_blink_cmp_loaded ~= true then
              require("blink.cmp")
              _G._dap_view_blink_cmp_loaded = true
            end
            require("blink.cmp").add_filetype_source(ft, "dap")
          end)
        end,
      })
    end
  end,
}

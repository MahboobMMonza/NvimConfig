return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  version = "1.*",
  config = function(_, opts)
    require("luasnip.loaders.from_vscode").lazy_load()
    require("blink.cmp").setup(opts)
  end,
  dependencies = {
    "rafamadriz/friendly-snippets",
    "mayromr/blink-cmp-dap",
    "Kaiser-Yang/blink-cmp-git",
    "barrettruth/blink-cmp-ghostty",
    { "L3MON4D3/LuaSnip", version = "v2.*" },
  },
  opts = {
    keymap = {
      preset = "default",
      ["<C-d>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      ["<C-e>"] = { "cancel", "fallback" },
      ["<C-l>"] = { "accept", "fallback" },
      ["<C-j>"] = {
        function(cmp)
          if cmp.is_visible() then
            return cmp.select_next()
          end
          local luasnip = package.loaded.luasnip or require("luasnip")
          if luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
            return true
          end
          return false
        end,
        "fallback",
      },
      ["<C-k>"] = {
        function(cmp)
          if cmp.is_visible() then
            return cmp.select_prev()
          end
          local luasnip = package.loaded.luasnip or require("luasnip")
          if luasnip.jumpable(-1) then
            luasnip.jump(-1)
            return true
          end
          return false
        end,
        "fallback",
      },
    },
    appearance = { nerd_font_variant = "mono" },
    completion = { documentation = { auto_show = true } },
    fuzzy = {
      implementation = "prefer_rust_with_warning",
      sorts = {
        "score",
        "sort_text",
      },
    },
    cmdline = { enabled = true },
    snippets = { preset = "luasnip" },
    sources = {
      default = { "lsp", "snippets", "path", "git", "buffer" },
      per_filetype = {
        ["dap-repl"] = { "dap" },
        ["dapui_watches"] = { "dap" },
        ["dapui_hover"] = { "dap" },
      },
      providers = {
        lsp = { fallbacks = { "buffer" } },
        dap = {
          name = "dap",
          module = "blink-cmp-dap",
        },
        git = {
          name = "Git",
          module = "blink-cmp-git",
          opts = { git_status = true },
        },
        ghostty = {
          name = "Ghostty",
          module = "blink-cmp-ghostty",
        },
      },
    },
  },
}

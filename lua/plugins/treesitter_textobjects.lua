local function map(mode, lhs, fn, desc)
  vim.keymap.set(
    mode,
    lhs,
    fn,
    { desc = "Treesitter: " .. desc, noremap = true }
  )
end

return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    local select = require("nvim-treesitter-textobjects.select")
    local move = require("nvim-treesitter-textobjects.move")
    local swap = require("nvim-treesitter-textobjects.swap")

    require("nvim-treesitter-textobjects").setup({
      select = {
        lookahead = true,
      },
      move = {
        set_jumps = true,
      },
    })

    -- Select
    map({ "x", "o" }, "aa", function()
      select.select_textobject("@parameter.outer", "textobjects")
    end, "Select parameter (outer)")
    map({ "x", "o" }, "ia", function()
      select.select_textobject("@parameter.inner", "textobjects")
    end, "Select parameter (inner)")
    map({ "x", "o" }, "af", function()
      select.select_textobject("@function.outer", "textobjects")
    end, "Select function (outer)")
    map({ "x", "o" }, "if", function()
      select.select_textobject("@function.inner", "textobjects")
    end, "Select function (inner)")
    map({ "x", "o" }, "ac", function()
      select.select_textobject("@class.outer", "textobjects")
    end, "Select class (outer)")
    map({ "x", "o" }, "ic", function()
      select.select_textobject("@class.inner", "textobjects")
    end, "Select class (inner)")

    -- Move
    map({ "n", "x", "o" }, "]m", function()
      move.goto_next_start("@function.outer", "textobjects")
    end, "Next function start")
    map({ "n", "x", "o" }, "]]", function()
      move.goto_next_start("@class.outer", "textobjects")
    end, "Next class start")
    map({ "n", "x", "o" }, "]M", function()
      move.goto_next_end("@function.outer", "textobjects")
    end, "Next function end")
    map({ "n", "x", "o" }, "][", function()
      move.goto_next_end("@class.outer", "textobjects")
    end, "Next class end")
    map({ "n", "x", "o" }, "[m", function()
      move.goto_previous_start("@function.outer", "textobjects")
    end, "Previous function start")
    map({ "n", "x", "o" }, "[[", function()
      move.goto_previous_start("@class.outer", "textobjects")
    end, "Previous class start")
    map({ "n", "x", "o" }, "[M", function()
      move.goto_previous_end("@function.outer", "textobjects")
    end, "Previous function end")
    map({ "n", "x", "o" }, "[]", function()
      move.goto_previous_end("@class.outer", "textobjects")
    end, "Previous class end")

    -- Swap
    map("n", "<leader>a", function()
      swap.swap_next("@parameter.inner")
    end, "Swap parameter with next")
    map("n", "<leader>A", function()
      swap.swap_previous("@parameter.inner")
    end, "Swap parameter with previous")
  end,
}

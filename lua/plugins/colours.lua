return {
  'navarasu/onedark.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('onedark').setup({
      style = 'deep',
      highlights = {
        IndentBlanklineContextChar = {
          fg = '$purple',
          fmt = 'nocombine',
        },
        ["@lsp.type.interface"] = { fg = '$green', fmt = 'italic', },
        ["@string.special"] = { fg = '$orange' },
        ["@string.escape"] = { fg = '$orange' },
        ["@character.special"] = { fg = '$orange' },
        -- ["@punctuation.special"] = { fg = '$orange' },
        ["@type.qualifier"] = { fg = '$purple', fmt = 'italic' },
        ["@type.builtin.java"] = { fg = '$purple' },
        ["@lsp.type.property"] = { fg = '$red' },
        ["@field"] = { fg = '$red' },
        ["@parameter"] = { fg = '$fg', fmt = 'italic' },
        ["@lsp.type.parameter"] = { fg = '$fg', fmt = 'italic' },
        ["@constant.java"] = { fmt = 'italic' },
      },
      ending_tildes = false,
    })
    require('onedark').load()
  end
}

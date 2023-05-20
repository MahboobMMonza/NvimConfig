local signs = {
 Error = "", Warn = "", Hint = "", Info = "", Debug=""
}
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, {text = icon, texthl = hl, numhl = hl })
end
--[[
diagnostics = {
    BoldError = "",
    Error = "",
    BoldWarning = "",
    Warning = "",
    BoldInformation = "",
    Information = "",
    BoldQuestion = "",
    Question = "",
    BoldHint = "",
    Hint = "",
    Debug = "",
    Trace = "✎",
  }
 --]]

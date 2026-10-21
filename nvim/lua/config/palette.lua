-- A vivid palette with neutral ordinary text and transparent backgrounds.
local M = {}
M.colors = {
  white = "#F8F8F2", yellow = "#FFD866", green = "#A8FF60", cyan = "#65D9EF",
  blue = "#82AAFF", red = "#FF6B7A", purple = "#C792EA", pink = "#FF6AC1",
  orange = "#FF9D5C", comment = "#8597AD",
}
function M.apply()
  local c = M.colors
  local groups = {
    white = { "Normal", "NormalNC", "Identifier", "@variable", "@variable.parameter", "@module",
      "@lsp.type.variable", "@lsp.type.parameter", "@lsp.type.namespace", "@punctuation.bracket", "@punctuation.delimiter", "@operator", "Operator" },
    yellow = { "Function", "@function", "@function.call", "@function.method", "@function.method.call", "@function.builtin", "@function.macro",
      "@constructor", "@lsp.type.function", "@lsp.type.method" },
    green = { "String", "Character", "@string", "@string.regexp", "@string.special", "@string.special.url", "@character" },
    cyan = { "@property", "@variable.member", "@field", "@tag.attribute", "@lsp.type.property", "@lsp.type.enumMember", "@constant", "Constant" },
    blue = { "Type", "@type", "@type.builtin", "@type.definition", "@lsp.type.type", "@lsp.type.class", "@lsp.type.interface", "@lsp.type.struct", "@lsp.type.enum",
      "@variable.builtin", "@tag", "@keyword.function", "@keyword.conditional", "@keyword.repeat", "Conditional", "Repeat" },
    purple = { "Keyword", "Statement", "@keyword", "@keyword.declaration", "@keyword.modifier", "@keyword.type", "@storageclass" },
    pink = { "Include", "PreProc", "@keyword.import", "@keyword.declaration.export", "@attribute", "@lsp.type.decorator" },
    orange = { "Number", "Float", "@number", "@number.float", "@keyword.return", "@keyword.exception", "Exception" },
    red = { "Boolean", "@boolean", "@constant.builtin" },
    comment = { "Comment", "@comment", "Folded" },
  }
  for color, names in pairs(groups) do
    for _, name in ipairs(names) do
      vim.api.nvim_set_hl(0, name, { fg = c[color] })
    end
  end
  -- Semantic token modifiers must not recolor ordinary const variables.
  for _, name in ipairs({ "@lsp.typemod.variable.readonly", "@lsp.typemod.variable.constant" }) do
    vim.api.nvim_set_hl(0, name, { link = "@variable" })
  end
  vim.api.nvim_set_hl(0, "@lsp.typemod.property.readonly", { link = "@property" })
  vim.api.nvim_set_hl(0, "@lsp.typemod.keyword.controlFlow", { fg = c.orange })
  vim.api.nvim_set_hl(0, "@string.escape", { fg = c.yellow })
end
return M

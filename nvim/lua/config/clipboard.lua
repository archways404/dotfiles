local M = {}

function M.paste()
  local lines = vim.fn.getreg("+", 1, true)
  if #lines == 0 then return end
  -- nvim_paste handles Normal, Insert and Visual modes (including replacement).
  -- Normalize CRLF from Windows without changing genuine internal line breaks.
  local text = table.concat(lines, "\n"):gsub("\r\n", "\n")
  if vim.fn.getregtype("+") == "V" then text = text .. "\n" end
  vim.api.nvim_paste(text, true, -1)
end

function M.setup()
  local map = vim.keymap.set
  map("x", "<D-c>", '"+y', { desc = "Copy selection to system clipboard" })
  map("x", "<C-c>", '"+y', { desc = "Copy selection to system clipboard" })
  map("n", "<D-c>", '"+yy', { desc = "Copy line to system clipboard" })
  map({ "n", "x" }, "<leader>cy", '"+y', { desc = "Copy to system clipboard" })
  map("n", "<leader>cy", '"+yy', { desc = "Copy line to system clipboard" })
  for _, key in ipairs({ "<D-v>", "<C-v>" }) do
    map({ "n", "x", "i" }, key, M.paste, { desc = "Paste from system clipboard" })
    map("c", key, "<C-r><C-o>+", { desc = "Paste clipboard into command line" })
  end
  map({ "n", "x" }, "<leader>cp", M.paste, { desc = "Paste from system clipboard" })
  map({ "n", "x" }, "<C-q>", "<C-v>", { desc = "Visual block selection" })
  map({ "n", "x" }, "<leader>cB", "<C-v>", { desc = "Visual block selection" })
end

return M

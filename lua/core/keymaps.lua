vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating window of [E]rror" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<C-j>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-h>", ":vertical resize -2<CR>", { silent = true, desc = "Resize window vertically (-2)" })
vim.keymap.set("n", "<C-l>", ":vertical resize +2<CR>", { silent = true, desc = "Resize window vertically (+2)" })


local function get_current_function()
  local node = vim.treesitter.get_node()
  while node do
    if node:type() == "function_definition" or node:type() == "function_declaration" then
      return node
    end
    node = node:parent()
  end
  return nil
end

local function goto_function_start()
  local node = get_current_function()
  if node then
    local start_row, start_col, _, _ = node:range()
    vim.cmd("normal! m`")  -- Save cursor position
    vim.cmd("normal! " .. (start_row + 1) .. "G" .. (start_col + 1) .. "|")  -- Move cursor safely
  end
end

local function goto_function_end()
  local node = get_current_function()
  if node then
    local _, _, end_row, end_col = node:range()
    vim.cmd("normal! m`")  -- Save cursor position
    vim.cmd("normal! " .. (end_row + 1) .. "G" .. (end_col + 1) .. "|")  -- Move cursor safely
  end
end

vim.keymap.set("n", "gk", goto_function_start, { desc = "Go to start of function" })
vim.keymap.set("n", "gj", goto_function_end, { desc = "Go to end of function" })


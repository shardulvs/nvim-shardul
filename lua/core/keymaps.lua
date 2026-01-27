vim.keymap.set("n", "<C-Up>",   ":tabprevious<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-Down>", ":tabnext<CR>",     { noremap = true, silent = true })

vim.keymap.set("n", "<C-z>", "<nop>")
vim.keymap.set("i", "<C-z>", "<nop>")
vim.keymap.set("v", "<C-z>", "<nop>")

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating window of [E]rror" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<A-Left>",  "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<A-Down>",  "<C-w><C-j>", { desc = "Move focus to the window below" })
vim.keymap.set("n", "<A-Up>",    "<C-w><C-k>", { desc = "Move focus to the window above" })
vim.keymap.set("n", "<A-Right>", "<C-w><C-l>", { desc = "Move focus to the right window" })

vim.keymap.set("n", "<S-A-Left>",  ":vertical resize -2<CR>", { silent = true, desc = "Resize window narrower" })
vim.keymap.set("n", "<S-A-Right>", ":vertical resize +2<CR>", { silent = true, desc = "Resize window wider" })
vim.keymap.set("n", "<S-A-Up>",    ":resize -2<CR>",          { silent = true, desc = "Resize window shorter" })
vim.keymap.set("n", "<S-A-Down>",  ":resize +2<CR>",          { silent = true, desc = "Resize window taller" })

-- Move tab one left
vim.keymap.set('n', '<C-S-PageUp>', ':tabmove -1<CR>', { silent = true })

-- Move tab one right
vim.keymap.set('n', '<C-S-PageDown>', ':tabmove +1<CR>', { silent = true })

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
        vim.cmd("normal! m`") -- Save cursor position
        vim.cmd("normal! " .. (start_row + 1) .. "G" .. (start_col + 1) .. "|") -- Move cursor safely
    end
end

local function goto_function_end()
    local node = get_current_function()
    if node then
        local _, _, end_row, end_col = node:range()
        vim.cmd("normal! m`") -- Save cursor position
        vim.cmd("normal! " .. (end_row + 1) .. "G" .. (end_col + 1) .. "|") -- Move cursor safely
    end
end

vim.keymap.set("n", "gk", goto_function_start, { desc = "Go to start of function" })
vim.keymap.set("n", "gj", goto_function_end, { desc = "Go to end of function" })

-- toggle virtual edit all
vim.keymap.set("n", "<Leader>ve", function()
    local ve = vim.opt.virtualedit:get()
    if vim.tbl_contains(ve, "all") then
        vim.opt.virtualedit = {}
        print("virtualedit OFF")
    else
        vim.opt.virtualedit = { "all" }
        print("virtualedit=all ON")
    end
end, { desc = "Toggle virtualedit=all" })

function BlockDelete()
    local reginfo = vim.fn.getreginfo('"')
    local regcont = reginfo.regcontents
    local width = vim.fn.strchars(regcont[1] or "")
    local height = #regcont
    local spaces = string.rep(" ", width)
    local regcontents = {}
    for i = 1, height do
        regcontents[i] = spaces
    end
    vim.fn.setreg("z", regcontents, "b")
    BlockPaste("z", false)
end

vim.keymap.set(
    "x", -- visual‑mode
    "<leader>x", -- trigger
    "y<Cmd>lua BlockDelete()<CR>", -- exit visual, then Lua
    { desc = "Block Delete" }
)

vim.keymap.set("n", "<leader>p", function()
    BlockPaste('"', true)
end, { desc = "Block Paste" })

function BlockPaste(regname, ignore_spaces)
    local reginfo = vim.fn.getreginfo(regname)
    local regcontents = reginfo.regcontents
    local pos = vim.fn.getcurpos()
    local row = pos[2] -- line number
    local col = pos[3] -- column number of last character + 1 (1 for empty line)
    local off = pos[4] -- column number of caret - column number of last character - 1 (column number of caret - pos[3])
    local current_line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""
    local real_col = vim.str_utfindex(current_line, col - 1) + 1
    -- vim.notify("difference of " .. (col - real_col))
    local orig_col = col
    col = real_col
    local caret = col + off -- column number of caret
    local buf = 0 -- current buffer

    for i, line in ipairs(regcontents) do
        local target_row = row - 1 + (i - 1)
        local line_chars = vim.fn.strchars(line)
        for j = 0, line_chars - 1 do
            local existing_line = vim.api.nvim_buf_get_lines(buf, target_row, target_row + 1, false)[1] or ""
            local target_col = caret + (j - 1) -- the column just after which next character is going to be put
            local line_len = vim.fn.strchars(existing_line)
            local char = vim.fn.strcharpart(line, j, 1)
            -- Pad with spaces if needed
            if char ~= " " or not ignore_spaces then
                if target_col >= line_len then
                    local pad_len = target_col - line_len + 1
                    local pad = string.rep(" ", pad_len)
                    existing_line = existing_line .. pad
                    vim.api.nvim_buf_set_lines(buf, target_row, target_row + 1, false, { existing_line })
                end
                -- Replace 1 character
                local byte_start = vim.fn.byteidx(existing_line, target_col)
                local byte_end = vim.fn.byteidx(existing_line, target_col + 1)
                vim.api.nvim_buf_set_text(buf, target_row, byte_start, target_row, byte_end, { char })
            end
        end
    end
    vim.cmd([[%s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(buf, { row, orig_col + off - 1 })
end

vim.keymap.set('n', '<leader>y', function()
  local filename = vim.fn.expand('%:t')
  local line = vim.fn.line('.')
  local result = filename .. ':' .. line
  vim.fn.setreg('+', result)  -- Copy to system clipboard
  print('Copied to clipboard: ' .. result)
end, { desc = 'Copy filename:line to clipboard' })

-- Keymap: Open the current file in a new tab and move the cursor to the same line number
vim.keymap.set('n', '<leader>tn', function()
  local file = vim.api.nvim_buf_get_name(0)
  local line = vim.api.nvim_win_get_cursor(0)[1]

  -- Open a new tab and edit the same file
  vim.cmd('tabnew ' .. file)

  -- Move the cursor to the same line
  vim.api.nvim_win_set_cursor(0, { line, 0 })
end, { desc = 'Open current file in new tab at same line number' })

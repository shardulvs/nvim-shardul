vim.keymap.set("n", "<leader>bp", function()
    local reginfo = vim.fn.getreginfo('"')
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
            if char ~= " " then
                if target_col >= line_len then
                    local pad_len = target_col - line_len + 1
                    local pad = string.rep(" ", pad_len)
                    existing_line = existing_line .. pad
                    vim.api.nvim_buf_set_lines(buf, target_row, target_row + 1, false, { existing_line })
                end
                -- Replace 1 character
                local byte_start = vim.fn.byteidx(existing_line, target_col)
                vim.api.nvim_buf_set_text(buf, target_row, byte_start, target_row, byte_start + 1, { char })
            end
        end
    end
    vim.api.nvim_win_set_cursor(buf, { row, orig_col + off - 1 })
end, { desc = "Block Paste" })

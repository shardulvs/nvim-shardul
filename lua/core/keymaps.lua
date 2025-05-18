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

-- block_delete.lua

function block_delete()
	local reginfo = vim.fn.getreginfo('"')
  local regcont = reginfo.regcontents
	local width = vim.fn.strchars(regcont[1] or "")
	local height = #regcont

	-- 4) Generate a block of spaces:
	local spaces = string.rep(" ", width)
	local regcontents = {}
	for i = 1, height do
		regcontents[i] = spaces
	end

	-- 5) Set named register "z" as a blockwise register:
	vim.fn.setreg("z", regcontents, "b")

	-- 6) Call your custom block paste logic using "z":
	vim.cmd('lua block_paste("z")')
end

vim.keymap.set(
	"x", -- visual‑mode
	"<leader>bd", -- trigger
	"y<Cmd>lua block_delete()<CR>", -- exit visual, then Lua
	{ desc = "Block‑delete (replace block with spaces)" }
)

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

function block_paste(regname)
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
	vim.api.nvim_win_set_cursor(buf, { row, orig_col + off - 1 })
end

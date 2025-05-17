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

vim.keymap.set("n", "<leader>p", function()
	-- 1) Grab the current default‑register contents into a Lua table
	local reg = vim.fn.getreg('"', 1, true)
	if type(reg) ~= "table" or vim.tbl_isempty(reg) then
		print("Nothing in register to paste")
		return
	end

	-- 2) Compute block height & width
	local height = #reg
	local width = 0
	for _, line in ipairs(reg) do
		local w = vim.fn.strdisplaywidth(line)
		if w > width then
			width = w
		end
	end

	-- 3) Mark the cursor start position in buffer (mark 'Z')
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	-- buf_set_mark: (bufnr, name, line, col, opts), col is 0‑indexed
	vim.api.nvim_buf_set_mark(0, "Z", row, col, {})

	-- 4) Enter Visual‑Block, stretch to our computed size, and paste (synchronously)
	local vblock = vim.api.nvim_replace_termcodes("<C-v>", true, false, true)
	vim.api.nvim_feedkeys(vblock, "n", false)
	local right = (width > 1) and string.rep("l", width - 1) or ""
	local down = (height > 1) and string.rep("j", height - 1) or ""
	vim.api.nvim_feedkeys(right .. down, "n", false)
	-- 'x' mode: execute paste before moving on
	vim.api.nvim_feedkeys("p", "x", false)

	-- 5) Cleanup trailing whitespace in the whole buffer
	--    (use :% so you don’t need any delay or guessing)
	vim.cmd([[%s/\s\+$//e]])

	-- 6) Go back to our mark, re‑select the same block, and yank it back
	local mpos = vim.api.nvim_buf_get_mark(0, "Z")
	vim.api.nvim_win_set_cursor(0, { mpos[1], mpos[2] })
	vim.api.nvim_feedkeys(vblock, "n", false)
	vim.api.nvim_feedkeys(right .. down, "n", false)
	vim.api.nvim_feedkeys("y", "x", false)
end, { desc = "Smart block‑paste + cleanup + restore register" })

--
-- Transparent block‑paste: non‑space chars only overwrite
--
vim.keymap.set("n", "<leader>bp", function()
	-- 1) pull the default register into Lua
	local reg = vim.fn.getreg('"', 1, true)
	if type(reg) ~= "table" or vim.tbl_isempty(reg) then
		print("Nothing in register to paste")
		return
	end

	-- 2) compute block size
	local height = #reg
	local width = 0
	for _, line in ipairs(reg) do
		if #line > width then
			width = #line
		end
	end

	-- 3) get cursor row, col (1‑indexed row; 0‑indexed col)
	local row, col0 = unpack(vim.api.nvim_win_get_cursor(0))
	local start_row = row - 1
	local start_col = col0

	-- 4) for each line of the block:
	for i = 1, height do
		local src = reg[i]
		-- pad src to full width
		if #src < width then
			src = src .. string.rep(" ", width - #src)
		end

		-- grab exactly that line from buffer
		local buf_line = vim.api.nvim_buf_get_lines(0, start_row + i - 1, start_row + i, false)[1]
		-- ensure buffer line is long enough
		if #buf_line < start_col + width then
			buf_line = buf_line .. string.rep(" ", start_col + width - #buf_line)
		end

		-- build the new line by selectively overwriting
		local new_line = {}
		-- prefix (before block)
		new_line[1] = buf_line:sub(1, start_col)
		-- the block region
		local middle = {}
		for j = 1, width do
			local c = src:sub(j, j)
			if c ~= " " then
				middle[j] = c
			else
				middle[j] = buf_line:sub(start_col + j, start_col + j)
			end
		end
		new_line[2] = table.concat(middle)
		-- suffix (after block)
		new_line[3] = buf_line:sub(start_col + width + 1)

		-- write it back
		vim.api.nvim_buf_set_lines(
			0,
			start_row + i - 1,
			start_row + i,
			false,
			{ new_line[1] .. new_line[2] .. new_line[3] }
		)
	end

	-- 5) re‑store the register so we don’t clobber your yanked block
	--    (note: getreg/setreg expect a string or a table of lines)
	vim.fn.setreg('"', reg, "c")
end, { desc = "Transparent block‑paste (skip spaces)" })





-- block_delete.lua

-- 1) Define the function
function block_delete()
  local buf = vim.api.nvim_get_current_buf()

  -- get the two corners of the visual selection
  local start_mark = vim.api.nvim_buf_get_mark(buf, '<')
  local end_mark   = vim.api.nvim_buf_get_mark(buf, '>')

  -- convert to 0‑indexed row/col
  local sl, sc = start_mark[1] - 1, start_mark[2] - 1
  local el, ec = end_mark[1]   - 1, end_mark[2]   - 1

  -- normalize (in case of reverse selection)
  if sl > el then sl, el = el, sl end
  if sc > ec then sc, ec = ec, sc end

  -- replace each line’s slice [sc..ec] with spaces
  for row = sl, el do
    local line = vim.api.nvim_buf_get_lines(buf, row, row+1, false)[1]
    local width = ec - sc + 1
    local spaces = string.rep(' ', width)
    local new_line = line:sub(1, sc+1) .. spaces .. line:sub(ec + 3)
    vim.api.nvim_buf_set_lines(buf, row, row+1, false, { new_line })
  end
end

-- 2) Map it in Visual mode, but first exit Visual (`<Esc>`), then run
vim.keymap.set(
  'x',                   -- visual‑mode
  '<leader>bd',          -- trigger
  '<Esc><Cmd>lua block_delete()<CR>',  -- exit visual, then Lua
  { desc = "Block‑delete (replace block with spaces)" }
)



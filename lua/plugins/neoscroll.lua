return {
	"karb94/neoscroll.nvim",
	config = function()
		require("neoscroll").setup({
			hide_cursor = true, -- Hide cursor while scrolling
			stop_eof = true, -- Stop at <EOF> when scrolling downwards
			respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
			cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
			easing = "linear", -- Default easing function
			pre_hook = nil, -- Function to run before the scrolling animation starts
			post_hook = nil, -- Function to run after the scrolling animation ends
			performance_mode = false, -- Disable "Performance Mode" on all buffers.
		})
		vim.api.nvim_set_keymap(
			"n",
			"<C-u>",
			[[<Cmd>lua require('neoscroll').scroll(-vim.wo.scroll, true, 150)<CR>]],
			{ noremap = true, silent = true }
		)
		vim.api.nvim_set_keymap(
			"n",
			"<C-d>",
			[[<Cmd>lua require('neoscroll').scroll(vim.wo.scroll, true, 150)<CR>]],
			{ noremap = true, silent = true }
		)
	end,
}

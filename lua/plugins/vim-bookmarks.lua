return {
	"MattesGroeger/vim-bookmarks",
	init = function()
		-- save bookmarks separately per working directory
		vim.g.bookmark_save_per_working_dir = 1
		-- vim.g.bookmark_auto_save = 0
		vim.g.bookmark_manage_per_buffer = 1
		vim.g.bookmark_auto_close = 1
		vim.g.bookmark_show_toggle_warning = 0
		vim.g.bookmark_display_annotation = 1
		-- (optional) disable built-in keymaps if you want to define your own
		-- vim.g.bookmark_no_default_key_mappings = 1
	end,
}

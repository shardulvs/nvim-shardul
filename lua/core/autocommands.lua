vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd("User", {
    pattern = "TelescopePreviewerLoaded",
    callback = function()
        vim.opt_local.number = true

        local status_ok, entry = pcall(require("telescope.actions.state").get_selected_entry)
        if not status_ok or not entry then return end

        local filename = entry.filename or entry.value
        if filename and filename ~= "" then
            vim.opt_local.winbar = " " .. vim.fn.fnamemodify(filename, ":t") -- Show at the top
            -- vim.opt_local.statusline = " " .. vim.fn.fnamemodify(filename, ":t") -- Uncomment for bottom
        end
    end,
})


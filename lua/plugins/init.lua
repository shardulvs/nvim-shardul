local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

--  To check the current status of your plugins, run :Lazy
--  To update plugins you can run :Lazy update
require("lazy").setup({
	"norcalli/nvim-colorizer.lua",
	"tpope/vim-sleuth",
	require("plugins.carbon-now"),
	require("plugins.kommentary"),
	"ThePrimeagen/vim-be-good",
	require("plugins.neoscroll"),
	require("plugins.gitsigns"),
	require("plugins.which-key"),
	require("plugins.telescope"),
	require("plugins.lsp.lazydev"),
	require("plugins.lsp.luvit-meta"),
	require("plugins.lsp.typescript-tools"),
	require("plugins.lsp.nvim-lspconfig"),
	require("plugins.conform"),
	require("plugins.nvim-cmp"),
	require("plugins.catppuccin"),
	require("plugins.kanagawa"),
	require("plugins.todo-comments"),
	require("plugins.mini"),
	require("plugins.nvim-treesitter"),
	-- require 'kickstart.plugins.debug',
	require("kickstart.plugins.indent_line"),
	-- require 'kickstart.plugins.lint',
	require("kickstart.plugins.autopairs"),
	-- require 'kickstart.plugins.neo-tree',
	-- require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps
	{
		"andymass/vim-matchup",
		lazy = false, -- Load immediately
		config = function()
			vim.g.matchup_matchparen_offscreen = { method = "popup" } -- Show offscreen matches in a popup
		end,
	},
	-- require("plugins.dev")
	require("plugins.harpoon"),
	require("plugins.vim-bookmarks"),
	'jbyuki/venn.nvim'
}, {
	ui = {
		-- If you are using a Nerd Font: set icons to an empty table which will use the
		-- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})

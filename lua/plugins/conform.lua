return { -- Autoformat
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true, lsp_format = "never" })
			end,
			mode = "",
			desc = "[F]ormat buffer",
		},
	},
	opts = {
		notify_on_error = false,
		-- i have disabled format_on_save for now
		--[[ format_on_save = function(bufnr)
			local disable_filetypes = {
				c = false,
				cpp = false,
			}
			local lsp_format_opt
			if disable_filetypes[vim.bo[bufnr].filetype] then
				lsp_format_opt = "never"
			else
				lsp_format_opt = "fallback"
			end
			return {
				timeout_ms = 500,
				lsp_format = lsp_format_opt,
			}
		end, ]]
		formatters = {
			["loclang-format"] = {
				command = "/opt/lo/bin/clang-format",
				args = { "-assume-filename", "$FILENAME" },
				range_args = function(self, ctx)
					local start_offset, end_offset = require("conform.util").get_offsets_from_range(ctx.buf, ctx.range)
					local length = end_offset - start_offset
					return {
						"-assume-filename",
						"$FILENAME",
						"--offset",
						tostring(start_offset),
						"--length",
						tostring(length),
					}
				end,
			},
		},
		formatters_by_ft = {
			lua = { "stylua" },
			cpp = { "loclang-format" },
			java = { "clang-format" }, -- Conform can also run multiple formatters sequentially
			python = { "isort", "black" }, -- You can use 'stop_after_first' to run the first available formatter from the list
			html = { "htmlbeautifier" },
			markdown = { "markdownlint", "cbfmt" },
			javascript = {"prettier"},
			json = {"fixjson"}
		},
	},
}

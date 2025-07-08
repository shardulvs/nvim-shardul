return {
    "ThePrimeagen/harpoon",
    dependencies = {
        "nvim-lua/plenary.nvim", -- required by Harpoon :contentReference[oaicite:6]{index=6}
    },
    config = function()
    require("harpoon").setup({
        -- you can override any of the global settings here, e.g.:
        -- save_on_toggle = true,
        -- tabline = true,
        menu = {
            width = vim.api.nvim_win_get_width(0) - 4,
        },
    }) -- initialize Harpoon :contentReference[oaicite:7]{index=7}

    local mark = require("harpoon.mark")
    local ui = require("harpoon.ui")
    -- local term = require("harpoon.term")
    -- local send = require("harpoon.term").sendCommand

    -- Add file to Harpoon list
    vim.keymap.set("n", "<leader>a", mark.add_file, { desc = "[H]arpoon [A]dd File" })

    -- Toggle the quick menu (files & terminals)
    vim.keymap.set("n", "<leader>u", ui.toggle_quick_menu, { desc = "[H]arpoon [U]I Toggle" })

        --[[ -- Jump to file marks 1–4 (add more if you like)
		vim.keymap.set("n", "<leader>1", function()
			ui.nav_file(1)
		end, { desc = "Nav to Harpoon File 1" })
		vim.keymap.set("n", "<leader>2", function()
			ui.nav_file(2)
		end, { desc = "Nav to Harpoon File 2" })

		-- Cycle through marks
		vim.keymap.set("n", "<leader>]", ui.nav_next, { desc = "Harpoon Next File" })
		vim.keymap.set("n", "<leader>[", ui.nav_prev, { desc = "Harpoon Previous File" })

		-- Terminal navigation: go to terminal 1 and 2
		vim.keymap.set("n", "<leader>t1", function()
			term.gotoTerminal(1)
		end, { desc = "Harpoon Terminal 1" })
		vim.keymap.set("n", "<leader>t2", function()
			term.gotoTerminal(2)
		end, { desc = "Harpoon Terminal 2" })

		-- (Optional) Send preconfigured command 1 to terminal 1
		vim.keymap.set("n", "<leader>c1", function()
			send(1, 1)
		end, { desc = "Send Cmd 1 → Term 1" }) ]]
    end,
}

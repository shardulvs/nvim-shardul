return {
  'kevinhwang91/nvim-ufo',
  dependencies = {
    'kevinhwang91/promise-async',
  },
  event = 'BufReadPost', -- load when a file is opened
  config = function()
    -- Core folding options
    vim.o.foldcolumn = '0'       -- shows fold signs
    vim.o.foldlevel = 99         -- keep folds open by default
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    -- UFO setup: Tree-sitter first, indent as fallback
    require('ufo').setup({
      provider_selector = function(_, _, _)
        return { 'lsp', 'indent' }
      end,
    })

    -- Keymaps recommended by ufo
    vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = 'Open all folds' })
    vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = 'Close all folds' })
  end,
}

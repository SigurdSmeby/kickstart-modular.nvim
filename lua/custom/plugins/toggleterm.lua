return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      require('toggleterm').setup {
        size = 20,
        open_mapping = [[<C-\>]],
        hide_numbers = true,
        shade_terminals = true,
        start_in_insert = true,
        direction = 'horizontal', -- 'float', 'horizontal', 'vertical', 'tab'
        close_on_exit = true,
        float_opts = {
          border = 'curved',
          winblend = 0,
        },
      }

      -- Terminal keymappings
      function _G.set_terminal_keymaps()
        local opts = { buffer = 0 }
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
      end

      vim.cmd 'autocmd! TermOpen term://* lua set_terminal_keymaps()'
      -- Create keybindings for specific terminals
      vim.keymap.set('n', '<leader>t1', '<cmd>1ToggleTerm<cr>', { desc = 'Toggle terminal 1' })
      vim.keymap.set('n', '<leader>t2', '<cmd>2ToggleTerm<cr>', { desc = 'Toggle terminal 2' })
      vim.keymap.set('n', '<leader>t3', '<cmd>3ToggleTerm<cr>', { desc = 'Toggle terminal 3' })
      vim.keymap.set('n', '<leader>t4', '<cmd>4ToggleTerm<cr>', { desc = 'Toggle terminal 4' })
    end,
  },
}

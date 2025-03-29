return {
  -- lazy.nvim
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {},
    dependencies = {
      'MunifTanjim/nui.nvim',
      -- Include nvim-notify if you want to use the notification view
      'rcarriga/nvim-notify',
    },
    config = function(_, opts)
      -- Configure nvim-notify first
      require('noice').setup(opts)
      -- Add keybinding to show message history
      vim.keymap.set('n', '<leader>nh', function()
        require('noice').cmd 'history'
      end, { desc = 'Noice history' })
      -- Add keybinding to dismiss all messages
      vim.keymap.set('n', '<leader>nd', function()
        require('noice').cmd 'dismiss'
      end, { desc = 'Dismiss all notifications' })
    end,
  },
}

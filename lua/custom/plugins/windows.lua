return {
  {
    'anuvyklack/windows.nvim',
    dependencies = {
      'anuvyklack/middleclass',
      'anuvyklack/animation.nvim',
    },
    config = function()
      -- Set required Neovim options
      vim.o.winwidth = 10
      vim.o.winminwidth = 10
      vim.o.equalalways = false

      -- Setup windows.nvim
      require('windows').setup {
        animation = {
          duration = 50,
        },
        autowidth = {
          enable = true,
          winwidth = 25,
        },
        ignore = {
          buftype = { 'nofile', 'prompt', 'popup' },
          filetype = { 'NvimTree', 'neo-tree', 'dashboard', 'Outline', 'aerial' },
        },
        restore_on_setup = true,
      }

      -- Set keymaps
      vim.keymap.set('n', '<C-w>z', '<Cmd>WindowsMaximize<CR>')
      vim.keymap.set('n', '<C-w>_', '<Cmd>WindowsMaximizeVertically<CR>')
      vim.keymap.set('n', '<C-w>|', '<Cmd>WindowsMaximizeHorizontally<CR>')
      vim.keymap.set('n', '<C-w>=', '<Cmd>WindowsEqualize<CR>')
      vim.keymap.set('n', '<C-w>a', '<Cmd>WindowsToggleAutowidth<CR>')
    end,
  },
}

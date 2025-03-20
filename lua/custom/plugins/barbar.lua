return {
  {
    'romgrk/barbar.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons', -- For file icons
      'nvim-neo-tree/neo-tree.nvim', -- Add neo-tree as dependency
    },
    init = function()
      vim.g.barbar_auto_setup = false
    end,
    opts = {
      animation = true,
      clickable = true,
      icons = {
        buffer_index = true,
        buffer_number = false,
        button = '×', -- This adds the close button (x symbol)
        filetype = {
          enabled = true,
        },
        separator = { left = '▎', right = '' },
        separator_at_end = true,
        modified = { button = '●' },
        pinned = { button = '', filename = true },
        inactive = { button = '' }, -- Also add × for inactive buffers
      },
      -- This is where we fix the neo-tree integration
      sidebar_filetypes = {
        NeoTree = true,
        ['neo-tree'] = { event = 'BufWipeout' },
      },
    },
    version = '^1.0.0',
  },
}

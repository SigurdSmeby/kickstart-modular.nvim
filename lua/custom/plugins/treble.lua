return {
  'ryanoneill/treble.nvim',
  dependencies = {
    {
      'akinsho/bufferline.nvim',
      version = '*',
      dependencies = 'nvim-tree/nvim-web-devicons',
    },
    {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.1',
      dependencies = 'nvim-lua/plenary.nvim',
    },
  },
}

return {
  -- Add colorizer.lua for color highlighting
  {
    'norcalli/nvim-colorizer.lua',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('colorizer').setup {
        '*', -- Highlight all files
        css = { css = true }, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        html = { names = false }, -- Disable names like Blue in HTML
      }
    end,
  },
}

return {
  {
    'github/copilot.vim',
    event = 'InsertEnter',
    lazy = false,
    config = function()
      -- Enable Copilot for all filetypes
      vim.g.copilot_enabled = true

      -- Disable the default tab mapping
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      vim.g.copilot_tab_fallback = ''

      -- Key mappings using more standard Vim conventions
      vim.api.nvim_set_keymap('i', '<C-y>', 'copilot#Accept("<CR>")', { silent = true, expr = true })
      vim.api.nvim_set_keymap('i', '<C-n>', 'copilot#Next()', { silent = true, expr = true })
      vim.api.nvim_set_keymap('i', '<C-p>', 'copilot#Previous()', { silent = true, expr = true })

      -- Optional: you can disable Copilot for specific filetypes
      vim.g.copilot_filetypes = {
        ['*'] = true,
        ['markdown'] = true,
        ['text'] = true,
        -- Add any filetypes you want to disable Copilot for
        -- ["lua"] = false,
      }
    end,
  },
}

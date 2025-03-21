return {
  {
    'github/copilot.vim',
    event = 'InsertEnter',
    lazy = false,
    config = function()
      -- Enable Copilot for all filetypes
      vim.g.copilot_enabled = true

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

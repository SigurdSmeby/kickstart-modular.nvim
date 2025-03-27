return {
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>s',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[S]tyle buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        local lsp_format_opt
        if disable_filetypes[vim.bo[bufnr].filetype] then
          lsp_format_opt = 'never'
        else
          lsp_format_opt = 'fallback'
        end
        return {
          timeout_ms = 500,
          lsp_format = lsp_format_opt,
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        -- Try prettier first, then prettierd (reversed order from original)
        javascript = { 'prettier', 'prettierd', stop_after_first = true },
        typescript = { 'prettier', 'prettierd', stop_after_first = true },
        javascriptreact = { 'prettier', 'prettierd', stop_after_first = true },
        typescriptreact = { 'prettier', 'prettierd', stop_after_first = true },
        css = { 'prettier', 'prettierd', stop_after_first = true },
        html = { 'prettier', 'prettierd', stop_after_first = true },
        json = { 'prettier', 'prettierd', stop_after_first = true },
        yaml = { 'prettier', 'prettierd', stop_after_first = true },
        markdown = { 'prettier', 'prettierd', stop_after_first = true },
      },
      -- Formatter configurations with explicit config path
      formatters = {
        prettier = {
          -- Explicitly point to your .prettierrc.json in home directory
          prepend_args = { '--config', vim.fn.expand '~/.prettierrc.json' },
        },
        prettierd = {
          -- Same configuration for prettierd
          prepend_args = { '--config', vim.fn.expand '~/.prettierrc.json' },
        },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et

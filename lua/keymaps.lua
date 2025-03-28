-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`
--
-- Quick exit insertmode with "jj".
vim.keymap.set('i', 'jj', '<Esc>', { desc = 'Exit insert mode with jj' })

-- create a console.log() mapping for javascript and typescript files
local console_group = vim.api.nvim_create_augroup('ConsoleCommands', { clear = true })

-- Create global mappings that show error messages when used in non-JS/TS files
vim.keymap.set('n', '<leader>cl', function()
  vim.notify('Not a JavaScript/TypeScript file', vim.log.levels.WARN)
end, { noremap = true })

vim.keymap.set('n', '<leader>ci', function()
  vim.notify('Not a JavaScript/TypeScript file', vim.log.levels.WARN)
end, { noremap = true })

vim.keymap.set('n', '<leader>ce', function()
  vim.notify('Not a JavaScript/TypeScript file', vim.log.levels.WARN)
end, { noremap = true })

vim.keymap.set('n', '<leader>cw', function()
  vim.notify('Not a JavaScript/TypeScript file', vim.log.levels.WARN)
end, { noremap = true })

-- Set up the functional mappings only for JS/TS files (these will override the error mappings)
vim.api.nvim_create_autocmd('FileType', {
  group = console_group,
  pattern = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
  callback = function()
    vim.keymap.set('n', '<leader>cl', '"lyiwo<ESC>iconsole.log(\'<ESC>"lpa :\', <ESC>"lpa);<ESC>', { buffer = true, noremap = true })
    vim.keymap.set('n', '<leader>ci', '"lyiwo<ESC>iconsole.info(\'<ESC>"lpa :\', <ESC>"lpa);<ESC>', { buffer = true, noremap = true })
    vim.keymap.set('n', '<leader>ce', '"lyiwo<ESC>iconsole.error(\'<ESC>"lpa :\', <ESC>"lpa);<ESC>', { buffer = true, noremap = true })
    vim.keymap.set('n', '<leader>cw', '"lyiwo<ESC>iconsole.warn(\'<ESC>"lpa :\', <ESC>"lpa);<ESC>', { buffer = true, noremap = true })
  end,
})

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- vim: ts=2 sts=2 sw=2 et

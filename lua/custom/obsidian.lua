-- obsidian.lua - Add Obsidian-like functionality to Neovim
-- Place this in ~/.config/nvim/lua/obsidian.lua

--[[ 
=====================================================================
CONFIGURATION SECTION - Edit these values to customize
=====================================================================
--]]

-- Create the module
local M = {}

-- Default configuration (edit these values to customize)
M.DEFAULT_CONFIG = {
  -- Paths (use double backslashes for Windows)
  vault_dir = 'C:\\Users\\Sigurd\\Documents\\Obsidian-Vault',
  template_dir = 'C:\\Users\\Sigurd\\Documents\\Obsidian-Vault\\009 Templates',
  default_note_dir = 'C:\\Users\\Sigurd\\Documents\\Obsidian-Vault\\001 Inbox',

  -- Template settings
  default_template = 'Nytt notat Template.md',

  -- Appearance settings
  link_existing_color = '#a3be8c', -- Green for existing links
  link_broken_color = '#bf616a', -- Red for broken links
  link_text_style = 'underline', -- Style for link text
  bold_color = '#f0c674', -- Gold/yellow for bold text
  bold_style = 'bold', -- Style for bold text
  italic_color = '#e98bb1', -- Pink for italic text
  italic_style = 'italic', -- Style for italic text

  -- Behavior settings
  throttle_ms = 300, -- Throttle time for highlighting updates (ms)
  auto_update_highlight = true, -- Whether to auto-update highlighting
  debug = false, -- Enable debug logging

  -- Key mappings (Leader prefix)
  prefix = 'o', -- Will be used as <Leader>{prefix}{key}
  mappings = {
    new_note = 'n', -- Create new note <Leader>on
    template = 't', -- Create with template <Leader>ot
    insert_link = 'l', -- Insert link <Leader>ol
    follow_link = 'f', -- Follow link <Leader>of
    update_highlight = 'u', -- Update highlighting <Leader>ou
  },
}

-- Initialize config with default values (will be overridden by user config in setup)
M.config = vim.deepcopy(M.DEFAULT_CONFIG)

--[[ 
=====================================================================
CORE FUNCTIONALITY
=====================================================================
--]]

-- Create a new note
function M.new_note()
  local filename = vim.fn.input 'New note name: '
  if filename == '' then
    return
  end

  -- Ensure filename has .md extension
  if not filename:match '%.md$' then
    filename = filename .. '.md'
  end

  local full_path = M.config.default_note_dir .. '\\' .. filename

  -- Check if file already exists
  if vim.fn.filereadable(full_path) == 1 then
    print('File already exists: ' .. full_path)
    return
  end

  -- Apply template
  M.apply_template(full_path, M.config.default_template)

  -- Open the new file
  vim.cmd('edit ' .. vim.fn.fnameescape(full_path))
end

-- Apply a specific template
function M.apply_template_interactive()
  local templates = M.get_available_templates()

  -- Ask user which template to use
  print 'Available templates:'
  for i, template in ipairs(templates) do
    print(i .. ': ' .. template)
  end

  local choice = tonumber(vim.fn.input 'Choose template (number): ')
  if not choice or choice < 1 or choice > #templates then
    print 'Invalid choice'
    return
  end

  local filename = vim.fn.input 'New note name: '
  if filename == '' then
    return
  end

  -- Ensure filename has .md extension
  if not filename:match '%.md$' then
    filename = filename .. '.md'
  end

  local full_path = M.config.default_note_dir .. '\\' .. filename

  -- Apply the selected template
  M.apply_template(full_path, templates[choice])

  -- Open the new file
  vim.cmd('edit ' .. vim.fn.fnameescape(full_path))
end

-- Apply a template to a file
function M.apply_template(file_path, template_name)
  -- Ensure template has .md extension
  if not template_name:match '%.md$' then
    template_name = template_name .. '.md'
  end

  local template_path = M.config.template_dir .. '\\' .. template_name

  -- Check if template exists
  if vim.fn.filereadable(template_path) == 0 then
    print('Template not found: ' .. template_path)
    return
  end

  -- Read template content
  local template_content = table.concat(vim.fn.readfile(template_path), '\n')

  -- Replace variables in the template
  local filename_without_ext = vim.fn.fnamemodify(file_path, ':t:r')
  local current_date = os.date '%Y-%m-%d'
  local current_time = os.date '%H:%M'

  template_content = template_content:gsub('{{title}}', filename_without_ext)
  template_content = template_content:gsub('{{date}}', current_date)
  template_content = template_content:gsub('{{time}}', current_time)

  -- Create directories if they don't exist
  local dir = vim.fn.fnamemodify(file_path, ':h')
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, 'p')
  end

  -- Write content to file
  local file = io.open(file_path, 'w')
  if file then
    file:write(template_content)
    file:close()
    print('Created new note: ' .. file_path)
  else
    print('Failed to create file: ' .. file_path)
  end
end

-- Get list of available templates
function M.get_available_templates()
  local templates = {}
  -- Use double backslash for Windows paths in glob pattern
  local pattern = M.config.template_dir:gsub('\\', '\\\\') .. '\\\\*.md'
  local files = vim.fn.glob(pattern, false, true)

  for _, file in ipairs(files) do
    table.insert(templates, vim.fn.fnamemodify(file, ':t'))
  end

  return templates
end

-- Find and insert a link to another note
function M.insert_link()
  -- Save current window and position
  local current_win = vim.fn.win_getid()
  local current_pos = vim.fn.getcurpos()

  -- Get list of markdown files in vault
  -- Use double backslash for Windows paths in glob pattern
  local pattern = M.config.vault_dir:gsub('\\', '\\\\') .. '\\\\**\\\\*.md'
  local files = vim.fn.glob(pattern, false, true)
  local file_names = {}

  for _, file in ipairs(files) do
    local name = vim.fn.fnamemodify(file, ':t:r')
    table.insert(file_names, name)
  end

  -- Create temporary buffer with file names
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, file_names)

  -- Open floating window
  local width = 60
  local height = math.min(#file_names, 15)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = 'rounded',
  })

  -- Set up autocommand to handle selection
  vim.api.nvim_create_autocmd({ 'BufLeave' }, {
    buffer = buf,
    callback = function()
      local selected_line = vim.api.nvim_win_get_cursor(win)[1]
      local selected_file = file_names[selected_line]

      -- Close floating window
      vim.api.nvim_win_close(win, true)

      -- Return to original window and position
      vim.fn.win_gotoid(current_win)
      vim.fn.setpos('.', current_pos)

      -- Insert link
      if selected_file then
        local link = '[[' .. selected_file .. ']]'
        vim.api.nvim_put({ link }, '', false, true)
      end
    end,
    once = true,
  })

  -- Set up keymappings for selection
  vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', {
    callback = function()
      vim.api.nvim_win_close(win, true)
    end,
    noremap = true,
    silent = true,
  })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '', {
    callback = function()
      vim.api.nvim_win_close(win, true)
      vim.fn.win_gotoid(current_win)
    end,
    noremap = true,
    silent = true,
  })
end

-- Improved follow_link function to work with the entire [[link]] construct
function M.follow_link()
  -- Get text under cursor
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- Convert to 1-based indexing for string operations

  -- Find all [[links]] in the current line
  local start_idx = 1
  while true do
    -- Find the next [[...]] pattern
    local link_start, link_end = line:find('%[%[.-%]%]', start_idx)
    if not link_start then
      break
    end

    -- Check if cursor is anywhere in this link (including brackets)
    if col >= link_start and col <= link_end then
      -- Extract the link text (without the brackets)
      local link_text = line:sub(link_start + 2, link_end - 2)

      -- Try to find the file in the vault
      local pattern = M.config.vault_dir:gsub('\\', '\\\\') .. '\\\\**\\\\' .. link_text .. '.md'
      local files = vim.fn.glob(pattern, false, true)

      if #files > 0 then
        -- File exists, edit it
        vim.cmd('edit ' .. vim.fn.fnameescape(files[1]))
        return
      else
        -- File doesn't exist, create it in default location
        local file_path = M.config.default_note_dir .. '\\' .. link_text .. '.md'
        local choice = vim.fn.confirm("File doesn't exist. Create it?", '&Yes\n&No', 1)
        if choice == 1 then
          M.apply_template(file_path, M.config.default_template)
          vim.cmd('edit ' .. vim.fn.fnameescape(file_path))
        end
        return
      end
    end

    -- Move to search for the next link
    start_idx = link_end + 1
  end

  print 'No link found under cursor'
end

--[[ 
=====================================================================
HIGHLIGHTING FUNCTIONS
=====================================================================
--]]

-- Check if a file exists in the vault
function M.file_exists_in_vault(link_text)
  local pattern = M.config.vault_dir:gsub('\\', '\\\\') .. '\\\\**\\\\' .. link_text .. '.md'
  local files = vim.fn.glob(pattern, false, true)
  return #files > 0
end

-- Update syntax highlighting based on existing files
function M.update_link_highlighting()
  -- Skip if not in a markdown buffer
  if vim.bo.filetype ~= 'markdown' then
    return
  end

  -- Use pcall for safer execution and prevent errors from interrupting workflow
  local status, err = pcall(function()
    -- Clear existing matches
    vim.fn.clearmatches()

    -- Add our custom highlighting groups if they don't exist yet
    if vim.fn.hlexists 'ObsidianLinkExists' == 0 then
      vim.cmd('highlight ObsidianLinkExists guifg=' .. M.config.link_existing_color .. ' gui=' .. M.config.link_text_style .. ',bold ctermfg=green')
    end

    if vim.fn.hlexists 'ObsidianLinkBroken' == 0 then
      vim.cmd('highlight ObsidianLinkBroken guifg=' .. M.config.link_broken_color .. ' gui=' .. M.config.link_text_style .. ',italic ctermfg=red')
    end

    -- Get all lines in current buffer
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    -- Process each line
    for line_num, line_content in ipairs(lines) do
      -- Find all wiki link patterns in the current line
      local start_idx = 1
      while true do
        -- Find the next [[...]] pattern
        local link_start, link_end = line_content:find('%[%[.-%]%]', start_idx)
        if not link_start then
          break
        end

        -- Extract the link text (without the brackets)
        local link_text = line_content:sub(link_start + 2, link_end - 2)

        -- Determine if the file exists
        local highlight_group = 'ObsidianLinkBroken'
        if M.file_exists_in_vault(link_text) then
          highlight_group = 'ObsidianLinkExists'
        end

        -- Add the highlight match
        vim.fn.matchaddpos(highlight_group, { { line_num, link_start, link_end - link_start + 1 } })

        -- Move to search for the next link
        start_idx = link_end + 1
      end
    end
  end)

  -- Handle any errors without interrupting the user
  if not status and M.config.debug then
    print('Highlighting error (safe to ignore): ' .. err)
  end
end

-- Create a throttled function to prevent too frequent updates
local throttle_timer = nil
function M.throttled_update_highlighting()
  -- If auto-update is disabled, don't do anything
  if not M.config.auto_update_highlight then
    return
  end

  -- Clear existing timer if any
  if throttle_timer then
    vim.fn.timer_stop(throttle_timer)
  end

  -- Set new timer to call the function after a delay
  throttle_timer = vim.fn.timer_start(M.config.throttle_ms, function()
    M.update_link_highlighting()
    throttle_timer = nil
  end)
end

-- Set up highlighting for markdown formatting (bold, italic)
function M.setup_formatting_highlighting()
  -- Set up highlighting for bold and italic text
  vim.cmd([[
    " Bold text with * or **
    syntax region markdownBold start=/\*\*/ end=/\*\*/
    syntax region markdownBold start=/__/ end=/__/
    
    " Italic text with * or _
    syntax region markdownItalic start=/\*/ end=/\*/
    syntax region markdownItalic start=/_/ end=/_/
    
    " Make sure bold and italic can be nested properly
    syntax region markdownBoldItalic start=/\*\*_/ end=/_\*\*/
    syntax region markdownBoldItalic start=/__\*/ end=/\*__/
    syntax region markdownBoldItalic start=/_\*\*/ end=/\*\*_/
    syntax region markdownBoldItalic start=/\*__/ end=/__\*/
    
    " Make sure our custom highlights override any others
    hi markdownBold guifg=]] .. M.config.bold_color .. [[ gui=]] .. M.config.bold_style .. [[ cterm=bold
    hi markdownItalic guifg=]] .. M.config.italic_color .. [[ gui=]] .. M.config.italic_style .. [[ cterm=italic
    hi markdownBoldItalic guifg=]] .. M.config.bold_color .. [[ gui=]] .. M.config.bold_style .. ',' .. M.config.italic_style .. [[ cterm=bold,italic
  ]])
end

-- Set up the custom syntax highlighting for Markdown files
function M.setup_highlighting()
  -- Define basic colors and styles for links
  vim.cmd [[
    " Basic wiki link pattern matching
    syntax match markdownWikiLink "\[\[.\+\]\]" contains=markdownWikiLinkBrackets,markdownWikiLinkText
    syntax match markdownWikiLinkBrackets "\[\[\|\]\]" contained conceal
    syntax match markdownWikiLinkText "\[\[\zs.\+\ze\]\]" contained
    highlight link markdownWikiLinkText Underlined
  ]]

  -- Define custom highlight groups for links
  vim.cmd('highlight ObsidianLinkExists guifg=' .. M.config.link_existing_color .. ' gui=' .. M.config.link_text_style .. ',bold ctermfg=green')

  vim.cmd('highlight ObsidianLinkBroken guifg=' .. M.config.link_broken_color .. ' gui=' .. M.config.link_text_style .. ',italic ctermfg=red')

  -- Add markdown formatting highlighting
  M.setup_formatting_highlighting()

  -- Update highlighting initially
  M.update_link_highlighting()
end

--[[ 
=====================================================================
SETUP AND INITIALIZATION
=====================================================================
--]]

-- Set up keymappings and everything else
function M.setup(user_config)
  -- Apply user configuration if provided
  if user_config then
    -- Merge configuration (simple shallow merge)
    for k, v in pairs(user_config) do
      M.config[k] = v
    end

    -- If user provided mappings, merge those separately to preserve defaults
    if user_config.mappings then
      for k, v in pairs(user_config.mappings) do
        M.config.mappings[k] = v
      end
    end
  end

  -- Create key mappings using the configured prefix
  local leader_prefix = '<Leader>' .. M.config.prefix

  -- Using vim.keymap.set for callback mappings (newer Neovim API)
  if vim.keymap and vim.keymap.set then
    -- For Neovim 0.7+
    vim.keymap.set('n', leader_prefix .. M.config.mappings.new_note, M.new_note, {
      desc = 'Create new note',
      noremap = true,
      silent = true,
    })

    vim.keymap.set('n', leader_prefix .. M.config.mappings.template, M.apply_template_interactive, {
      desc = 'Create note with template',
      noremap = true,
      silent = true,
    })

    vim.keymap.set('n', leader_prefix .. M.config.mappings.insert_link, M.insert_link, {
      desc = 'Insert note link',
      noremap = true,
      silent = true,
    })

    vim.keymap.set('n', leader_prefix .. M.config.mappings.follow_link, M.follow_link, {
      desc = 'Follow link under cursor',
      noremap = true,
      silent = true,
    })

    vim.keymap.set('n', leader_prefix .. M.config.mappings.update_highlight, M.update_link_highlighting, {
      desc = 'Update link highlighting',
      noremap = true,
      silent = true,
    })
  else
    -- Fallback for older Neovim versions
    vim.api.nvim_set_keymap(
      'n',
      leader_prefix .. M.config.mappings.new_note,
      ':lua require("obsidian").new_note()<CR>',
      { noremap = true, silent = true, desc = 'Create new note' }
    )

    vim.api.nvim_set_keymap(
      'n',
      leader_prefix .. M.config.mappings.template,
      ':lua require("obsidian").apply_template_interactive()<CR>',
      { noremap = true, silent = true, desc = 'Create note with template' }
    )

    vim.api.nvim_set_keymap(
      'n',
      leader_prefix .. M.config.mappings.insert_link,
      ':lua require("obsidian").insert_link()<CR>',
      { noremap = true, silent = true, desc = 'Insert note link' }
    )

    vim.api.nvim_set_keymap(
      'n',
      leader_prefix .. M.config.mappings.follow_link,
      ':lua require("obsidian").follow_link()<CR>',
      { noremap = true, silent = true, desc = 'Follow link under cursor' }
    )

    vim.api.nvim_set_keymap(
      'n',
      leader_prefix .. M.config.mappings.update_highlight,
      ':lua require("obsidian").update_link_highlighting()<CR>',
      { noremap = true, silent = true, desc = 'Update link highlighting' }
    )
  end

  -- Create autocommands for markdown files
  vim.api.nvim_create_augroup('ObsidianMarkdown', { clear = true })

  -- Enable concealing of [[ and ]] in markdown files
  vim.api.nvim_create_autocmd({ 'FileType' }, {
    pattern = 'markdown',
    callback = function()
      vim.opt_local.conceallevel = 2
      vim.opt_local.concealcursor = 'nc'
    end,
    group = 'ObsidianMarkdown',
  })

  -- Add custom syntax highlighting for markdown files
  vim.api.nvim_create_autocmd({ 'FileType' }, {
    pattern = 'markdown',
    callback = function()
      -- Set up our highlighting
      M.setup_highlighting()
    end,
    group = 'ObsidianMarkdown',
  })

  -- Add markdown settings
  vim.api.nvim_create_autocmd({ 'FileType' }, {
    pattern = 'markdown',
    callback = function()
      vim.opt_local.wrap = true
      vim.opt_local.linebreak = true

      -- Add special mapping for clicking on links with the mouse
      vim.api.nvim_buf_set_keymap(0, 'n', '<LeftMouse>', '<LeftMouse>:lua require("obsidian").follow_link()<CR>', { noremap = true, silent = true })
    end,
    group = 'ObsidianMarkdown',
  })

  -- Set up auto-update events if enabled
  if M.config.auto_update_highlight then
    vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost', 'TextChanged', 'TextChangedI', 'BufEnter' }, {
      pattern = '*.md',
      callback = function()
        -- Use throttled version to prevent too frequent updates
        M.throttled_update_highlighting()
      end,
      group = 'ObsidianMarkdown',
    })
  end
end

--[[ 
=====================================================================
USAGE EXAMPLE
=====================================================================
--]]

--[[ 
-- Example configuration in your init.lua:

require('obsidian').setup({
  -- Custom vault location
  vault_dir = 'D:\\My-Notes',
  template_dir = 'D:\\My-Notes\\Templates',
  default_note_dir = 'D:\\My-Notes\\Inbox',
  
  -- Customize colors
  link_existing_color = '#00ff00',  -- Bright green
  link_broken_color = '#ff0000',    -- Bright red
  
  -- Change key mappings
  prefix = 'v',                     -- Change to <Leader>v prefix
  mappings = {
    new_note = 'c',                 -- Create with <Leader>vc
  },
})
--]]

-- Initialize with default settings
M.setup()
return M

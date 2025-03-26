-- Custom Navigation for Variables and HTML Tags
-- Supports TypeScript (.ts), TSX (.tsx), and CSS (.css) files

local M = {}

-- Helper function to get file extension
local function get_file_extension()
  local filename = vim.fn.expand '%:t'
  local extension = vim.fn.fnamemodify(filename, ':e'):lower()
  return extension
end

-- Helper function to check if current file is supported
local function is_supported_filetype()
  local filetype = get_file_extension()
  return filetype == 'ts' or filetype == 'tsx' or filetype == 'css'
end

-- Navigate to variables and tags
local function navigate(type, direction)
  if not is_supported_filetype() then
    vim.notify('Navigation only supported in TypeScript, TSX, and CSS files', vim.log.levels.WARN)
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = get_file_extension()

  -- Current cursor position
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local cursor_row = cursor_pos[1] - 1 -- Convert to 0-based
  local cursor_col = cursor_pos[2]

  -- Get parser and syntax tree
  local parser = vim.treesitter.get_parser(bufnr, filetype == 'css' and 'css' or 'tsx')
  local tree = parser:parse()[1]
  local root = tree:root()

  -- Create a table to store all matching nodes
  local nodes = {}

  -- Function to collect nodes of interest
  local function collect_nodes(node, row, col)
    if not node then
      return
    end

    local node_type = node:type()
    local start_row, start_col, end_row, end_col = node:range()

    -- Debug node types (uncomment to debug)
    -- if node_type == "array_pattern" or node_type:match("destruct") then
    --   vim.notify("Found node type: " .. node_type .. " at row " .. start_row, vim.log.levels.INFO)
    -- end

    -- For variable navigation
    if type == 'variable' then
      if filetype == 'ts' or filetype == 'tsx' then
        if node_type == 'identifier' then
          -- Check parent to see if it's a variable declaration
          local parent = node:parent()
          if
            parent
            and (
              parent:type() == 'variable_declarator'
              or parent:type() == 'function_declaration'
              or parent:type() == 'class_declaration'
              -- Handle array destructuring patterns (for React hooks)
              or parent:type() == 'array_pattern'
              -- Handle object destructuring patterns
              or parent:type() == 'object_pattern'
            )
          then
            table.insert(nodes, {
              node = node,
              row = start_row,
              col = start_col,
            })
          end
        end
      elseif filetype == 'css' then
        if node_type == 'class_name' or node_type == 'id_name' or node_type == 'tag_name' then
          table.insert(nodes, {
            node = node,
            row = start_row,
            col = start_col,
          })
        end
      end
    -- For HTML tag navigation
    elseif type == 'html_tag' and filetype == 'tsx' then
      if node_type == 'identifier' then
        -- Check if parent is a JSX element or component
        local parent = node:parent()
        if parent and (parent:type() == 'jsx_opening_element' or parent:type() == 'jsx_self_closing_element') then
          table.insert(nodes, {
            node = node,
            row = start_row,
            col = start_col,
          })
        end
      end
    -- For logic/loops navigation
    elseif type == 'logic' and (filetype == 'ts' or filetype == 'tsx') then
      -- Control flow statements
      if
        node_type == 'if_statement'
        or node_type == 'else_clause'
        or node_type == 'for_statement'
        or node_type == 'for_in_statement'
        or node_type == 'while_statement'
        or node_type == 'do_statement'
        or node_type == 'switch_statement'
        or node_type == 'try_statement'
        or node_type == 'catch_clause'
        or node_type == 'finally_clause'
      then
        -- Find the keyword position (if, else, for, while, etc.)
        -- For most statements, the keyword is at the start of the node
        table.insert(nodes, {
          node = node,
          row = start_row,
          col = start_col,
        })
      end

      -- Array methods like map, filter, reduce, forEach
      if node_type == 'member_expression' then
        local method_name = nil
        for child in node:iter_children() do
          if child:type() == 'property_identifier' then
            local method = vim.treesitter.get_node_text(child, bufnr)
            if
              method == 'map'
              or method == 'filter'
              or method == 'reduce'
              or method == 'forEach'
              or method == 'find'
              or method == 'some'
              or method == 'every'
            then
              method_name = method
              table.insert(nodes, {
                node = child,
                row = child:range(),
                col = select(2, child:range()),
              })
            end
          end
        end
      end

    -- For function navigation
    elseif type == 'function' and (filetype == 'ts' or filetype == 'tsx') then
      -- Named function declarations
      if node_type == 'function_declaration' then
        for child in node:iter_children() do
          if child:type() == 'identifier' then
            table.insert(nodes, {
              node = child,
              row = child:range(),
              col = select(2, child:range()),
            })
            break
          end
        end
      end

      -- Method definitions in classes
      if node_type == 'method_definition' then
        for child in node:iter_children() do
          if child:type() == 'property_identifier' then
            table.insert(nodes, {
              node = child,
              row = child:range(),
              col = select(2, child:range()),
            })
            break
          end
        end
      end

      -- Arrow functions assigned to variables
      if node_type == 'arrow_function' then
        local parent = node:parent()
        if parent and parent:type() == 'variable_declarator' then
          for child in parent:iter_children() do
            if child:type() == 'identifier' then
              table.insert(nodes, {
                node = child,
                row = child:range(),
                col = select(2, child:range()),
              })
              break
            end
          end
        end
      end

      -- Anonymous functions as arguments
      if node_type == 'arrow_function' or node_type == 'function' then
        -- Just collect the function node itself for anonymous functions
        table.insert(nodes, {
          node = node,
          row = start_row,
          col = start_col,
        })
      end
    end

    -- Recursively process child nodes
    for child, _ in node:iter_children() do
      collect_nodes(child)
    end
  end

  -- Start collecting from the root
  collect_nodes(root)

  -- Sort nodes by position
  table.sort(nodes, function(a, b)
    if a.row == b.row then
      return a.col < b.col
    end
    return a.row < b.row
  end)

  -- Find the next or previous node based on cursor position
  local target_node = nil

  if direction == 'forward' then
    for _, node_data in ipairs(nodes) do
      if node_data.row > cursor_row or (node_data.row == cursor_row and node_data.col > cursor_col) then
        target_node = node_data
        break
      end
    end
    -- Wrap around to beginning if needed
    if not target_node and #nodes > 0 then
      target_node = nodes[1]
    end
  else -- backward
    for i = #nodes, 1, -1 do
      local node_data = nodes[i]
      if node_data.row < cursor_row or (node_data.row == cursor_row and node_data.col < cursor_col) then
        target_node = node_data
        break
      end
    end
    -- Wrap around to end if needed
    if not target_node and #nodes > 0 then
      target_node = nodes[#nodes]
    end
  end

  -- Move to target node
  if target_node then
    vim.api.nvim_win_set_cursor(0, { target_node.row + 1, target_node.col })
  end
end

-- Navigate to variable declarations
function M.goto_variable(forward)
  navigate('variable', forward and 'forward' or 'backward')
end

-- Navigate to HTML tags
function M.goto_html_tag(forward)
  navigate('html_tag', forward and 'forward' or 'backward')
end

-- Navigate to logic/loop constructs
function M.goto_logic(forward)
  navigate('logic', forward and 'forward' or 'backward')
end

-- Navigate to function declarations
function M.goto_function(forward)
  navigate('function', forward and 'forward' or 'backward')
end

-- Set up keymaps
function M.setup()
  -- Variable navigation
  vim.keymap.set('n', '[v', function()
    M.goto_variable(false)
  end, { desc = 'Go to previous variable declaration' })
  vim.keymap.set('n', ']v', function()
    M.goto_variable(true)
  end, { desc = 'Go to next variable declaration' })
  vim.keymap.set('v', '[v', function()
    M.goto_variable(false)
  end, { desc = 'Go to previous variable declaration' })
  vim.keymap.set('v', ']v', function()
    M.goto_variable(true)
  end, { desc = 'Go to next variable declaration' })

  -- HTML tag navigation
  vim.keymap.set('n', '[h', function()
    M.goto_html_tag(false)
  end, { desc = 'Go to previous HTML tag' })
  vim.keymap.set('n', ']h', function()
    M.goto_html_tag(true)
  end, { desc = 'Go to next HTML tag' })
  vim.keymap.set('v', '[h', function()
    M.goto_html_tag(false)
  end, { desc = 'Go to previous HTML tag' })
  vim.keymap.set('v', ']h', function()
    M.goto_html_tag(true)
  end, { desc = 'Go to next HTML tag' })

  -- Logic/loops navigation
  vim.keymap.set('n', '[l', function()
    M.goto_logic(false)
  end, { desc = 'Go to previous logic/loop statement' })
  vim.keymap.set('n', ']l', function()
    M.goto_logic(true)
  end, { desc = 'Go to next logic/loop statement' })
  vim.keymap.set('v', '[l', function()
    M.goto_logic(false)
  end, { desc = 'Go to previous logic/loop statement' })
  vim.keymap.set('v', ']l', function()
    M.goto_logic(true)
  end, { desc = 'Go to next logic/loop statement' })

  -- Function navigation
  vim.keymap.set('n', '[f', function()
    M.goto_function(false)
  end, { desc = 'Go to previous function declaration' })
  vim.keymap.set('n', ']f', function()
    M.goto_function(true)
  end, { desc = 'Go to next function declaration' })
  vim.keymap.set('v', '[f', function()
    M.goto_function(false)
  end, { desc = 'Go to previous function declaration' })
  vim.keymap.set('v', ']f', function()
    M.goto_function(true)
  end, { desc = 'Go to next function declaration' })
end

return M

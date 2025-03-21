return {
  {
    'romgrk/barbar.nvim',
    dependencies = {
      'lewis6991/gitsigns.nvim', -- For git status integration
      'nvim-tree/nvim-web-devicons', -- For file icons
      'nvim-neo-tree/neo-tree.nvim', -- Neo-tree integration
    },
    init = function()
      vim.g.barbar_auto_setup = false
    end,
    opts = {
      -- Animation for changing buffers
      animation = true,

      -- Auto-hide tabline when only one buffer
      auto_hide = false,

      -- Enable tabpages indicator (top right)
      tabpages = true,

      -- Enable clickable tabs
      clickable = true,

      -- Focus behavior when closing buffers
      focus_on_close = 'left',

      -- Hide inactive buffers and file extensions
      hide = { extensions = true, inactive = false },

      -- Highlighting options
      highlight_visible = true,
      highlight_alternate = false,

      icons = {
        -- Buffer indicators
        buffer_index = true,
        buffer_number = false,

        -- Close button
        button = '×',

        -- Diagnostic icons
        diagnostics = {
          [vim.diagnostic.severity.ERROR] = { enabled = true, icon = 'ﬀ' },
          [vim.diagnostic.severity.WARN] = { enabled = false },
          [vim.diagnostic.severity.INFO] = { enabled = false },
          [vim.diagnostic.severity.HINT] = { enabled = true },
        },

        -- Git status icons
        gitsigns = {
          added = { enabled = true, icon = '+' },
          changed = { enabled = true, icon = '~' },
          deleted = { enabled = true, icon = '-' },
        },

        -- File type icons
        filetype = {
          custom_colors = false,
          enabled = true,
        },

        -- Separators between buffers
        separator = { left = '▎', right = '' },
        separator_at_end = true,

        -- Status indicators
        modified = { button = '●' },
        pinned = { button = '', filename = true },

        -- Inactive buffer appearance
        inactive = { button = '×' },
      },

      -- Buffer insertion behavior
      insert_at_end = false,
      insert_at_start = false,

      -- Padding settings
      maximum_padding = 1,
      minimum_padding = 1,

      -- Buffer name length
      maximum_length = 30,

      -- Buffer pick mode letter assignment
      semantic_letters = true,

      -- Sidebar integration
      sidebar_filetypes = {
        -- Standard NvimTree
        NvimTree = true,

        -- Neo-tree with proper events
        NeoTree = { event = 'BufWinLeave', text = '' },
        ['neo-tree'] = { event = 'BufWipeout' },

        -- Add other sidebars as needed
        Outline = { event = 'BufWinLeave', text = 'Symbols', align = 'right' },
      },

      -- Letter order for buffer-pick mode
      letters = 'asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERUTYQP',

      -- Sorting options
      sort = {
        ignore_case = true,
      },
    },
    config = function(_, opts)
      -- Setup barbar with the provided options
      require('barbar').setup(opts)

      -- Setup keymappings
      local map = vim.keymap.set
      local kopts = { noremap = true, silent = true }

      -- Move between buffers
      map('n', '<A-,>', '<Cmd>BufferPrevious<CR>', kopts)
      map('n', '<A-.>', '<Cmd>BufferNext<CR>', kopts)

      -- Reorder buffers
      map('n', '<A-<>', '<Cmd>BufferMovePrevious<CR>', kopts)
      map('n', '<A->>', '<Cmd>BufferMoveNext<CR>', kopts)

      -- Go to specific buffer
      map('n', '<A-1>', '<Cmd>BufferGoto 1<CR>', kopts)
      map('n', '<A-2>', '<Cmd>BufferGoto 2<CR>', kopts)
      map('n', '<A-3>', '<Cmd>BufferGoto 3<CR>', kopts)
      map('n', '<A-4>', '<Cmd>BufferGoto 4<CR>', kopts)
      map('n', '<A-5>', '<Cmd>BufferGoto 5<CR>', kopts)
      map('n', '<A-6>', '<Cmd>BufferGoto 6<CR>', kopts)
      map('n', '<A-7>', '<Cmd>BufferGoto 7<CR>', kopts)
      map('n', '<A-8>', '<Cmd>BufferGoto 8<CR>', kopts)
      map('n', '<A-9>', '<Cmd>BufferGoto 9<CR>', kopts)
      map('n', '<A-0>', '<Cmd>BufferLast<CR>', kopts)

      -- Pin/unpin buffer
      map('n', '<A-p>', '<Cmd>BufferPin<CR>', kopts)

      -- Close buffer
      map('n', '<A-c>', '<Cmd>BufferClose<CR>', kopts)

      -- Restore buffer (after closing)
      map('n', '<A-s-c>', '<Cmd>BufferRestore<CR>', kopts)

      -- Magic buffer-picking mode
      map('n', '<C-p>', '<Cmd>BufferPick<CR>', kopts)
      map('n', '<C-s-p>', '<Cmd>BufferPickDelete<CR>', kopts)

      -- Sort buffers
      -- map('n', '<leader>bb', '<Cmd>BufferOrderByBufferNumber<CR>', kopts)
      -- map('n', '<leader>bd', '<Cmd>BufferOrderByDirectory<CR>', kopts)
      -- map('n', '<leader>bl', '<Cmd>BufferOrderByLanguage<CR>', kopts)
      -- map('n', '<leader>bn', '<Cmd>BufferOrderByName<CR>', kopts)
      -- map('n', '<leader>bw', '<Cmd>BufferOrderByWindowNumber<CR>', kopts)

      -- Session support
      vim.opt.sessionoptions:append 'globals'

      -- Create an autocmd that will be triggered before saving a session
      vim.api.nvim_create_autocmd('User', {
        pattern = 'SessionSavePre',
        callback = function()
          -- This will be triggered by session managers that properly integrate with barbar
          -- (like persistence.nvim when configured correctly)
        end,
      })
    end,
    version = '^1.0.0',
  },
}

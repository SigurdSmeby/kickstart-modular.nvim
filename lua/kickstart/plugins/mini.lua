return {
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- Examples:
      --  - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      --  - sd'   - [S]urround [D]elete [']quotes
      --  - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Enhanced movement for selections
      --
      -- Examples:
      --  - Alt+h - Move selection left
      --  - Alt+j - Move selection down
      require('mini.move').setup()

      -- Comment lines or blocks of code
      --
      -- Examples:
      --  - gcc  - [G]o [C]omment [C]urrent line
      --  - gc{motion} - [G]o [C]omment {motion}
      --  - gc2j - [G]o [C]omment 2 lines down
      require('mini.comment').setup()

      -- Highlight occurrences of word under cursor
      require('mini.cursorword').setup()

      -- Minimap sidebar visualizing buffer content
      --
      --  - Toggle with :lua MiniMap.toggle()
      --  - Jump to locations by clicking
      -- require('mini.map').setup()

      -- Enhanced bracket movement and operations
      --
      -- Examples:
      --  - ]f - Jump to [N]ext [F]unction start
      --  - [c - Jump to [P]revious [C]omment
      --  - ]i - Jump to [N]ext [I]ndent change
      --  - [b - Jump to [P]revious [B]racket
      require('mini.bracketed').setup()

      -- Add animation onto the neovim editor
      local animate = require 'mini.animate'

      -- Define the threshold outside the setup function
      local NOANIMATION_JUMP_THRESHOLD = 60

      animate.setup {
        -- Disable cursor animations for large jumps
        cursor = {
          enable = true,
          path = function(dest, src)
            -- Check if src or dest is nil to prevent errors
            if not src or not dest then
              return {} -- Return empty path to skip animation
            end

            -- Check if we have valid indices
            if not src[1] or not dest[1] then
              return {} -- Return empty path to skip animation
            end

            -- Calculate movement distance (in lines)
            local line_diff = math.abs(dest[1] - src[1])

            -- If it's a large vertical jump (like gg or G), disable animation
            if line_diff > NOANIMATION_JUMP_THRESHOLD then
              return { src, dest } -- Just return start and end points
            end

            -- Use default path for normal movements
            return animate.gen_path.line { max_output_steps = 1000 }(dest, src)
          end,
        },

        -- Enable scroll animation but customize it to exclude gg and G
        scroll = {
          enable = true,
          subscroll = function(total_scroll)
            -- Safety check for nil value
            if not total_scroll then
              return {} -- Return empty subscroll to skip animation
            end

            -- Disable animation for very large scrolls (which are likely gg/G)
            if math.abs(total_scroll) > NOANIMATION_JUMP_THRESHOLD then
              return { total_scroll } -- Return single step (no animation)
            end

            -- Use default subscroll for normal scrolling
            return animate.gen_subscroll.equal { max_output_steps = 60 }(total_scroll)
          end,
        },
      }
      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et

-- Central plugin registry. Plugin-specific setup lives in sibling modules.
return {
  -- Editing and navigation
  'tpope/vim-fugitive',
  'mbbill/undotree',
  'tpope/vim-rhubarb',
  'tpope/vim-surround',
  'tpope/vim-sleuth',
  'ghassan0/telescope-glyph.nvim',
  {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('plugins.diffview')
    end,
  },
  {
    "scalameta/nvim-metals",
    ft = { "scala", "sbt", "java" },
    opts = require('plugins.metals').opts,
    config = function(self, metals_config)
      require('plugins.metals').setup(self.ft, metals_config)
    end,
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require('plugins.harpoon')
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      {
        'j-hui/fidget.nvim',
        opts = {
          progress = {
            -- gopls reports workspace/package-loading failures as progress
            -- updates. Keep real diagnostics, but do not pin that noisy
            -- progress stream over unrelated buffers.
            ignore = { 'gopls' },
          },
        },
      },

      'folke/neodev.nvim',
    },
    config = function()
      require('plugins.lsp')
    end
  },
  {
    "azratul/live-share.nvim",
    dependencies = {
      "jbyuki/instant.nvim",
    },
    config = function()
      vim.g.instant_username = "tur"
      require("live-share").setup({
       -- Add your configuration here
      })
    end
  },
  {
  'mrcjkb/haskell-tools.nvim',
    version = '^5', -- Recommended
    lazy = false, -- This plugin is already lazy
  },
  {
    "olimorris/codecompanion.nvim",
    opts = {},
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function ()
      require('plugins.codecompanion')
    end
  },
  {
  "RRethy/vim-illuminate",
  event = "CursorHold",
  },

  {
    'isovector/cornelis',
    name = 'cornelis',
    ft = 'agda',
    build = 'stack install',
    dependencies = {'neovimhaskell/nvim-hs.vim', 'kana/vim-textobj-user'},
    version = '*',
    config = function()
      require("plugins.cornelis")
    end,
  },
  {
    'voldikss/vim-floaterm',
    config = function()
      require('plugins.floaterm')  -- Load floaterm configuration from a separate file
    end
  },
  {
    'kyazdani42/nvim-web-devicons',
    config = function()
      require('nvim-web-devicons').setup { default = true }
    end
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      require("plugins.dap")
    end,
  },
  {
      'frazrepo/vim-rainbow'
  },
  {
      "epwalsh/obsidian.nvim",
      version = "*",
      lazy = true,
      ft = "markdown",
      dependencies = {
        "nvim-lua/plenary.nvim",
      },
      config = function()
        require('plugins.obsidian')
      end,
  },
  {
    "tadmccorkle/markdown.nvim",
    ft = "markdown", -- or 'event = "VeryLazy"'
    opts = {
      -- configuration here or empty for defaults
    },
  },
  {
    'stevearc/aerial.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = {
       "nvim-treesitter/nvim-treesitter",
       "nvim-tree/nvim-web-devicons"
    },
    config = function()
      require('plugins.aerial')  -- Load aerial configuration from separate file
    end,
  },

  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("plugins.copilot")
    end,
  },
  {
    'windwp/nvim-autopairs',
    config = function()
      require('plugins.nvim-autopairs')  -- Load nvim-autopairs configuration from separate file
    end
  },

  {
    "okuuva/auto-save.nvim",
    cmd = "ASToggle", -- optional for lazy loading on command
    event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
    opts = {
      -- your config goes here
      -- or just leave it empty :)
    },
    -- colorschemes
  },
  { "Mofiqul/vscode.nvim" },
  { "mellow-theme/mellow.nvim" },
  { "EdenEast/nightfox.nvim" },  
  { "Mofiqul/dracula.nvim" },  
  { "rose-pine/neovim", name = "rose-pine" },
  {
    'bluz71/vim-nightfly-colors',
    config = function()
      vim.cmd.colorscheme "nightfly"
    end,
  },

  {
    "ellisonleao/gruvbox.nvim", priority = 1000 , config = true, opts = {}
  },
  { 'tomasiser/vim-code-dark', priority = 1000},
  { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = false, priority = 1000 },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  {
    'kyazdani42/nvim-tree.lua',
    dependencies = { 'kyazdani42/nvim-web-devicons' },
    config = function()
      require('plugins.nvim-tree')
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = "make install_jsregexp"
  },
  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
    config = function()
      require('plugins.cmp')
    end,
  },

    -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },

  { 'christoomey/vim-tmux-navigator'},

  {
    'lewis6991/gitsigns.nvim',
    opts = function()
      require('plugins.gitsigns')  -- Load gitsigns configuration from separate file
    end
  },

  {
    'nvim-lualine/lualine.nvim',
    opts = function()
      require('plugins.lualine')  -- Load lualine configuration from separate file
    end
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = 'master',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end
      }
    },
    config = function()
      require('plugins.telescope')  -- Load telescope configuration from separate file
    end
  },

  -- Expandable LSP call hierarchies (for example: foo -> bar2 -> bar3).
  {
    'marcomayer/calltree.nvim',
    config = function()
      require('plugins.calltree')
    end,
  },

  {
    'nvimdev/dashboard-nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = "VimEnter",
    opts = function()
      return require('plugins.dashboard')
    end
  },


  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = "main",
    lazy = false,
    dependencies = {
      -- 'nvim-treesitter/nvim-treesitter-textobjects',
    },
    -- config = function()
    --   require('plugins.treesitter')
    -- end,
  },

}

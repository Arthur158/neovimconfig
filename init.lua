-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Install `lazy.nvim` plugin manager ]]

--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Load the lazy.nvim setup
require('lazy').setup({

  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'tpope/vim-surround',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

-- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
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
  -- {
  -- 'mrcjkb/haskell-tools.nvim',
  --   version = '^5', -- Recommended
  --   lazy = false, -- This plugin is already lazy
  -- },
  {
    "olimorris/codecompanion.nvim",
    opts = {},
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
  "RRethy/vim-illuminate",
  event = "CursorHold",
  },

  -- {
  --   'nvim-telescope/telescope-frecency.nvim',
  --   requires = {'tami5/sqlite.lua'},
  --   config = function()
  --     require('telescope').load_extension('frecency')
  --   end
  -- },
-- {
--   "derekelkins/agda-vim",
--   lazy = false,  -- Load immediately
-- },
-- {
--   "ashinkarov/nvim-agda",
--   lazy = false,  -- Load immediately for debugging
--   config = function()
--     -- Enable debug mode
--     vim.g.nvim_agda_settings = {
--       agda = "/usr/bin/agda",  -- Update this path!
--       agda_args = {},
--       debug_p = true  -- Turn on debugging
--     }
--     
--     -- Print confirmation
--     print("nvim-agda loaded!")
--     print("Agda path: " .. (vim.g.nvim_agda_settings.agda or "not set"))
--   end,
-- },
-- {
--   'isovector/cornelis',
--   name = 'cornelis',
--   ft = 'agda',
--   build = 'stack install',
--   dependencies = {'neovimhaskell/nvim-hs.vim', 'kana/vim-textobj-user'},
--   version = '*',
--   config = function()
--     require("plugins.cornelis")
--   end,
-- },
  -- {
  --   'neovimhaskell/haskell-vim',
  --   ft = { 'haskell' },
  --   config = function()
  --     -- Plugin-specific configuration
  --   end
  -- },
  -- {
  --   "scalameta/nvim-metals",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --   },
  --   ft = { "scala", "sbt", "java" },
  --   opts = function()
  --     local metals_config = require("metals").bare_config()
  --     metals_config.on_attach = function(client, bufnr)
  --       -- your on_attach function
  --     end
  --
  --     return metals_config
  --   end,
  --   config = function(self, metals_config)
  --     local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
  --     vim.api.nvim_create_autocmd("FileType", {
  --       pattern = self.ft,
  --       callback = function()
  --         require("metals").initialize_or_attach(metals_config)
  --       end,
  --       group = nvim_metals_group,
  --     })
  --   end
  -- },
-- {
--   'untitled-ai/jupyter_ascending.vim',
--   config = function()
--     require('jupyter_ascending').setup()
--   end
-- },
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
-- {
-- 	'nvim-java/nvim-java',
-- 	dependencies = {
-- 		'nvim-java/lua-async-await',
-- 		'nvim-java/nvim-java-refactor',
-- 		'nvim-java/nvim-java-core',
-- 		'nvim-java/nvim-java-test',
-- 		'nvim-java/nvim-java-dap',
-- 		'MunifTanjim/nui.nvim',
-- 		'neovim/nvim-lspconfig',
-- 		'mfussenegger/nvim-dap',
-- 		{
-- 			'JavaHello/spring-boot.nvim',
-- 			commit = '218c0c26c14d99feca778e4d13f5ec3e8b1b60f0',
-- 		},
-- 		{
-- 			'williamboman/mason.nvim',
-- 			opts = {
-- 				registries = {
-- 					'github:nvim-java/mason-registry',
-- 					'github:mason-org/mason-registry',
-- 				},
-- 			},
-- 		},
-- 	},
--   config = function()
--       require('plugins.nvim-java')
--   end
-- },
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
  "whonore/Coqtail"
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
    -- nightfly
    'bluz71/vim-nightfly-colors',
    config = function()
      vim.cmd.colorscheme "nightfly"
    end,
  },

  {
    "ellisonleao/gruvbox.nvim", priority = 1000 , config = true, opts = ...
  },
  { 'tomasiser/vim-code-dark', priority = 1000},
  { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = false, priority = 1000 },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  -- Configuration for nvim-tree
{
  'kyazdani42/nvim-tree.lua',
  dependencies = { 'kyazdani42/nvim-web-devicons' },
  config = function()
    require('nvim-tree').setup {
      hijack_netrw = true,           -- Replaces netrw with nvim-tree, optional
      sync_root_with_cwd = false,    -- Prevents syncing with the current directory automatically
      respect_buf_cwd = true,        -- Enables respecting buffer directory when switching files
      actions = {
        open_file = {
          quit_on_open = true,       -- Closes the tree when opening a file
        },
      },
      renderer = {
        icons = {
          glyphs = {
            default = "",
            symlink = "",
            folder = {
              arrow_open = "",
              arrow_closed = "",
              default = "",
              open = "",
              empty = "",
              empty_open = "",
              symlink = "",
              symlink_open = "",
            },
            git = {
              unstaged = "✗",
              staged = "✓",
              unmerged = "",
              renamed = "➜",
              untracked = "★",
              deleted = "",
              ignored = "◌",
            },
          },
        },
      },
    }
  end
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
  'romgrk/barbar.nvim',
  dependencies = {
    'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
    'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
  },
  init = function()
    vim.g.barbar_auto_setup = false
  end,
  opts = {
    icons = {
      enabled = true, -- Enable icons
      separator = {
        left = '▎', -- Left separator icon
        right = '▎' -- Right separator icon
      },
      filetype = {
        custom_colors = false, -- Optional: enables filetype colors
      },
    },
    -- You can add any other options you'd like here
    -- Other options previously in your setup
  },
  version = '^1.0.0', -- optional: only update when a new 1.x version is released
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

    -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
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

  {
    'nvimdev/dashboard-nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = "VimEnter",
    opts = function()
      local logo = [[
           ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z
           ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z    
           ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z       
           ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z         
           ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║           
           ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝           
      ]]

      logo = string.rep("\n", 8) .. logo .. "\n\n"

      local opts = {
        theme = "doom",
        hide = {
          -- this is taken care of by lualine
          -- enabling this messes up the actual laststatus setting after loading a file
          statusline = false,
        },
        config = {
          header = vim.split(logo, "\n"),
          -- stylua: ignore
          footer = function()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
          end,
        },
      }


      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "DashboardLoaded",
          callback = function()
            require("lazy").show()
          end,
        })
      end

    local projects = {
        { path = "~/main", desc = "main", key = "1" },
        { path = "~/.config/nvim", desc = "nvim config", key = "2" },
        -- Add more projects as needed
    }

    -- Function to open a project
    local function open_project(project_path)
        return function()
            vim.cmd("cd " .. project_path)
            -- Command to open Telescope in the specified project directory
            vim.cmd("Telescope find_files cwd=" .. project_path)
        end
    end

    -- Update the center section with your projects
    opts.config.center = {
        { action = "Telescope find_files", desc = " Find file",       icon = " ", key = "f" },
        -- { action = "Telescope frecency",   desc = " Recent files",    icon = " ", key = "r" },
        { action = "ene | startinsert", desc = " New file",        icon = " ", key = "n" },
    }
      
    for _, button in ipairs(opts.config.center) do
      button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
      button.key_format = "  %s"
    end

    -- Add project entries to the center section
    for _, project in ipairs(projects) do
        table.insert(opts.config.center, {
            action = open_project(project.path),
            desc = project.desc,
            icon = " ", -- You can choose an appropriate icon
            key = project.key
        })
    end

      return opts
    end
  },


  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function()
      require('plugins.treesitter')
    end,
    build = ':TSUpdate',
  },

  -- ... (rest of your plugins)
}, {})

-- Load general settings
require('settings.options')

-- Load key mappings
require('keymaps/telescope')
require('keymaps/mappings')

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ configure telescope ]]
-- see `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  extensions = {
    -- frecency = {
    --   show_scores = true,
    --   auto_validate = true,
    -- },
  },
  defaults = {
    mappings = {
      i = {
        ['<c-u>'] = false,
        ['<c-d>'] = false,
      },
    },
  },
}

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep({
      search_dirs = {git_root},
    })
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(client, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc, remap = true })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  -- nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  -- nmap('gd', "<cmd>Telescope lsp_definitions<CR>", '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  -- nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- -- document existing key chains
-- require('which-key').register {
--
--     -- { "<leader>c", group = "[C]ode" },
--     -- { "<leader>c_", hidden = true },
--     -- { "<leader>d", group = "[D]ocument" },
--     -- { "<leader>d_", hidden = true },
--     -- { "<leader>g", group = "[G]it" },
--     -- { "<leader>g_", hidden = true },
--     -- { "<leader>r", group = "[R]ename" },
--     -- { "<leader>r_", hidden = true },
--     -- { "<leader>s", group = "[S]earch" },
--     -- { "<leader>s_", hidden = true },
--     -- { "<leader>w", group = "[W]orkspace" },
--     -- { "<leader>w_", hidden = true },
--     -- { "", group = "[C]ode" },
--     -- { "", group = "[S]earch" },
--     -- { "", desc = "<leader>r_", hidden = true },
--     -- { "", desc = "<leader>s_", hidden = true },
--     -- { "", group = "[W]orkspace" },
--     -- { "", group = "[R]ename" },
--     -- { "", desc = "<leader>w_", hidden = true },
--     -- { "", group = "[G]it" },
--     -- { "", desc = "<leader>g_", hidden = true },
--     -- { "", group = "[D]ocument" },
--     -- { "", desc = "<leader>c_", hidden = true },
--     -- { "", desc = "<leader>d_", hidden = true },
--     -- { "<leader>c", group = "[C]ode" },
--     -- { "<leader>c_", hidden = true },
--     -- { "<leader>d", group = "[D]ocument" },
--     -- { "<leader>d_", hidden = true },
--     -- { "<leader>g", group = "[G]it" },
--     -- { "<leader>g_", hidden = true },
--     -- { "<leader>r", group = "[R]ename" },
--     -- { "<leader>r_", hidden = true },
--     -- { "<leader>s", group = "[S]earch" },
--     -- { "<leader>s_", hidden = true },
--     -- { "<leader>w", group = "[W]orkspace" },
--     -- { "<leader>w_", hidden = true },
--     -- {
--     --   mode = { "n", "n" },
--     --   { "", desc = "<leader>g_", hidden = true },
--     --   { "", desc = "<leader>c_", hidden = true },
--     --   { "", desc = "<leader>d_", hidden = true },
--     --   { "", desc = "<leader>w_", hidden = true },
--     --   { "", desc = "<leader>s_", hidden = true },
--     --   { "", desc = "<leader>r_", hidden = true },
--     -- },
--     -- {
--     --   mode = { "n", "n", "n" },
--     --   { "", group = "[C]ode" },
--     --   { "", group = "[D]ocument" },
--     --   { "", group = "[R]ename" },
--     --   { "", group = "[W]orkspace" },
--     --   { "", group = "[S]earch" },
--     --   { "", group = "[G]it" },
--     -- },
--     -- { "", desc = "", hidden = true, mode = { "n", "n", "n", "n", "n", "n" } },
-- }

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}


-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = servers[server_name],
        filetypes = (servers[server_name] or {}).filetypes,
      }
    end,
  },
}

-- mason_lspconfig.setup_handlers {
--   function(server_name)
--     require('lspconfig')[server_name].setup {
--       capabilities = capabilities,
--       on_attach = on_attach,
--       settings = servers[server_name],
--       filetypes = (servers[server_name] or {}).filetypes,
--     }
--   end,
-- }

require('plugins.cmp')

-- vim.cmd('syntax on')
-- vim.cmd('syntax on')
vim.cmd('syntax spell toplevel')  -- Disable syntax-based spell checking
vim.opt.spell = false  -- Ensure global spell checking is off
vim.cmd('filetype plugin indent on')
-- vim.cmd('colorscheme desert')

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

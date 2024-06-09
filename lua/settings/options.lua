-- options.lua
-- Set Neovim global options here

-- Enable highlight search
vim.o.hlsearch = false

vim.o.background = "dark" -- or "light" for light mode
vim.cmd([[colorscheme vscode]])

vim.o.conceallevel = 1  -- or set to 2

vim.o.wrap = false
vim.o.scrolloff = 12
vim.o.sidescrolloff = 16

-- Enable line numbers
vim.wo.number = true

-- Enable linebreak
vim.wo.linebreak = true

-- Enable mouse support
vim.o.mouse = 'a'

-- Set clipboard to use system clipboard
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching unless /C or capital letter is used
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep sign column on
vim.wo.signcolumn = 'yes'

-- Decrease update time for more responsive UI
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt for better completion experience
vim.o.completeopt = 'menuone,noselect'

-- Ensure terminal GUI colors are used
vim.o.termguicolors = true

-- Enable relative line numbers
vim.wo.relativenumber = true

-- Return from this file so it can be required successfully
return {}


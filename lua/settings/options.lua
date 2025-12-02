-- options.lua
-- Set Neovim global options here

-- Enable highlight search
vim.o.hlsearch = false
vim.opt.spell = false

vim.o.background = "dark" -- or "light" for light mode
vim.cmd([[colorscheme catppuccin-mocha]])

-- auto-reload files when modified externally
-- https://unix.stackexchange.com/a/383044
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
  command = "if mode() != 'c' | checktime | endif",
  pattern = { "*" },
})

vim.diagnostic.config({
    virtual_text = {
        severity = { min = vim.diagnostic.severity.WARN }, -- Hide hints & info
    },
    signs = {
        severity = { min = vim.diagnostic.severity.WARN },
    },
    underline = {
        severity = { min = vim.diagnostic.severity.WARN },
    },
    update_in_insert = false,
})

-- Table to track buffer access order
local buffer_access_order = {}

-- Function to update buffer access
local function update_buffer_access(bufnr)
  -- Remove the buffer if it already exists in the order
  for i = #buffer_access_order, 1, -1 do
    if buffer_access_order[i] == bufnr then
      table.remove(buffer_access_order, i)
    end
  end

  -- Add the buffer to the end of the list
  table.insert(buffer_access_order, bufnr)
end

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
        vim.opt.spell = false
    end,
})

local function enforce_buffer_limit()
  local max_buffers = 7

  -- Sanitize: remove invalid buffers from access order
  for i = #buffer_access_order, 1, -1 do
    local b = buffer_access_order[i]
    if not vim.api.nvim_buf_is_valid(b) then
      table.remove(buffer_access_order, i)
    end
  end

  if #buffer_access_order > max_buffers then
    -- LRU = first element
    local lru_bufnr = table.remove(buffer_access_order, 1)

    -- Only delete if:
    --   - buffer is valid
    --   - buffer is listed (real file buffers only)
    --   - buffer is loaded
    if vim.api.nvim_buf_is_valid(lru_bufnr)
      and vim.api.nvim_buf_is_loaded(lru_bufnr)
      and vim.api.nvim_buf_get_option(lru_bufnr, "buflisted")
    then
      -- Safe deletion (avoid throwing errors inside autocommands)
      pcall(vim.api.nvim_buf_delete, lru_bufnr, { force = true })
    end
  end
end

-- Autocommand to track buffer access and enforce limit
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local bufnr = vim.fn.bufnr()
    update_buffer_access(bufnr)
    enforce_buffer_limit()
  end,
})


vim.api.nvim_buf_set_var(0, 'coqtail_coq_path', '~/.opam/4.14.1/bin')
vim.api.nvim_buf_set_var(0, 'coqtail_coq_prog', 'coqtop')

vim.o.conceallevel = 1  -- or set to 2

vim.o.wrap = false
vim.o.scrolloff = 12
vim.o.sidescrolloff = 16

-- Enable line numbers
vim.wo.number = true

-- Enable linebreak
vim.wo.linebreak = true

vim.opt.autoread = true

-- vim.g.which_key_check_health = false

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

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascriptreact", "typescriptreact", "javascript", "typescript" },
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascriptreact", "typescriptreact" },
  callback = function()
    vim.bo.expandtab = true
  end,
})


-- Return from this file so it can be required successfully
return {}


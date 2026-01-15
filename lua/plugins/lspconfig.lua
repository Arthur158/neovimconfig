-- plugins/lspconfig.lua

-- LSP server configuration
require'lspconfig'.pyright.setup{}  -- Example for Python; repeat for other servers

-- ... (additional LSP server configurations)

-- Configuration for Mason
require('mason').setup()

-- Configuration for Mason LSPconfig
require('mason-lspconfig').setup({
  -- Specify LSP servers to automatically install
  ensure_installed = { 'pyright', 'tsserver', 'rust_analyzer', --[[ more servers ]] },
})

-- Fidget.nvim setup for LSP progress
require('fidget').setup{}

-- ... (any other additional LSP related configurations)

-- Return from this file so it can be required successfully
return {}

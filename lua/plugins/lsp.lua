local servers = {
  gopls = {},
  clangd = {},
  pyright = {},
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

require('mason').setup()
require('neodev').setup()

local capabilities = require('cmp_nvim_lsp').default_capabilities(
  vim.lsp.protocol.make_client_capabilities()
)
local mason_lspconfig = require('mason-lspconfig')

mason_lspconfig.setup({
  ensure_installed = vim.tbl_keys(servers),
})

for _, server_name in ipairs(vim.tbl_keys(servers)) do
  local server_config = {
    capabilities = capabilities,
    on_attach = require('plugins.lsp-keymaps').on_attach,
    settings = servers[server_name],
    filetypes = servers[server_name].filetypes,
  }

  if server_name == 'gopls' then
    -- Prefer local Go workspace metadata and fall back to Nebo's Bazel package driver.
    server_config.cmd = {
      '/home/arthur-jacques/.local/share/nvim/nebo-gopls/gopls-wrapper',
    }
    -- nvim-lspconfig prefers an ancestor go.work over a nearer go.mod.  In
    -- Nebo that makes every Go buffer load the entire multi-module checkout.
    -- Keep gopls scoped to the module containing the file when possible.
    server_config.root_dir = function(bufnr, on_dir)
      local filename = vim.api.nvim_buf_get_name(bufnr)
      on_dir(
        vim.fs.root(filename, 'go.mod')
          or vim.fs.root(filename, 'go.work')
          or vim.fs.root(filename, '.git')
      )
    end
  end

  vim.lsp.config(server_name, server_config)
end

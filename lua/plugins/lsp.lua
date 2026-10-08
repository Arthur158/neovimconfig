local servers = {
  gopls = {},
  clangd = {},
  protols = {},
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
      local nebo_root = vim.fs.root(filename, '.nebo.root')
      local testenv_root = nebo_root and (nebo_root .. '/vpc/testenv')

      -- vpc/testenv needs Nebo's Bazel package driver for generated and
      -- overlaid packages.  Give it a separate client so the rest of vpc can
      -- keep using the much faster local Go-module workspace.
      if testenv_root and (filename == testenv_root or vim.startswith(filename, testenv_root .. '/')) then
        on_dir(testenv_root)
        return
      end

      on_dir(
        vim.fs.root(filename, 'go.mod')
          or vim.fs.root(filename, 'go.work')
          or vim.fs.root(filename, '.git')
      )
    end
  end

  if server_name == 'protols' then
    local protoc_root = vim.fn.stdpath('data') .. '/protoc-36.2'
    server_config.cmd = {
      'protols',
      '--include-paths',
      protoc_root .. '/include',
    }
    server_config.cmd_env = {
      PATH = protoc_root .. '/bin:' .. vim.env.PATH,
    }
  end

  vim.lsp.config(server_name, server_config)
end

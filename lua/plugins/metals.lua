local M = {}

function M.opts()
  local config = require('metals').bare_config()
  config.on_attach = require('plugins.lsp-keymaps').metals_on_attach
  config.capabilities = require('cmp_nvim_lsp').default_capabilities(
    vim.lsp.protocol.make_client_capabilities()
  )
  config.settings = {
    showImplicitArguments = true,
    showInferredType = true,
    excludedPackages = {
      'akka.actor.typed.javadsl',
      'com.github.swagger.akka.javadsl',
    },
  }
  return config
end

function M.setup(filetypes, config)
  local group = vim.api.nvim_create_augroup('nvim-metals', { clear = true })
  vim.api.nvim_create_autocmd('FileType', {
    pattern = filetypes,
    group = group,
    callback = function()
      require('metals').initialize_or_attach(config)
    end,
  })
end

return M

local M = {}

local function mapper(bufnr)
  return function(keys, func, desc)
    vim.keymap.set('n', keys, func, {
      buffer = bufnr,
      desc = 'LSP: ' .. desc,
      remap = true,
    })
  end
end

local function common(bufnr)
  local nmap = mapper(bufnr)
  local telescope = require('telescope.builtin')

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  nmap('gd', telescope.lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', telescope.lsp_references, '[G]oto [R]eferences')
  nmap('gI', telescope.lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', telescope.lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', telescope.lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', telescope.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
  nmap('<leader>co', vim.lsp.buf.outgoing_calls, '[C]all hierarchy: [O]utgoing')
  nmap('<leader>ci', vim.lsp.buf.incoming_calls, '[C]all hierarchy: [I]ncoming')
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

  return nmap
end

function M.on_attach(_, bufnr)
  local nmap = common(bufnr)

  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function()
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

function M.metals_on_attach(_, bufnr)
  local nmap = common(bufnr)
  nmap('<leader>mc', function()
    require('metals').commands()
  end, '[M]etals [C]ommands')
  nmap('<leader>mi', function()
    require('metals').organize_imports()
  end, '[M]etals [I]mports')
end

return M

vim.api.nvim_create_user_command('LiveGrepGitRoot', function()
  local current_file = vim.api.nvim_buf_get_name(0)
  local start_path = current_file ~= '' and current_file or vim.uv.cwd()
  local git_root = vim.fs.root(start_path, '.git')

  if not git_root then
    vim.notify('Not inside a Git repository', vim.log.levels.WARN)
    return
  end

  require('telescope.builtin').live_grep({
    search_dirs = { git_root },
  })
end, { desc = 'Search text from the current Git root' })

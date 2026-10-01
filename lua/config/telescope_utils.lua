local M = {}

local nebo_repositories = {
  nebo = true,
  nebo2 = true,
  neboreplica = true,
}

local function nebo_roots(path)
  if not path or path == '' then
    return nil
  end

  path = vim.fs.normalize(path)
  if vim.fn.isdirectory(path) == 0 then
    path = vim.fs.dirname(path)
  end

  while path do
    if nebo_repositories[vim.fs.basename(path)] then
      local vpc_root = vim.fs.joinpath(path, 'vpc')
      if vim.fn.isdirectory(vpc_root) == 1 then
        return path, vpc_root
      end
    end

    local parent = vim.fs.dirname(path)
    if not parent or parent == path then
      break
    end
    path = parent
  end
end

function M.roots()
  local current_file = vim.api.nvim_buf_get_name(0)
  local repo_root, vpc_root = nebo_roots(current_file)
  if repo_root then
    return repo_root, vpc_root
  end
  return nebo_roots(vim.uv.cwd())
end

function M.repo_root()
  return M.roots()
end

function M.vpc_root()
  local _, vpc_root = M.roots()
  return vpc_root
end

local function is_vpc_entry(entry, line, repo_root, vpc_root)
  local path = entry and entry.filename or line
  if not path or path == '' then
    return false
  end

  if not vim.startswith(path, '/') then
    path = vim.fs.joinpath(repo_root, path)
  end
  path = vim.fs.normalize(path)

  return path == vpc_root or vim.startswith(path, vpc_root .. '/')
end

local function prioritized_sorter(picker_name, repo_root, vpc_root)
  local config = require('telescope.config').values
  local file_picker = picker_name == 'find_files' or picker_name == 'git_files'
  local sorter = (file_picker and config.file_sorter or config.generic_sorter)({})
  local score = sorter.scoring_function

  sorter.scoring_function = function(self, prompt, line, entry, ...)
    local base_score = score(self, prompt, line, entry, ...)
    if not base_score or base_score < 0 then
      return base_score
    end

    -- Keep fuzzy relevance within each group, but rank every vpc match ahead
    -- of matches elsewhere in the checkout.
    local normalized_score = base_score / (1 + base_score)
    if is_vpc_entry(entry, line, repo_root, vpc_root) then
      return normalized_score
    end
    return 1 + normalized_score
  end

  return sorter
end

function M.options(opts, picker_name)
  opts = vim.deepcopy(opts or {})
  if not opts.cwd and not opts.search_dirs then
    local repo_root, vpc_root = M.roots()
    if repo_root then
      opts.cwd = repo_root
      if not opts.sorter then
        opts.sorter = prioritized_sorter(picker_name, repo_root, vpc_root)
      end
    end
  end
  return opts
end

function M.picker(name, opts)
  return function()
    require('telescope.builtin')[name](M.options(opts, name))
  end
end

function M.setup()
  if M._configured then
    return
  end
  M._configured = true

  local builtin = require('telescope.builtin')
  for _, name in ipairs({ 'find_files', 'git_files', 'live_grep', 'grep_string' }) do
    local picker_name = name
    local original = builtin[picker_name]
    builtin[picker_name] = function(opts)
      original(M.options(opts, picker_name))
    end
  end
end

return M

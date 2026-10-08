local M = {}

local nebo_repositories = {
  nebo = true,
  nebo2 = true,
  neboreplica = true,
}

local git_status_cache = {}
local git_status_cache_ttl_ms = 2000
local vpc_priority_limit = 100

local vpc_first_rg_script = [=[
rg_command=$1
shift
priority_limit=$1
shift
arguments=("$@")
separator_index=

for index in "${!arguments[@]}"; do
  if [[ "${arguments[$index]}" == "--" ]]; then
    separator_index=$index
    break
  fi
done

if [[ -z "$separator_index" ]] || (( separator_index + 1 >= ${#arguments[@]} )); then
  exec "$rg_command" "${arguments[@]}"
fi

rg_arguments=("${arguments[@]:0:separator_index}")
search_arguments=("${arguments[@]:separator_index+1}")

"$rg_command" "${rg_arguments[@]}" -- "${search_arguments[@]}" vpc | head -n "$priority_limit"
vpc_status=${PIPESTATUS[0]}

if (( vpc_status > 1 && vpc_status != 141 )); then
  exit "$vpc_status"
fi

"$rg_command" "${rg_arguments[@]}" --glob '!vpc/**' -- "${search_arguments[@]}" .
rest_status=$?

if (( rest_status > 1 )); then
  exit "$rest_status"
fi

"$rg_command" "${rg_arguments[@]}" -- "${search_arguments[@]}" vpc | tail -n "+$((priority_limit + 1))"
remaining_vpc_status=${PIPESTATUS[0]}

if (( remaining_vpc_status > 1 )); then
  exit "$remaining_vpc_status"
fi
if (( vpc_status == 0 || vpc_status == 141 || rest_status == 0 || remaining_vpc_status == 0 )); then
  exit 0
fi
exit 1
]=]

local vpc_first_files_script = [=[
rg_command=$1
shift
priority_limit=$1
shift

"$rg_command" "$@" vpc | head -n "$priority_limit"
vpc_status=${PIPESTATUS[0]}

if (( vpc_status > 1 && vpc_status != 141 )); then
  exit "$vpc_status"
fi

"$rg_command" "$@" --glob '!vpc/**' .
rest_status=$?

if (( rest_status > 1 )); then
  exit "$rest_status"
fi

"$rg_command" "$@" vpc | tail -n "+$((priority_limit + 1))"
remaining_vpc_status=${PIPESTATUS[0]}

if (( remaining_vpc_status > 1 )); then
  exit "$remaining_vpc_status"
fi
if (( vpc_status == 0 || vpc_status == 141 || rest_status == 0 || remaining_vpc_status == 0 )); then
  exit 0
fi
exit 1
]=]

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

local function entry_path(entry, line, repo_root)
  local path = entry and entry.filename or line
  if not path or path == '' then
    return nil
  end

  if not vim.startswith(path, '/') then
    path = vim.fs.joinpath(repo_root, path)
  end
  return vim.fs.normalize(path)
end

local function parse_git_status(repo_root, output)
  local changed = {}
  local records = vim.split(output or '', '\0', { plain = true, trimempty = true })
  local index = 1
  while index <= #records do
    local record = records[index]
    local status = record:sub(1, 2)
    local path = record:sub(4)
    if path ~= '' then
      changed[vim.fs.normalize(vim.fs.joinpath(repo_root, path))] = true
    end

    -- Porcelain -z output adds the old path after a renamed or copied path.
    if status:find('[RC]') then
      index = index + 1
    end
    index = index + 1
  end
  return changed
end

local function refresh_git_status(repo_root)
  local cached = git_status_cache[repo_root] or {}
  git_status_cache[repo_root] = cached
  if cached.loading then
    return
  end

  cached.loading = true
  vim.system({
    'git', '-C', repo_root, 'status', '--porcelain=v1', '-z', '--untracked-files=all',
  }, { text = true }, function(result)
    vim.schedule(function()
      cached.loading = false
      cached.updated_at = vim.uv.hrtime() / 1000000
      if result.code == 0 then
        -- Replace the table so an already-open picker keeps its stable snapshot.
        cached.changed = parse_git_status(repo_root, result.stdout)
      end
    end)
  end)
end

local function cached_git_changed_files(repo_root)
  local cached = git_status_cache[repo_root]
  local now = vim.uv.hrtime() / 1000000
  if not cached or not cached.updated_at or now - cached.updated_at >= git_status_cache_ttl_ms then
    refresh_git_status(repo_root)
  end
  return cached and cached.changed or nil
end

local function is_vpc_entry(path, vpc_root)
  if not path then
    return false
  end

  return path == vpc_root or vim.startswith(path, vpc_root .. '/')
end

local function prioritized_sorter(picker_name, repo_root, vpc_root)
  local config = require('telescope.config').values
  local file_picker = picker_name == 'find_files' or picker_name == 'git_files'
  local sorter = (file_picker and config.file_sorter or config.generic_sorter)({})
  local score = sorter.scoring_function
  local changed_files = cached_git_changed_files(repo_root)

  sorter.scoring_function = function(self, prompt, line, entry, ...)
    local base_score = score(self, prompt, line, entry, ...)
    if not base_score or base_score < 0 then
      return base_score
    end

    local normalized_score = base_score / (1 + base_score)
    local path = entry_path(entry, line, repo_root)

    -- Reserve an initial VPC-priority window without hiding every other result.
    local priority_vpc = is_vpc_entry(path, vpc_root)
      and (not entry or not entry.index or entry.index <= vpc_priority_limit)

    if not changed_files then
      if priority_vpc then
        return normalized_score
      end
      return 1 + normalized_score
    end

    if path and changed_files[path] then
      return normalized_score
    end
    if priority_vpc then
      return 1 + normalized_score
    end
    return 2 + normalized_score
  end

  return sorter
end

local function vpc_first_vimgrep_arguments(opts)
  local arguments = vim.deepcopy(opts.vimgrep_arguments or require('telescope.config').values.vimgrep_arguments)
  local rg_command = table.remove(arguments, 1)
  if not rg_command or vim.fs.basename(rg_command) ~= 'rg' then
    return nil
  end

  return vim.list_extend({
    'bash', '-c', vpc_first_rg_script, 'telescope-vpc-first', rg_command, tostring(vpc_priority_limit),
  }, arguments)
end

local function vpc_first_find_command(opts)
  local arguments
  if opts.find_command then
    if type(opts.find_command) ~= 'table' then
      return nil
    end
    arguments = vim.deepcopy(opts.find_command)
  elseif vim.fn.executable('rg') == 1 then
    arguments = { 'rg', '--files', '--color', 'never' }
  else
    return nil
  end

  local rg_command = table.remove(arguments, 1)
  if not rg_command or vim.fs.basename(rg_command) ~= 'rg' then
    return nil
  end

  if opts.hidden then
    table.insert(arguments, '--hidden')
  end
  if opts.no_ignore then
    table.insert(arguments, '--no-ignore')
  end
  if opts.no_ignore_parent then
    table.insert(arguments, '--no-ignore-parent')
  end
  if opts.follow then
    table.insert(arguments, '-L')
  end
  if opts.search_file then
    vim.list_extend(arguments, { '-g', '*' .. opts.search_file .. '*' })
  end

  return vim.list_extend({
    'bash', '-c', vpc_first_files_script, 'telescope-vpc-first', rg_command, tostring(vpc_priority_limit),
  }, arguments)
end

function M.options(opts, picker_name)
  opts = vim.deepcopy(opts or {})
  if not opts.cwd and not opts.search_dirs then
    local repo_root, vpc_root = M.roots()
    if repo_root then
      opts.cwd = repo_root
      if picker_name == 'find_files' then
        opts.find_command = vpc_first_find_command(opts) or opts.find_command
      end
      if (picker_name == 'live_grep' or picker_name == 'grep_string') and not opts.grep_open_files then
        opts.vimgrep_arguments = vpc_first_vimgrep_arguments(opts) or opts.vimgrep_arguments
      end
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

function M.find_files_by_extension()
  local action_state = require('telescope.actions.state')
  local finders = require('telescope.finders')
  local extension = ''

  local command
  if vim.fn.executable('rg') == 1 then
    command = 'rg'
  elseif vim.fn.executable('fd') == 1 then
    command = 'fd'
  elseif vim.fn.executable('fdfind') == 1 then
    command = 'fdfind'
  else
    vim.notify('Extension filtering requires rg, fd, or fdfind', vim.log.levels.ERROR)
    return
  end

  local function find_command()
    local result
    if command == 'rg' then
      result = { command, '--files', '--color', 'never' }
    else
      result = { command, '--type', 'f', '--color', 'never' }
    end

    if extension ~= '' then
      vim.list_extend(result, { '--glob', '*.' .. extension })
    end
    return result
  end

  local function title()
    local filter = extension == '' and 'all' or '*.' .. extension
    return 'Find Files [extension: ' .. filter .. ' | <C-e> to change]'
  end

  local opts = M.options({ find_command = find_command() }, 'find_files')
  opts.prompt_title = title()
  opts.attach_mappings = function(prompt_bufnr, map)
    local function change_extension()
      vim.ui.input({
        prompt = 'File extension (blank for all): ',
        default = extension,
      }, function(input)
        if input == nil then
          return
        end

        extension = vim.trim(input):gsub('^%*?%.', '')
        local picker = action_state.get_current_picker(prompt_bufnr)
        picker.prompt_title = title()
        if picker.layout.prompt.border then
          picker.layout.prompt.border:change_title(picker.prompt_title)
        end
        local refresh_opts = M.options({ find_command = find_command() }, 'find_files')
        picker:refresh(finders.new_oneshot_job(refresh_opts.find_command, refresh_opts), { reset_prompt = false })

        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(prompt_bufnr) then
            vim.cmd.startinsert()
          end
        end)
      end)
    end

    map({ 'i', 'n' }, '<C-e>', change_extension)
    return true
  end

  require('telescope.builtin').find_files(opts)
end

function M.setup()
  if M._configured then
    return
  end
  M._configured = true

  local repo_root = M.repo_root()
  if repo_root then
    refresh_git_status(repo_root)
  end

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

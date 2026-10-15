local function entry_is_test_file(entry)
  if type(entry) ~= 'table' then
    return false
  end

  local path = entry.filename or entry.path
  if type(path) ~= 'string' or path == '' then
    return false
  end

  return vim.fs.basename(path):lower():find('test', 1, true) ~= nil
end

local function toggle_test_files(prompt_bufnr)
  local picker = require('telescope.actions.state').get_current_picker(prompt_bufnr)
  if not picker or not picker.sorter or type(picker.sorter.scoring_function) ~= 'function' then
    return
  end

  if not picker._test_file_filter_installed then
    local original_scoring_function = picker.sorter.scoring_function
    picker.sorter.scoring_function = function(sorter, prompt, line, entry, ...)
      if picker._exclude_test_files and entry_is_test_file(entry) then
        return -1
      end
      return original_scoring_function(sorter, prompt, line, entry, ...)
    end
    picker._test_file_filter_installed = true
  end

  picker._exclude_test_files = not picker._exclude_test_files
  picker:refresh(nil, { reset_prompt = false })
  vim.notify('Telescope: test files ' .. (picker._exclude_test_files and 'hidden' or 'shown'))
end

require('telescope').load_extension('glyph')
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<c-u>'] = false,
        ['<c-d>'] = false,
        ['<C-g>'] = toggle_test_files,
      },
      n = {
        ['<C-g>'] = toggle_test_files,
      },
    },
  },
}

pcall(require('telescope').load_extension, 'fzf')

require('config.telescope_utils').setup()

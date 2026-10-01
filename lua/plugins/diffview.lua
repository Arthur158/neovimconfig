local function toggle_file_history()
  if require('diffview.lib').get_current_view() then
    vim.cmd('DiffviewClose')
    return
  end

  local file = vim.fn.expand('%:p')
  if file == '' then
    vim.notify('Current buffer has no file to show history for', vim.log.levels.WARN)
    return
  end

  vim.cmd('DiffviewFileHistory ' .. vim.fn.fnameescape(file))
end

vim.keymap.set('n', '<leader>gh', toggle_file_history, {
  desc = '[G]it current file [H]istory toggle',
})

vim.keymap.set('n', '<leader>gq', '<cmd>DiffviewClose<CR>', {
  desc = '[G]it diffview [Q]uit',
})

return {}

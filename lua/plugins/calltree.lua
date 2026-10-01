require('calltree').setup({
  layout_size = 70,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'Calltree',
  callback = function(args)
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(args.buf) then
        return
      end

      vim.keymap.set('n', 'zo', function()
        local ui = require('calltree.ui')
        local tree_handle = ui.get_tree_from_buf(
          vim.api.nvim_get_current_tabpage(),
          vim.api.nvim_get_current_buf()
        )
        local node = require('calltree.ui.marshal').marshal_line(
          vim.api.nvim_win_get_cursor(0),
          tree_handle
        )

        if node and node.expanded then
          ui.collapse()
        else
          ui.expand()
        end
      end, {
        buffer = args.buf,
        silent = true,
        desc = 'Calltree: toggle node',
      })
    end)
  end,
})

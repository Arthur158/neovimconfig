require("obsidian").setup({
  workspaces = {
    {
      name = "main",
      path = "/home/arthurj/main"
    },
  },
  
  -- Use the note title as the filename
  note_id_func = function(title)
    -- If title is provided, use it directly as the ID
    if title ~= nil then
      -- Transform title into a valid filename: replace spaces with hyphens, remove special chars
      return title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
    else
      -- If no title, generate a timestamp-based ID
      return tostring(os.time())
    end
  end,

  -- Create note files with the ID as the filename (no timestamp prefix)
  note_path_func = function(spec)
    local path = spec.dir / tostring(spec.id)
    return path:with_suffix(".md")
  end,

  -- Keep your existing keymaps
  -- mappings = {
  --   -- Add the default gf mapping for following links
  --   ["gf"] = {
  --     action = function()
  --       return require("obsidian").util.gf_passthrough()
  --     end,
  --     opts = { noremap = false, expr = true, buffer = true },
  --   },
  --   -- You can add more default mappings here if you want
  -- },
})

-- Your custom keymaps
vim.keymap.set('n', '<leader>n', ':ObsidianNew<CR>', { silent = true })
vim.keymap.set('n', '<leader>k', ':ObsidianBacklinks<CR>', { silent = true })
vim.keymap.set('n', '<leader>j', ':ObsidianLinks<CR>', { silent = true })
vim.keymap.set('n', '<leader>o', ':ObsidianQuickSwitch<CR>', { silent = true })

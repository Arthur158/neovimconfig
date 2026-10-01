local logo = [[
     ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z
     ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z
     ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z
     ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z
     ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║
     ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝
]]

local telescope_utils = require('config.telescope_utils')

local opts = {
  theme = 'doom',
  hide = { statusline = false },
  config = {
    header = vim.split(string.rep('\n', 8) .. logo .. '\n\n', '\n'),
    footer = function()
      local stats = require('lazy').stats()
      local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
      return { '⚡ Neovim loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms' }
    end,
  },
}

if vim.o.filetype == 'lazy' then
  vim.cmd.close()
  vim.api.nvim_create_autocmd('User', {
    pattern = 'DashboardLoaded',
    callback = function()
      require('lazy').show()
    end,
  })
end

local projects = {
  { path = '~/main', desc = 'main', key = '1' },
  { path = '~/.config/nvim', desc = 'nvim config', key = '2' },
}

local function open_project(path)
  return function()
    vim.cmd('cd ' .. path)
    vim.cmd('Telescope find_files cwd=' .. path)
  end
end

opts.config.center = {
  { action = telescope_utils.picker('find_files'), desc = ' Find file', icon = ' ', key = 'f' },
  { action = 'ene | startinsert', desc = ' New file', icon = ' ', key = 'n' },
}

for _, button in ipairs(opts.config.center) do
  button.desc = button.desc .. string.rep(' ', 43 - #button.desc)
  button.key_format = '  %s'
end

for _, project in ipairs(projects) do
  table.insert(opts.config.center, {
    action = open_project(project.path),
    desc = project.desc,
    icon = ' ',
    key = project.key,
  })
end

return opts

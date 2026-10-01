# Neovim configuration map

The entry point is intentionally small. Start with `init.lua` to see the load order.

- `lua/config/` contains startup plumbing, custom commands, filetypes, and general autocmds.
- `lua/settings/options.lua` contains editor options and option-related autocmds.
- `lua/keymaps/` contains global mappings.
- `lua/plugins/specs.lua` is the central lazy.nvim plugin registry.
- `lua/plugins/<name>.lua` contains setup for a plugin with non-trivial configuration.
- `after/ftplugin/` contains filetype-specific settings loaded by Neovim.

## Adding a plugin

Add its lazy.nvim declaration to `lua/plugins/specs.lua`. If setup takes more than a few lines, put it in `lua/plugins/<name>.lua` and call that module from the spec's `config` function.

## Language servers

- Server inventory and Mason integration: `lua/plugins/lsp.lua`
- Shared buffer-local LSP mappings: `lua/plugins/lsp-keymaps.lua`
- Scala/Metals-specific setup: `lua/plugins/metals.lua`

The custom gopls wrapper used for Nebo checkouts remains configured in `lua/plugins/lsp.lua`.

## Validation

For a quick startup check:

```sh
nvim --headless -i NONE '+lua vim.defer_fn(function() print("STARTUP_OK") vim.cmd("qa") end, 1000)'
```

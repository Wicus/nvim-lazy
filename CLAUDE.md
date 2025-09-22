# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Code Formatting and Linting

- **Stylua**: Run `stylua .` to format Lua code according to the project's style guide (2-space indentation, 120 column width)
- **Configuration**: Style rules are defined in `stylua.toml`

## Project Architecture

This is a **LazyVim** configuration - a Neovim distribution built on top of the Lazy.nvim plugin manager. The architecture follows LazyVim's modular approach:

### Core Structure
- `init.lua`: Entry point that bootstraps the entire configuration by requiring `config.lazy`
- `lua/config/`: Core configuration files that set up the foundation
  - `lazy.lua`: Initializes Lazy.nvim and imports LazyVim + custom plugins
  - `options.lua`: Vim options and global settings
  - `keymaps.lua`: Custom key mappings and bindings
  - `autocmds.lua`: Automatic commands and event handlers
- `lua/plugins/`: Individual plugin configurations (one file per plugin/feature)

### Plugin Management
- Uses **Lazy.nvim** for plugin management
- LazyVim core is imported via `{ "LazyVim/LazyVim", import = "lazyvim.plugins" }`
- Custom plugins are imported via `{ import = "plugins" }`
- `lazy-lock.json`: Lock file for reproducible plugin versions
- `lazyvim.json`: LazyVim extras configuration and version tracking

### Configuration Philosophy
- **Plugin-per-file**: Each plugin gets its own configuration file in `lua/plugins/`
- **Override pattern**: Files in `lua/plugins/` override or extend LazyVim defaults
- **Modular**: Easy to enable/disable plugins by setting `enabled = false`
- **LazyVim extras**: Pre-configured plugin bundles enabled via `lazyvim.json`

### Key Configuration Details
- **Colorscheme**: Uses Catppuccin theme (configured in `lua/plugins/init.lua`)
- **Indentation**: 4-space tabs (set in `options.lua`)
- **Autoformat**: Disabled globally (`vim.g.autoformat = false`)
- **Backup files**: Enabled with custom directory (`~/nvim-lazy-backup-folder`)
- **Clipboard**: Not synced with system by default
- **Color column**: Set to 160 characters

### Enabled LazyVim Extras
- AI: Copilot and Copilot Chat
- Coding: Yanky (clipboard management)
- DAP: Core debugging + Neovim Lua debugging
- Editor: Harpoon2, Neo-tree
- Languages: JSON, Markdown, Python, SQL, TypeScript, Zig
- VSCode integration

### Custom Plugins and Overrides
Notable customizations in the plugin directory:
- Disabled: `bufferline.nvim`, `mini.pairs`, `render-markdown.nvim`
- Added: `vim-surround`, `vim-sleuth`
- Blink.cmp for completion
- Custom keymaps for Rider and VSCode integration
- Database tools (vim-dadbod)
- File navigation (Oil, Neo-tree)

### Development Workflow
When modifying this configuration:
1. Plugin configurations go in `lua/plugins/[plugin-name].lua`
2. Global options go in `lua/config/options.lua`
3. Key mappings go in `lua/config/keymaps.lua`
4. Run `stylua .` before committing changes
5. LazyVim will auto-update `lazy-lock.json` when plugins change
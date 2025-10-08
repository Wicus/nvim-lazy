# Repository Guidelines

## Project Structure & Module Organization
Configuration lives in `init.lua`, which bootstraps LazyVim and loads everything under `lua/`. Reusable settings ship from `lua/config`, while plugin specifications stay in `lua/plugins`. Filetype-specific overrides belong in `after/ftplugin`. Sync state is recorded in `lazy-lock.json`, and `lazyvim.json` tracks preset options. Keep assets such as snippets or templates alongside the module that consumes them to minimise path confusion.

## Build, Test, and Development Commands
Run `nvim --headless "+Lazy sync" +qa` after adding or updating plugins; it installs pinned versions from `lazy-lock.json`. Use `nvim --headless "+Lazy check" +qa` to confirm plugin health and detect missing dependencies. Reload the config during local iteration with `:Lazy load` inside Neovim, or restart Neovim to validate startup behaviour. Format changes before review with `stylua lua` to match the repository’s Lua style.

## Coding Style & Naming Conventions
Lua follows two-space indentation and camelCase for locals, while modules exported from `lua/config` or `lua/plugins` should use snake_case filenames to align with LazyVim’s loader. Keep configuration tables compact; prefer inline functions for simple mappings and wrap multi-line logic in dedicated helpers under `lua/config`. Run `stylua` before committing—its settings are defined in `stylua.toml`, so avoid custom overrides.

## Testing Guidelines
Automated tests are not present; rely on headless Neovim sessions to exercise the configuration. For runtime validation, execute `nvim --headless "+checkhealth" +qa` and address reported issues. When introducing plugin-specific behaviour, add a temporary minimal init under `lua/config/examples/` (gitignored) to reproduce edge cases without disturbing the main config, and document manual steps in the pull request.

## Commit & Pull Request Guidelines
Existing history shows short imperative messages (`disable marksman`) and optional type prefixes (`chore:`, `refactor(scope):`). Follow that pattern: begin with a lowercase verb, and include a scope when touching a specific plugin or subsystem. Limit PRs to focused changes, provide a concise summary, list manual validation steps (commands run, health checks), and link related issues. Screenshots or terminal recordings help reviewers confirm UI-facing tweaks quickly.

## Security & Configuration Tips
Guard secrets by keeping them in user-level environment variables—never commit API keys or tokens. When configuring external tools (e.g., LSP binaries), prefer path detection via `vim.fn.exepath` or LazyVim’s `util.get_root()` helpers to avoid hard-coded machine paths. Document any machine-specific requirements in your PR so other contributors can replicate the setup safely.

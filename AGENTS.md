# Repository Guidelines

## Project Structure & Module Organization
`init.lua` bootstraps LazyVim and pulls modules from `lua/`. Shared settings live in `lua/config`, plugin specs in `lua/plugins`, and filetype tweaks in `after/ftplugin`. State files `lazy-lock.json` and `lazyvim.json` pin plugin versions and preset options. Keep supporting assets—snippets, templates, helper scripts—next to the module that consumes them, and use `lua/config/examples/` (gitignored) for temporary reproductions.

## Build, Test, and Development Commands
Run `nvim --headless "+Lazy sync" +qa` whenever plugins change to install the versions tracked in `lazy-lock.json`. Follow with `nvim --headless "+Lazy check" +qa` to surface missing binaries or misconfigurations. Use `nvim --headless "+checkhealth" +qa` before submitting changes to confirm runtime health. Reload individual modules during development with `:Lazy load <plugin>` or restart Neovim as needed. Format Lua code via `stylua lua` to honour the repo’s style.

## Coding Style & Naming Conventions
Lua files use two-space indentation and concise tables. Prefer camelCase for local variables, while modules exported from `lua/config` or `lua/plugins` should use snake_case filenames so LazyVim can locate them. Inline simple callbacks directly in configuration tables; promote multi-step logic into helper functions under `lua/config`. Avoid trailing whitespace and run `stylua` prior to opening a PR.

## Testing Guidelines
No automated suite exists; rely on targeted headless runs. Exercise startup paths with `nvim --headless "+Lazy sync" +qa` followed by `+Lazy check`. Validate runtime behaviours with `nvim --headless "+checkhealth" +qa` and by loading affected buffers manually. For complex plugin changes, craft a minimal reproduction in `lua/config/examples/` and document manual steps in the PR description.

## Commit & Pull Request Guidelines
Commits follow short, imperative messages such as `disable marksman` and may include scope prefixes (`chore:`, `refactor(scope):`). Group related adjustments and keep diffs focused. PRs should summarise intent, list manual validation steps (commands run, health checks), link any issues, and attach screenshots or recordings for UI-facing tweaks. Mention outstanding follow-up work so reviewers can track it.

## Security & Configuration Tips
Store tokens and API keys in user-level environment variables; never commit secrets. Detect external tool paths dynamically via helpers like `vim.fn.exepath` or LazyVim util functions instead of hard-coding locations. Call out machine-specific requirements in the PR to keep other contributors unblocked.

local ui = require("utils.ui")

local function resize(win, dim, amount)
  local edgebar = win.view.edgebar
  local shared_edge = (dim == "width" and edgebar.vertical) or (dim == "height" and not edgebar.vertical)
  if not shared_edge then
    win:resize(dim, amount)
    return
  end

  -- Width is shared by all windows in a left/right edgebar, and height is
  -- shared by all windows in a top/bottom edgebar. Resize all visible siblings;
  -- otherwise a second Neo-tree pane can keep the whole edgebar at its old size.
  for _, sibling in ipairs(edgebar.wins) do
    if sibling.visible then
      local var = "edgy_" .. dim
      vim.w[sibling.win][var] = math.max(1, (vim.w[sibling.win][var] or sibling[dim]) + amount)
    end
  end
  require("edgy.layout").update()
end

return {
  "folke/edgy.nvim",
  keys = {
    { "<leader>e", function() require("edgy").toggle("left") end, desc = "Toggle left edgebar" },
  },
  opts = function(_, opts)
    opts.options = opts.options or {}
    -- Edgy's edgebar size is the minimum width. Keep the minimum small so
    -- Neo-tree can be shrunk, while setting Neo-tree's initial width below.
    opts.options.left = vim.tbl_extend("force", opts.options.left or {}, { size = 20 })

    -- Drop Normal:EdgyNormal — it remaps Normal in focused edgy windows,
    -- making neo-tree look dark when focused while NormalNC keeps base on blur.
    opts.wo = opts.wo or {}
    opts.wo.winhighlight = "WinBar:EdgyWinBar,WinBarNC:EdgyWinBarNC"

    opts.animate = opts.animate or {}
    opts.animate.enabled = false

    opts.keys = opts.keys or {}
    for key, spec in pairs({
      ["<c-Left>"] = { "width", -2 },
      ["<c-Right>"] = { "width", 2 },
      ["<c-Up>"] = { "height", 2 },
      ["<c-Down>"] = { "height", -2 },
      ["<c-w><lt>"] = { "width", -2 },
      ["<c-w>>"] = { "width", 2 },
      ["<c-w>+"] = { "height", 2 },
      ["<c-w>-"] = { "height", -2 },
    }) do
      opts.keys[key] = function(win) resize(win, spec[1], spec[2]) end
    end

    -- LazyVim's edgy extra pins a separate left view per neo-tree source
    -- (filesystem, git_status, ...), stacking them oddly. Collapse to ONE left
    -- view; neo-tree swaps sources inside that single window (see <leader>ge).
    local left = {}
    local neotree_added = false
    for _, view in ipairs(opts.left or {}) do
      if type(view) == "table" and view.ft == "neo-tree" then
        if not neotree_added then
          neotree_added = true
          left[#left + 1] = {
            title = "Explorer",
            ft = "neo-tree",
            size = { width = ui.sidebar_width },
            open = function()
              -- Keep focus in Neo-tree when expanding the Edgy view with vertical
              -- window navigation (for example <C-j>/<C-k>).
              require("neo-tree.command").execute({
                source = "filesystem",
                action = "focus",
                position = "left",
                dir = LazyVim.root(),
              })
              vim.defer_fn(function()
                local ok, manager = pcall(require, "neo-tree.sources.manager")
                local state = ok and manager.get_state("filesystem")
                if state and state.winid and vim.api.nvim_win_is_valid(state.winid) then
                  pcall(vim.api.nvim_set_current_win, state.winid)
                end
              end, 50)
            end,
          }
        end
      else
        left[#left + 1] = view
      end
    end
    opts.left = left

    opts.bottom = opts.bottom or {}
    table.insert(opts.bottom, {
      ft = "sidekick_terminal",
      size = { height = 0.4 },
      title = "Sidekick: %{w:sidekick_cli.name}",
      filter = function(_buf, win) return vim.w[win].sidekick_cli ~= nil end,
    })
  end,
}

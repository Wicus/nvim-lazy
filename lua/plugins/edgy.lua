local function neotree_width()
  return math.max(20, math.min(81, math.floor(vim.o.columns * 0.25)))
end

return {
  "folke/edgy.nvim",
  keys = {
    { "<leader>e", function() require("edgy").toggle("left") end, desc = "Toggle left edgebar" },
  },
  opts = function(_, opts)
    opts.options = opts.options or {}
    opts.options.left = { size = neotree_width() }

    opts.animate = opts.animate or {}
    opts.animate.enabled = false

    for _, view in ipairs(opts.left or {}) do
      if type(view) == "table" and view.title and view.title:lower():find("git") then
        view.size = { height = 0.33 }
      end
    end

    opts.bottom = opts.bottom or {}
    table.insert(opts.bottom, {
      ft = "sidekick_terminal",
      size = { height = 0.4 },
      title = "Sidekick: %{w:sidekick_cli.name}",
      filter = function(_buf, win)
        return vim.w[win].sidekick_cli ~= nil
      end,
    })

    table.insert(opts.bottom, {
      ft = "snacks_terminal",
      size = { height = 0.4 },
      filter = function(_buf, win)
        return vim.api.nvim_win_get_config(win).relative == ""
      end,
    })
  end,
}

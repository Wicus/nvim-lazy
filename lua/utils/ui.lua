local M = {}

--- Fraction of the editor width clamped between min and max columns.
function M.clamped_width(frac, min, max) return math.max(min, math.min(max, math.floor(vim.o.columns * frac))) end

--- Shared width for left sidebars (Neo-tree, DAP UI): 25% of columns, clamped 20-81.
function M.sidebar_width() return M.clamped_width(0.25, 20, 81) end

--- Keep windows of the given filetype at width_fn() across terminal resizes.
function M.autoresize_width(ft, width_fn)
  vim.api.nvim_create_autocmd("VimResized", {
    group = vim.api.nvim_create_augroup("autoresize_width_" .. ft, { clear = true }),
    callback = function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == ft then
          vim.api.nvim_win_set_width(win, width_fn())
        end
      end
    end,
    desc = "Resize " .. ft .. " windows on terminal resize",
  })
end

return M

return {
  "gbprod/yanky.nvim",
  opts = {
    system_clipboard = {
      sync_with_ring = true,
    },
    highlight = {
      on_put = false,
      timer = 75,
    },
  },
  keys = {
    { "p", '"_d<Plug>(YankyPutAfter)', mode = { "x" }, desc = "Put Text After Cursor wo/ copying" },
    { "P", '"_d<Plug>(YankyPutBefore)', mode = { "x" }, desc = "Put Text Before Cursor wo/ copying" },
  },
}

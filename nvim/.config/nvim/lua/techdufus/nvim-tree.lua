-- empty setup using defaults
require("nvim-tree").setup {
  open_on_setup = true,
  view = {
    side = "left",
    width = 30,
  },
  renderer = {
    icons = {
      glyphs = {
        folder = {
          arrow_open = "",
          arrow_closed = "",
        },
    },
},
},
}

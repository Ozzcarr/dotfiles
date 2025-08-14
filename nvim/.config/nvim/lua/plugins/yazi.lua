return {
  "mikavilpas/yazi.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    {
      "<leader>y",
      mode = { "n", "v" },
      "<cmd>Yazi<cr>",
      desc = "Explorer Yazi (Root Dir)",
    },
    {
      "<leader>Y",
      mode = { "n", "v" },
      "<cmd>Yazi cwd<cr>",
      desc = "Explorer Yazi (cwd)",
    },
  },
}

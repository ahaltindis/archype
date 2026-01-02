return {
  { "ellisonleao/gruvbox.nvim" },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
      icons = {
        diagnostics = {
          -- I find fancy icons very distractive.
          Error = "e",
          Warn = "w",
          Hint = "h",
          Info = "i",
        },
      },
    },
  },
  {
    "snacks.nvim",
    opts = {
      picker = {
        icons = {
          diagnostics = {
            -- Match picker (explorer) icons with the editor icons.
            Error = "e",
            Warn = "w",
            Hint = "h",
            Info = "i",
          },
        },
      },
      scroll = {
        enabled = false,
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("ibl").setup({
        indent = {
          -- this helps to disable indent for non active scopes
          char = "",
        },
        scope = {
          -- Scope based indention handled by snacks indent
          enabled = false,
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        -- disable in-line diagnostics as they are very distractive.
        virtual_text = false,
      },
    },
  },
  -- disable trouble
  { "folke/trouble.nvim", enabled = false },
  { "folke/noice.nvim", enabled = false },
}

vim.pack.add({
    {src = 'https://github.com/Saghen/blink.cmp', version="v1"},
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/folke/tokyonight.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/mfussenegger/nvim-jdtls",
})
vim.pack.add({
  "https://github.com/ellisonleao/gruvbox.nvim",
})
vim.pack.add({
    "https://github.com/maxmx03/solarized.nvim"
})
require("gruvbox").setup({
  contrast = "hard",
})

-- vim.o.background = "dark"
vim.cmd("colorscheme gruvbox")
-- vim.cmd("colorscheme solarized")
-- vim.cmd.colorscheme("tokyonight-night")

require('nvim-treesitter.config').setup({
  ensure_installed = { "lua", "vim", "vimdoc", "java", "python",
                       "javascript", "typescript", "tsx", "html",
                       "css", "json", "bash", "markdown", "tex", "c" },
  auto_install = true,
  highlight = { enable = true },
  indent    = { enable = true },
})

require('mason').setup()

require('blink.cmp').setup({
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = { preset = 'default' },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono'
    },
    -- (Default) Only show the documentation popup when manually triggered
    completion = { documentation = { auto_show = true } },
    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
    -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
    -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
    --
    -- See the fuzzy documentation for more information
    fuzzy = { implementation = "prefer_rust_with_warning" }
})
vim.lsp.enable('lua_ls')
vim.lsp.enable('clangd')
vim.lsp.enable('pyright')
vim.lsp.enable('ruff')

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'java',
    callback = function(args)
        require('plugins.jdtls_setup').setup()
    end
})

require("telescope").setup({
    pickers = {
        find_files = {
            hidden = true,
        },
    }
})
local builtin = require('telescope.builtin')

-- Keybinds
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })

require("gitsigns").setup({
    signs = {
      add          = { text = "+" },
      change       = { text = "~" },
      delete       = { text = "-" },
      topdelete    = { text = "-" },
      changedelete = { text = "~" },
}
})

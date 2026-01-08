-- Basic
vim.g.mapleader = " "
vim.o.wrap = false

-- Indentation
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.smartindent = true

-- Search
vim.o.hlsearch = false
vim.o.incsearch = true

-- Visual
vim.o.scrolloff = 10
vim.o.signcolumn = "yes"
vim.o.syntax = on
vim.o.colorcolumn = "80"
vim.o.showtabline = 0
vim.opt.laststatus = 0

vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "E",
            [vim.diagnostic.severity.WARN] = "W",
            [vim.diagnostic.severity.INFO] = "I",
            [vim.diagnostic.severity.HINT] = "H",
        },
    },
    virtual_text = true,
})

-- LSP
vim.lsp.enable('lua_ls')
vim.lsp.enable('gopls')
vim.lsp.enable('html')
vim.lsp.enable('ts_ls')
vim.lsp.enable('easy-dotnet')
vim.lsp.enable('bashls')
vim.lsp.enable('astro-language-server')
vim.lsp.enable('prettier')
vim.lsp.enable('markdown-oxide')
vim.lsp.enable('nextls')
vim.lsp.enable('rust-analyzer')

-- File handling
vim.o.backup = false
vim.o.swapfile = false
vim.o.undofile = true
vim.o.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.o.updatetime = 50
vim.o.filetype = "on"

-- Autocommands
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.shiftwidth = 2
    end,
})

-- Packages
vim.pack.add({
    -- colorscheme
    { src = "https://github.com/sainnhe/sonokai" },
    -- Terminal within Vim
    { src = "https://github.com/akinsho/toggleterm.nvim" },
    -- Parser
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    -- Fuzzy finder
    { src = "https://github.com/nvim-telescope/telescope.nvim" },
    -- LSP
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
    { src = "https://github.com/j-hui/fidget.nvim" },
    -- Autocomplete
    { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
    { src = "https://github.com/hrsh7th/cmp-buffer" },
    { src = "https://github.com/hrsh7th/cmp-path" },
    { src = "https://github.com/hrsh7th/nvim-cmp" },

    -- indent guide
    { src = "https://github.com/lukas-reineke/indent-blankline.nvim" },

    -- Something???
    { src = "https://github.com/nvim-lua/plenary.nvim" },

    -- C# support
    { src = "https://github.com/GustavEikaas/easy-dotnet.nvim" }
})

-- Colorscheme
vim.cmd.colorscheme("sonokai")

-- Transparent background support
vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })

-- C#
require("easy-dotnet").setup()

require("fidget").setup()
require("mason").setup()
require("mason-lspconfig").setup()
local cmp = require("cmp")
local treesitter = require("nvim-treesitter.configs")
local _, toggleterm = pcall(require, "toggleterm")

-- Keymaps
-- Telescope
local telescope_builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", function()
    require("telescope.builtin").find_files({
        path_display = { "filename_first" },
        follow = true,
    })
end)
vim.keymap.set("n", "<leader>fa", function()
    telescope_builtin.live_grep({
        path_display = { "filename_first" },
        follow = true,
    })
end)

-- LSP
vim.keymap.set("n", "grd", vim.lsp.buf.definition, opts) -- go to definition
vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format)    -- format code using LSP
vim.keymap.set("n", "K", function()                      -- lsp hover
    vim.lsp.buf.hover({
        border = "rounded",
    })
end)
vim.keymap.set("n", "gdi", vim.diagnostic.open_float, opts) -- diagnostics
vim.keymap.set("n", "gca", vim.lsp.buf.code_action, opts)   -- code actions
vim.keymap.set('n', "grr", function()
    telescope_builtin.lsp_references();
end)
vim.keymap.set("n", "grn", vim.lsp.buf.rename, opts)           -- rename
vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts) -- signature help

-- General
vim.keymap.set("n", "<leader>ex", vim.cmd.Ex)                                            -- open file explorer

vim.keymap.set("n", "<C-d>", "<C-d>zz")                                                  -- scroll down
vim.keymap.set("n", "<C-u>", "<C-u>zz")                                                  -- scroll down
vim.keymap.set("n", "n", "nzzzv")                                                        -- search next and center
vim.keymap.set("n", "N", "Nzzzv")                                                        -- search previous and center
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])                                       -- copy (line) to system clipboard
vim.keymap.set("n", "Q", "<nop>")                                                        -- disable Q
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]) -- search and replace current word
vim.keymap.set("v", "<", "<gv")                                                          -- stay in visual mode when indenting left
vim.keymap.set("v", ">", ">gv")                                                          -- stay in visual mode when indenting right

-- Plugin config
toggleterm.setup({
    size = 20,
    open_mapping = [[<c-\>]],
    hide_numbers = true,
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = true,
    persist_size = true,
    direction = "float",
    close_on_exit = true,
    shell = vim.o.shell,
    float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
            border = "Normal",
            background = "Normal",
        },
    },
})

treesitter.setup({
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
})

-- indenting
local indentGuide = require("ibl")
indentGuide.setup();

cmp.setup({
    snippet = {
        expand = function(args)
            vim.snippet.expand(args.body)
        end,
    },
    window = {
        completion = {
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
        },
        documentation = {
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
        },
    },
    mapping = cmp.mapping.preset.insert({
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end, { 'i', 's' }),

        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end, { 'i', 's' }),

        ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
    }, {
        { name = "buffer" },
    })
})

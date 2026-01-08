vim.g.mapleader = " "

vim.o.wrap = false

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.smartindent = true

vim.o.hlsearch = false
vim.o.incsearch = true

vim.o.scrolloff = 10
vim.o.signcolumn = "yes"
vim.o.colorcolumn = "80"
vim.o.showtabline = 0
vim.o.laststatus = 0

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

vim.o.backup = false
vim.o.swapfile = false
vim.o.undofile = true
vim.o.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.o.updatetime = 50

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.shiftwidth = 2
    end,
})

vim.pack.add({
    { src = "https://github.com/sainnhe/sonokai" },
    { src = "https://github.com/akinsho/toggleterm.nvim" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/nvim-telescope/telescope.nvim" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/williamboman/mason.nvim" },
    { src = "https://github.com/williamboman/mason-lspconfig.nvim" },
    { src = "https://github.com/j-hui/fidget.nvim" },
    { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
    { src = "https://github.com/hrsh7th/cmp-buffer" },
    { src = "https://github.com/hrsh7th/cmp-path" },
    { src = "https://github.com/hrsh7th/nvim-cmp" },
    { src = "https://github.com/lukas-reineke/indent-blankline.nvim" },
    { src = "https://github.com/GustavEikaas/easy-dotnet.nvim" },
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
})

vim.lsp.enable("lua_ls")
vim.lsp.enable("ts_ls")
vim.lsp.enable("html")
vim.lsp.enable("cssls")

require("fidget").setup()
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "ts_ls", "html", "cssls" },
    automatic_installation = true,
})

require("easy-dotnet").setup()

require("nvim-treesitter.configs").setup({
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
})

require("ibl").setup()

require("gitsigns").setup({
    signs = {
        add          = { text = "+" },
        change       = { text = "~" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
    },
    current_line_blame = false,
})

require("toggleterm").setup({
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

local completion = require("cmp")
completion.setup({
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
    mapping = completion.mapping.preset.insert({
        ["<Tab>"] = completion.mapping(function(fallback)
            if completion.visible() then
                completion.select_next_item()
            else
                fallback()
            end
        end, { "i", "s" }),

        ["<S-Tab>"] = completion.mapping(function(fallback)
            if completion.visible() then
                completion.select_prev_item()
            else
                fallback()
            end
        end, { "i", "s" }),

        ["<CR>"] = completion.mapping.confirm({ select = true }),
    }),
    sources = completion.config.sources({
        { name = "nvim_lsp" },
    }, {
        { name = "buffer" },
    })
})

local telescope = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", function()
    telescope.find_files({
        path_display = { "filename_first" },
        follow = true,
    })
end)

vim.keymap.set("n", "<leader>fa", function()
    telescope.live_grep({
        path_display = { "filename_first" },
        follow = true,
    })
end)

vim.keymap.set("n", "grd", vim.lsp.buf.definition)
vim.keymap.set("n", "grr", telescope.lsp_references)
vim.keymap.set("n", "grn", vim.lsp.buf.rename)
vim.keymap.set("n", "gca", vim.lsp.buf.code_action)
vim.keymap.set("n", "gdi", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format)
vim.keymap.set("n", "K", function()
    vim.lsp.buf.hover({
        border = "rounded",
    })
end)
vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help)

local gitsigns = require("gitsigns")

vim.keymap.set("n", "<leader>gp", gitsigns.preview_hunk)
vim.keymap.set("n", "<leader>gs", gitsigns.stage_hunk)
vim.keymap.set("n", "<leader>gu", gitsigns.undo_stage_hunk)
vim.keymap.set("n", "<leader>gr", gitsigns.reset_hunk)
vim.keymap.set("n", "<leader>gb", gitsigns.toggle_current_line_blame)
vim.keymap.set("n", "[c", gitsigns.prev_hunk)
vim.keymap.set("n", "]c", gitsigns.next_hunk)

vim.keymap.set("n", "<leader>ex", vim.cmd.Ex)
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

vim.cmd.colorscheme("sonokai")

vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })

local M = {}

local function install_plugins()
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
        { src = "https://github.com/tpope/vim-fugitive" },
        { src = "https://github.com/folke/which-key.nvim" },
        { src = "https://github.com/sphamba/smear-cursor.nvim" },
        { src = "https://github.com/nickjvandyke/opencode.nvim" },
    })
end

local function setup_treesitter()
    require("nvim-treesitter.configs").setup({
        sync_install = false,
        auto_install = true,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
    })
end

local function setup_gitsigns()
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
end

local function setup_which_key()
    require("which-key").setup({
        preset = "modern",
        delay = 400,
        win = {
            border = "rounded",
            padding = { 1, 2 },
        },
        layout = {
            align = "center",
        },
    })
end

local function setup_toggleterm()
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
end

local function setup_smear_cursor()
    require("smear_cursor").setup({
        smear_between_buffers = true,
        smear_between_neighbor_lines = true,
        scroll_buffer_space = true,
        smear_insert_mode = true,
        stiffness = 0.5,
        trailing_stiffness = 0.5,
        matrix_pixel_threshold = 0.5,
    })
end

local function setup_opencode()
    ---@type opencode.Opts
    vim.g.opencode_opts = {}

    vim.o.autoread = true -- Required for buffer reload on opencode edits
end

function M.setup()
    install_plugins()
    require("easy-dotnet").setup()
    setup_treesitter()
    require("ibl").setup()
    setup_gitsigns()
    setup_which_key()
    setup_toggleterm()
    setup_smear_cursor()
    setup_opencode()
end

return M

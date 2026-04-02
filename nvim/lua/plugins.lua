local M = {}

local function install_plugins()
    vim.pack.add({
        { src = "https://github.com/sitiom/nvim-numbertoggle" },
        { src = "https://github.com/sainnhe/sonokai" },
        { src = "https://github.com/akinsho/toggleterm.nvim" },
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
    })
end

local function trim(value)
    return vim.trim(value or "")
end

local function detect_easy_dotnet_server_version()
    if vim.fn.executable("dotnet") == 0 then
        return "2.0.0"
    end

    local result = vim.system({ "dotnet", "easydotnet", "-v" }, { text = true }):wait()
    if result.code ~= 0 then
        return "2.0.0"
    end

    local version = trim(result.stdout):match("%d+%.%d+%.%d+%.?%d*")
    return version or "2.0.0"
end

local function patch_easy_dotnet_client_version()
    local ok, client = pcall(require, "easy-dotnet.rpc.dotnet-client")
    if not ok or client._version_shim_applied then
        return
    end

    client._version_shim_applied = true

    local create_rpc_call = client.create_rpc_call

    --- Easy Dotnet currently hard-codes an older client version in initialize.
    --- Patch only the outgoing version field so the plugin's own initialize flow stays intact.
    client.create_rpc_call = function(opts)
        local request = opts and opts.params and opts.params.request
        local client_info = request and request.clientInfo

        if opts and opts.method == "initialize" and client_info and client_info.name == "EasyDotnet" then
            client_info.version = detect_easy_dotnet_server_version()
        end

        return create_rpc_call(opts)
    end
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

function M.setup()
    install_plugins()
    patch_easy_dotnet_client_version()
    require("easy-dotnet").setup()
    require("ibl").setup()
    setup_gitsigns()
    setup_which_key()
    setup_toggleterm()
    setup_smear_cursor()
end

return M

local M = {}

local function install_plugins()
    vim.pack.add({
        { src = "https://github.com/sitiom/nvim-numbertoggle" },
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

    --- Easy Dotnet currently hard-codes an older client version in initialize.
    --- Mirror the installed server version so startup keeps working until the plugin updates.
    client._initialize = function(self, cb, opts)
        opts = opts or {}

        coroutine.wrap(function()
            local use_visual_studio = require("easy-dotnet.options").options.server.use_visual_studio == true
            local debugger_path = require("easy-dotnet.options").options.debugger.bin_path
            local apply_value_converters = require("easy-dotnet.options").options.debugger.apply_value_converters
            local sln_file = require("easy-dotnet.parsers.sln-parse").find_solution_file()

            local debugger_options = {
                applyValueConverters = apply_value_converters,
                binaryPath = debugger_path,
            }

            return client.create_rpc_call({
                client = self._client,
                job = {
                    name = "Initializing...",
                    on_success_text = "Client initialized",
                    on_error_text = "Failed to initialize server",
                },
                cb = cb,
                on_crash = opts.on_crash,
                method = "initialize",
                params = {
                    request = {
                        clientInfo = {
                            name = "EasyDotnet",
                            version = detect_easy_dotnet_server_version(),
                        },
                        projectInfo = {
                            rootDir = vim.fs.normalize(vim.fn.getcwd()),
                            solutionFile = sln_file,
                        },
                        options = {
                            useVisualStudio = use_visual_studio,
                            debuggerOptions = debugger_options,
                        },
                    },
                },
            })()
        end)()
    end
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

function M.setup()
    install_plugins()
    patch_easy_dotnet_client_version()
    require("easy-dotnet").setup()
    setup_treesitter()
    require("ibl").setup()
    setup_gitsigns()
    setup_which_key()
    setup_toggleterm()
    setup_smear_cursor()
end

return M

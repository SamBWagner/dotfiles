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

local Terminal = require("toggleterm.terminal").Terminal
local lazygit = Terminal:new({
    cmd = "lazygit",
    direction = "float",
    float_opts = {
        border = "curved",
    },
    hidden = true,
})

vim.keymap.set("n", "<leader>gg", function()
    lazygit:toggle()
end, { desc = "Toggle Lazygit" })

local opencode = Terminal:new({
    cmd = "opencode",
    dir = vim.fn.getcwd(),
    direction = "float",
    float_opts = {
        border = "curved",
    },
    hidden = true,
})

vim.keymap.set("n", "<leader>ai", function()
    opencode:toggle()
end, { desc = "Toggle OpenCode" })

vim.keymap.set("n", "<leader>md", function()
    local file = vim.fn.expand("%:p")
    if vim.bo.filetype ~= "markdown" then
        vim.notify("Not a markdown file", vim.log.levels.WARN)
        return
    end
    local glow = Terminal:new({
        cmd = "glow " .. vim.fn.shellescape(file) .. " -p",
        direction = "float",
        float_opts = {
            border = "curved",
        },
        close_on_exit = true,
    })
    glow:toggle()
end, { desc = "Preview markdown with glow" })

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

local function get_visual_selection()
    vim.cmd('noau normal! "vy')
    local text = vim.fn.getreg("v")
    vim.fn.setreg("v", {})
    text = string.gsub(text, "\n", "")
    return text
end

vim.keymap.set("n", "<leader>ff", function()
    telescope.find_files({
        path_display = { "filename_first" },
        follow = true,
    })
end)

vim.keymap.set("v", "<leader>ff", function()
    local text = get_visual_selection()
    telescope.find_files({
        path_display = { "filename_first" },
        follow = true,
        default_text = text,
    })
end)

vim.keymap.set("n", "<leader>fa", function()
    telescope.live_grep({
        path_display = { "filename_first" },
        follow = true,
    })
end)

vim.keymap.set("v", "<leader>fa", function()
    local text = get_visual_selection()
    telescope.live_grep({
        path_display = { "filename_first" },
        follow = true,
        default_text = text,
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

-- Stateful git changed file navigation
local git_nav = {
    index = 0,
    files = {},
    last_refresh = 0,
}

local function get_git_changed_files()
    -- Get git root directory
    local root_handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
    if not root_handle then return {} end
    local git_root = root_handle:read("*l")
    root_handle:close()
    if not git_root or git_root == "" then return {} end

    local handle = io.popen("git status --porcelain 2>/dev/null")
    if not handle then return {} end
    local result = handle:read("*a")
    handle:close()

    local files = {}
    for line in result:gmatch("[^\r\n]+") do
        -- Extract filename (skip the 2-char status + space)
        local file = line:sub(4)
        -- Handle renamed files (old -> new)
        local arrow_pos = file:find(" -> ")
        if arrow_pos then
            file = file:sub(arrow_pos + 4)
        end
        if file ~= "" then
            -- Convert to absolute path using git root
            local abs_path = git_root .. "/" .. file
            table.insert(files, abs_path)
        end
    end
    return files
end

local function git_nav_next()
    local files = get_git_changed_files()
    if #files == 0 then
        vim.notify("No git changes found", vim.log.levels.INFO)
        return
    end

    -- Check if file list changed; if so, try to preserve position
    local files_changed = #files ~= #git_nav.files
    if not files_changed then
        for i, f in ipairs(files) do
            if git_nav.files[i] ~= f then
                files_changed = true
                break
            end
        end
    end

    if files_changed then
        -- Try to find current file in new list to maintain context
        local current_file = vim.fn.expand("%:p")
        local found_idx = 0
        for i, f in ipairs(files) do
            if f == current_file then
                found_idx = i
                break
            end
        end
        git_nav.files = files
        git_nav.index = found_idx
    end

    -- Move to next file
    git_nav.index = git_nav.index + 1
    if git_nav.index > #files then
        git_nav.index = 1
    end

    local target = files[git_nav.index]
    vim.cmd("edit " .. vim.fn.fnameescape(target))
    vim.notify(string.format("[%d/%d] %s", git_nav.index, #files, vim.fn.fnamemodify(target, ":~:.")), vim.log.levels.INFO)
end

local function git_nav_prev()
    local files = get_git_changed_files()
    if #files == 0 then
        vim.notify("No git changes found", vim.log.levels.INFO)
        return
    end

    local files_changed = #files ~= #git_nav.files
    if not files_changed then
        for i, f in ipairs(files) do
            if git_nav.files[i] ~= f then
                files_changed = true
                break
            end
        end
    end

    if files_changed then
        local current_file = vim.fn.expand("%:p")
        local found_idx = 0
        for i, f in ipairs(files) do
            if f == current_file then
                found_idx = i
                break
            end
        end
        git_nav.files = files
        git_nav.index = found_idx
    end

    git_nav.index = git_nav.index - 1
    if git_nav.index < 1 then
        git_nav.index = #files
    end

    local target = files[git_nav.index]
    vim.cmd("edit " .. vim.fn.fnameescape(target))
    vim.notify(string.format("[%d/%d] %s", git_nav.index, #files, vim.fn.fnamemodify(target, ":~:.")), vim.log.levels.INFO)
end

vim.keymap.set("n", "<leader>gn", git_nav_next, { desc = "Next git changed file" })
vim.keymap.set("n", "<leader>gp", git_nav_prev, { desc = "Previous git changed file" })
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

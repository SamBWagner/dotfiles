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

vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function(event)
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.spell = true
        vim.opt_local.spelllang = { "en_us" }
        vim.opt_local.colorcolumn = ""
        vim.opt_local.conceallevel = 2

        local function show_spell_suggestions()
            local word = vim.fn.spellbadword()[1]
            if not word or word == "" then
                return false
            end

            local suggestions = vim.fn.spellsuggest(word, 8)
            local message
            if #suggestions == 0 then
                message = string.format("No suggestions for \"%s\"", word)
            else
                message = string.format(
                    "Suggestions for \"%s\": %s",
                    word,
                    table.concat(suggestions, ", ")
                )
            end

            vim.notify(message, vim.log.levels.INFO, { title = "Spelling" })
            return true
        end

        local function hover_or_spell()
            if not show_spell_suggestions() then
                vim.lsp.buf.hover({ border = "rounded" })
            end
        end

        local function diagnostics_or_spell()
            if not show_spell_suggestions() then
                vim.diagnostic.open_float(nil, { border = "rounded" })
            end
        end

        vim.keymap.set("n", "K", hover_or_spell, { buffer = event.buf, desc = "Hover or spelling suggestions" })
        vim.keymap.set("n", "<C-k>", hover_or_spell, { buffer = event.buf, desc = "Hover or spelling suggestions" })
        vim.keymap.set(
            "n",
            "gdi",
            diagnostics_or_spell,
            { buffer = event.buf, desc = "Diagnostics or spelling suggestions" }
        )
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
    { src = "https://github.com/tpope/vim-fugitive" },
    { src = "https://github.com/folke/which-key.nvim" },
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

local TerminalClass = require("toggleterm.terminal").Terminal
local lazygit_terminal = TerminalClass:new({
    cmd = "lazygit",
    direction = "float",
    float_opts = {
        border = "curved",
    },
    hidden = true,
})

vim.keymap.set("n", "<leader>gg", function()
    lazygit_terminal:toggle()
end, { desc = "Toggle Lazygit" })

local opencode_terminal = TerminalClass:new({
    cmd = "opencode",
    dir = vim.fn.getcwd(),
    direction = "float",
    float_opts = {
        border = "curved",
    },
    hidden = true,
})

vim.keymap.set("n", "<leader>ai", function()
    opencode_terminal:toggle()
end, { desc = "Toggle OpenCode" })

vim.keymap.set("n", "<leader>md", function()
    local current_file_path = vim.fn.expand("%:p")
    if vim.bo.filetype ~= "markdown" then
        vim.notify("Not a markdown file", vim.log.levels.WARN)
        return
    end
    local glow_terminal = TerminalClass:new({
        cmd = "glow " .. vim.fn.shellescape(current_file_path) .. " -p",
        direction = "float",
        float_opts = {
            border = "curved",
        },
        close_on_exit = true,
    })
    glow_terminal:toggle()
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
    local selected_text = vim.fn.getreg("v")
    vim.fn.setreg("v", {})
    selected_text = string.gsub(selected_text, "\n", "")
    return selected_text
end

vim.keymap.set("n", "<leader>ff", function()
    telescope.find_files({
        path_display = { "filename_first" },
        follow = true,
    })
end, { desc = "Find files" })

vim.keymap.set("v", "<leader>ff", function()
    local selected_text = get_visual_selection()
    telescope.find_files({
        path_display = { "filename_first" },
        follow = true,
        default_text = selected_text,
    })
end, { desc = "Find files" })

vim.keymap.set("n", "<leader>fh", function()
    telescope.find_files({
        path_display = { "filename_first" },
        follow = true,
        hidden = true,
    })
end, { desc = "Find files (hidden included)" })

vim.keymap.set("v", "<leader>fh", function()
    local selected_text = get_visual_selection()
    telescope.find_files({
        path_display = { "filename_first" },
        follow = true,
        hidden = true,
        default_text = selected_text,
    })
end, { desc = "Find files (hidden included)" })

vim.keymap.set("n", "<leader>fa", function()
    telescope.live_grep({
        path_display = { "filename_first" },
        follow = true,
    })
end, { desc = "Find in all files (grep)" })

vim.keymap.set("v", "<leader>fa", function()
    local selected_text = get_visual_selection()
    telescope.live_grep({
        path_display = { "filename_first" },
        follow = true,
        default_text = selected_text,
    })
end, { desc = "Find in all files (grep)" })

vim.keymap.set("n", "grd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "grr", telescope.lsp_references, { desc = "Go to references" })
vim.keymap.set("n", "grn", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("n", "gca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "gdi", vim.diagnostic.open_float, { desc = "Show diagnostic" })
vim.keymap.set("n", "<leader>lf", function()
    if vim.bo.filetype == "cs" then
        local current_file_path = vim.fn.expand("%:p")
        vim.cmd("!" .. "dotnet csharpier " .. vim.fn.shellescape(current_file_path))
        vim.cmd("edit!")
    else
        vim.lsp.buf.format()
    end
end, { desc = "Format buffer" })
vim.keymap.set("n", "K", function()
    vim.lsp.buf.hover({
        border = "rounded",
    })
end, { desc = "Hover documentation" })

local gitsigns = require("gitsigns")

local changed_file_navigation = {
    current_index = 0,
    file_list = {},
}

local function get_git_changed_files()
    local git_root_process = io.popen("git rev-parse --show-toplevel 2>/dev/null")
    if not git_root_process then return {} end
    local git_root = git_root_process:read("*l")
    git_root_process:close()
    if not git_root or git_root == "" then return {} end

    local git_status_process = io.popen("git status --porcelain 2>/dev/null")
    if not git_status_process then return {} end
    local git_status_output = git_status_process:read("*a")
    git_status_process:close()

    local changed_files = {}
    for status_line in git_status_output:gmatch("[^\r\n]+") do
        local filename = status_line:sub(4)
        local rename_separator_position = filename:find(" -> ")
        if rename_separator_position then
            filename = filename:sub(rename_separator_position + 4)
        end
        if filename ~= "" then
            local absolute_path = git_root .. "/" .. filename
            table.insert(changed_files, absolute_path)
        end
    end
    return changed_files
end

local function has_file_list_changed(new_files, old_files)
    if #new_files ~= #old_files then return true end
    for index, filepath in ipairs(new_files) do
        if old_files[index] ~= filepath then return true end
    end
    return false
end

local function find_current_file_index(file_list)
    local current_file_path = vim.fn.expand("%:p")
    for index, filepath in ipairs(file_list) do
        if filepath == current_file_path then return index end
    end
    return 0
end

local function sync_navigation_state_if_needed(changed_files)
    if has_file_list_changed(changed_files, changed_file_navigation.file_list) then
        changed_file_navigation.file_list = changed_files
        changed_file_navigation.current_index = find_current_file_index(changed_files)
    end
end

local function navigate_to_changed_file(target_file_path, current_index, total_files)
    vim.cmd("edit " .. vim.fn.fnameescape(target_file_path))
    local display_path = vim.fn.fnamemodify(target_file_path, ":~:.")
    vim.notify(string.format("[%d/%d] %s", current_index, total_files, display_path), vim.log.levels.INFO)
end

local function navigate_to_next_changed_file()
    local changed_files = get_git_changed_files()
    if #changed_files == 0 then
        vim.notify("No git changes found", vim.log.levels.INFO)
        return
    end

    sync_navigation_state_if_needed(changed_files)

    changed_file_navigation.current_index = changed_file_navigation.current_index + 1
    if changed_file_navigation.current_index > #changed_files then
        changed_file_navigation.current_index = 1
    end

    navigate_to_changed_file(
        changed_files[changed_file_navigation.current_index],
        changed_file_navigation.current_index,
        #changed_files
    )
end

local function navigate_to_previous_changed_file()
    local changed_files = get_git_changed_files()
    if #changed_files == 0 then
        vim.notify("No git changes found", vim.log.levels.INFO)
        return
    end

    sync_navigation_state_if_needed(changed_files)

    changed_file_navigation.current_index = changed_file_navigation.current_index - 1
    if changed_file_navigation.current_index < 1 then
        changed_file_navigation.current_index = #changed_files
    end

    navigate_to_changed_file(
        changed_files[changed_file_navigation.current_index],
        changed_file_navigation.current_index,
        #changed_files
    )
end

vim.keymap.set("n", "<leader>gn", navigate_to_next_changed_file, { desc = "Next git changed file" })
vim.keymap.set("n", "<leader>gp", navigate_to_previous_changed_file, { desc = "Previous git changed file" })
vim.keymap.set("n", "<leader>gs", gitsigns.stage_hunk, { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>gu", gitsigns.undo_stage_hunk, { desc = "Undo stage hunk" })
vim.keymap.set("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Reset hunk" })
vim.keymap.set("n", "<leader>gb", gitsigns.toggle_current_line_blame, { desc = "Toggle line blame" })
vim.keymap.set("n", "[c", gitsigns.prev_hunk, { desc = "Previous hunk" })
vim.keymap.set("n", "]c", gitsigns.next_hunk, { desc = "Next hunk" })

vim.keymap.set("n", "<leader>gc", "<cmd>Git commit<CR>", { desc = "Git commit" })
vim.keymap.set("n", "<leader>gl", "<cmd>Git log --oneline<CR>", { desc = "Git log" })
vim.keymap.set("n", "<leader>gd", "<cmd>Gvdiffsplit<CR>", { desc = "Git diff current file" })
vim.keymap.set("n", "<leader>gh", function()
    vim.cmd("Git log --oneline --graph --decorate --all")
end, { desc = "Git history (graph)" })
vim.keymap.set("n", "<leader>gv", function()
    vim.cmd("Git")
end, { desc = "Git status" })

vim.api.nvim_create_autocmd("FileType", {
    pattern = "fugitive",
    callback = function()
        local buffer_only = { buffer = true }
        vim.keymap.set("n", "<Tab>", "=", buffer_only)
        vim.keymap.set("n", "dv", "<cmd>Gvdiffsplit<CR>", buffer_only)
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "git",
    callback = function()
        vim.keymap.set("n", "gd", function()
            local current_line = vim.api.nvim_get_current_line()
            local commit_hash = current_line:match("^%*?%s*([a-f0-9]+)")
            if commit_hash then
                vim.cmd("Git diff " .. commit_hash .. "^.." .. commit_hash)
            end
        end, { buffer = true, desc = "Diff this commit" })

        vim.keymap.set("n", "<CR>", function()
            local current_line = vim.api.nvim_get_current_line()
            local commit_hash = current_line:match("^%*?%s*([a-f0-9]+)")
            if commit_hash then
                vim.cmd("Git show " .. commit_hash)
            end
        end, { buffer = true, desc = "Show commit" })
    end,
})

vim.keymap.set("n", "<leader>ex", vim.cmd.Ex, { desc = "File explorer" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
vim.keymap.set("n", "Q", "<nop>", { desc = "Disable Ex mode" })
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Substitute word under cursor" })
vim.keymap.set("v", "<", "<gv", { desc = "Indent left (keep selection)" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right (keep selection)" })

vim.cmd.colorscheme("sonokai")

vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })

local whichkey = require("which-key")
whichkey.add({
    { "<leader>f", group = "Find" },
    { "<leader>g", group = "Git" },
    { "<leader>l", group = "LSP" },
    { "<leader>a", group = "AI" },
    { "<leader>m", group = "Markdown" },
    { "<leader>e", group = "Explorer" },

    { "<leader>gc", desc = "Commit" },
    { "<leader>gd", desc = "Diff current file" },
    { "<leader>gg", desc = "Lazygit" },
    { "<leader>gh", desc = "History (graph)" },
    { "<leader>gl", desc = "Log" },
    { "<leader>gv", desc = "Status" },
    { "<leader>gn", desc = "Next changed file" },
    { "<leader>gp", desc = "Previous changed file" },
    { "<leader>gs", desc = "Stage hunk" },
    { "<leader>gu", desc = "Undo stage hunk" },
    { "<leader>gr", desc = "Reset hunk" },
    { "<leader>gb", desc = "Toggle blame" },

    { "gr", group = "Go to/Refactor" },
    { "grd", desc = "Definition" },
    { "grr", desc = "References" },
    { "grn", desc = "Rename" },
    { "gc", group = "Code" },
    { "gca", desc = "Code action" },
    { "gd", group = "Diagnostics" },
    { "gdi", desc = "Show diagnostic" },

    { "[c", desc = "Previous hunk" },
    { "]c", desc = "Next hunk" },
})

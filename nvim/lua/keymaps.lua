local M = {}

local telescope = require("telescope.builtin")

local function get_visual_selection()
    vim.cmd('noau normal! "vy')
    local selected_text = vim.fn.getreg("v")
    vim.fn.setreg("v", {})
    selected_text = string.gsub(selected_text, "\n", "")
    return selected_text
end

local function setup_telescope_keymaps()
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
end

local function setup_lsp_keymaps()
    vim.keymap.set("n", "grd", vim.lsp.buf.definition, { desc = "Go to definition" })
    vim.keymap.set("n", "grr", telescope.lsp_references, { desc = "Go to references" })
    vim.keymap.set("n", "grn", vim.lsp.buf.rename, { desc = "Rename symbol" })
    vim.keymap.set("n", "gca", vim.lsp.buf.code_action, { desc = "Code action" })
    vim.keymap.set("n", "gdi", function() vim.diagnostic.open_float(nil, { border = "rounded" }) end, { desc = "Show diagnostic" })
    vim.keymap.set("n", "<leader>lf", function()
        if vim.bo.filetype == "cs" then
            local current_file_path = vim.fn.expand("%:p")
            vim.cmd("write")
            local output = vim.fn.system({ "csharpier", "format", current_file_path })
            if vim.v.shell_error ~= 0 then
                vim.notify("CSharpier error:\n" .. output, vim.log.levels.ERROR)
            else
                vim.cmd("edit!")
                vim.notify("Formatted with CSharpier", vim.log.levels.INFO)
            end
        elseif vim.bo.filetype == "markdown" then
            local current_file_path = vim.fn.expand("%:p")
            vim.cmd("write")
            local output = vim.fn.system({
                "prettier",
                "--write",
                "--prose-wrap", "always",
                "--print-width", "80",
                current_file_path,
            })
            if vim.v.shell_error ~= 0 then
                vim.notify("Prettier error:\n" .. output, vim.log.levels.ERROR)
            else
                vim.cmd("edit!")
                vim.notify("Formatted with Prettier", vim.log.levels.INFO)
            end
        else
            vim.lsp.buf.format()
        end
    end, { desc = "Format buffer" })
    vim.keymap.set("n", "K", function()
        vim.lsp.buf.hover({
            border = "rounded",
        })
    end, { desc = "Hover documentation" })
end

local function setup_terminal_keymaps()
    local TerminalClass = require("toggleterm.terminal").Terminal

    vim.keymap.set("n", "<leader>gg", function()
        vim.cmd("enew")
        local buf = vim.api.nvim_get_current_buf()
        vim.fn.termopen("lazygit", {
            on_exit = function()
                vim.schedule(function()
                    if vim.api.nvim_buf_is_valid(buf) then
                        vim.api.nvim_buf_delete(buf, { force = true })
                    end
                end)
            end
        })
        vim.cmd("startinsert")
    end, { desc = "Open Lazygit" })

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
end

local function setup_general_keymaps()
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
end

function M.setup()
    setup_telescope_keymaps()
    setup_lsp_keymaps()
    setup_terminal_keymaps()
    setup_general_keymaps()
end

return M

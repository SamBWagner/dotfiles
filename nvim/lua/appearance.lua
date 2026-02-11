local M = {}

local function setup_colorscheme()
    vim.cmd.colorscheme("sonokai")
end

local function setup_transparent_background()
    vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })
end

local function setup_which_key_labels()
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
end

function M.setup()
    setup_colorscheme()
    setup_transparent_background()
    setup_which_key_labels()
end

return M

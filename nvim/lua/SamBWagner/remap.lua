-- Set leader key
vim.g.mapleader = " "

-- Normal mode remaps
vim.keymap.set("n", "<C-m>", "<Esc>")
vim.keymap.set("n", "Q", "gq")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Visual mode remaps
vim.keymap.set("v", "<C-m>", "<Esc>")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- IDE-style commands (mapped to Telescope or placeholder actions)
vim.keymap.set("n", "<leader>rr", ":echo 'Run Action'<CR>")
vim.keymap.set("n", "<leader>rs", ":echo 'Stop Action'<CR>")
vim.keymap.set("n", "<leader>rd", ":echo 'Debug Action'<CR>")
vim.keymap.set("n", "<leader>rb", ":echo 'Rebuild Solution'<CR>")
vim.keymap.set("n", "<leader>lf", ":echo 'Format with CSharpier'<CR>")

-- LSP
vim.keymap.set("n", "<leader>ra", vim.lsp.buf.rename)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references)

-- Finding (Telescope mappings assumed)
local telescopeBuiltin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', telescopeBuiltin.find_files, { desc = 'Telescope: Find Files' })
vim.keymap.set('n', '<leader>fa', telescopeBuiltin.live_grep, { desc = 'Telescope: Live Grep' })
vim.keymap.set('n', '<leader>fb', telescopeBuiltin.buffers, { desc = 'Telescope: Buffers' })
vim.keymap.set('n', '<leader>fh', telescopeBuiltin.help_tags, { desc = 'Telescope: Help Tags' })

-- Debugging
vim.keymap.set("n", "<leader>bp", ":echo 'Toggle Breakpoint'<CR>")
vim.keymap.set("n", "<leader>cbp", ":echo 'Clear Breakpoints'<CR>")

-- Tests
vim.keymap.set("n", "<leader>tr", ":echo 'Run Current Test'<CR>")
vim.keymap.set("n", "<leader>tar", ":echo 'Run All Tests'<CR>")

-- Window Management
vim.keymap.set("n", "<leader>wh", ":echo 'Hide All Windows'<CR>")
vim.keymap.set("n", "<leader>we", ":echo 'Open Project Tool Window'<CR>")
vim.keymap.set("n", "<leader>wg", ":echo 'Open Commit Tool Window'<CR>")
vim.keymap.set("n", "<leader>wt", ":echo 'Open Unit Test Tool Window'<CR>")

-- Git
vim.keymap.set("n", "<leader>gb", ":Gitsigns blame_line<CR>") -- or ":Git blame"
vim.keymap.set("n", "<leader>gc", ":Telescope git_commits<CR>")

-- Theme
vim.keymap.set("n", "<leader>th", ":Telescope colorscheme<CR>")

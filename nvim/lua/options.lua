local M = {}

function M.setup()
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
end

return M

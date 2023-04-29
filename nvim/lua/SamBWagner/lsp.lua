local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(_, bufnr)
	lsp.default_keymaps({ buffer = bufnr })
end)

-- (Optional) Configure lua language server for neovim
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

lsp.format_on_save({
	servers = {
		['lua_ls'] = { 'lua' },
		['c_sharp_ls'] = { 'c_sharp' },
		['angularls'] = { 'angularls' },
	}
})

lsp.setup()

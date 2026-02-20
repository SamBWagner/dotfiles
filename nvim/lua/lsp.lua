local M = {}

local function enable_servers()
    vim.lsp.enable("lua_ls")
    vim.lsp.enable("ts_ls")
    vim.lsp.enable("html")
    vim.lsp.enable("cssls")
    vim.lsp.enable("bicep")
    vim.lsp.enable("yamlls")
    vim.lsp.enable("powershell_es")
end

local function setup_mason()
    require("mason").setup()
    require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "ts_ls", "html", "cssls", "bicep", "yamlls", "powershell_es" },
        automatic_installation = true,
    })
end

local function setup_yaml_schema()
    require("lspconfig").yamlls.setup({
        settings = {
            yaml = {
                schemas = {
                    ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                    ["https://json.schemastore.org/github-action.json"] = "/action.{yml,yaml}",
                },
            },
        },
    })
end

local function setup_completion()
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
end

function M.setup()
    enable_servers()
    require("fidget").setup()
    setup_mason()
    setup_yaml_schema()
    setup_completion()
end

return M

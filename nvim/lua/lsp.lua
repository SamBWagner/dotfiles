local M = {}

local servers = {
    "lua_ls",
    "ts_ls",
    "html",
    "cssls",
    "bicep",
    "yamlls",
    "powershell_es",
}

local function setup_server_configs()
    vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
    })

    vim.lsp.config("yamlls", {
        settings = {
            redhat = {
                telemetry = {
                    enabled = false,
                },
            },
            yaml = {
                format = {
                    enable = true,
                },
                schemas = {
                    ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                    ["https://json.schemastore.org/github-action.json"] = "/action.{yml,yaml}",
                },
            },
        },
    })
end

local function setup_mason()
    require("mason").setup()
    require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_enable = servers,
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
    require("fidget").setup()
    setup_server_configs()
    setup_mason()
    setup_completion()
end

return M

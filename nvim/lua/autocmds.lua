local M = {}

local function setup_js_ts_indent()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
        callback = function()
            vim.opt_local.tabstop = 2
            vim.opt_local.softtabstop = 2
            vim.opt_local.shiftwidth = 2
        end,
    })
end

local function setup_bicep_filetype()
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "*.bicep", "*.bicepparam" },
        callback = function()
            vim.bo.filetype = "bicep"
        end,
    })
end

local function setup_markdown_filetype()
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
end

function M.setup()
    setup_js_ts_indent()
    setup_bicep_filetype()
    setup_markdown_filetype()
end

return M

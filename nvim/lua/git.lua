local M = {}

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

local function setup_changed_file_keymaps()
    vim.keymap.set("n", "<leader>gn", navigate_to_next_changed_file, { desc = "Next git changed file" })
    vim.keymap.set("n", "<leader>gp", navigate_to_previous_changed_file, { desc = "Previous git changed file" })
end

local function setup_gitsigns_keymaps()
    local gitsigns = require("gitsigns")

    vim.keymap.set("n", "<leader>gs", gitsigns.stage_hunk, { desc = "Stage hunk" })
    vim.keymap.set("n", "<leader>gu", gitsigns.undo_stage_hunk, { desc = "Undo stage hunk" })
    vim.keymap.set("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Reset hunk" })
    vim.keymap.set("n", "<leader>gb", gitsigns.toggle_current_line_blame, { desc = "Toggle line blame" })
    vim.keymap.set("n", "[c", gitsigns.prev_hunk, { desc = "Previous hunk" })
    vim.keymap.set("n", "]c", gitsigns.next_hunk, { desc = "Next hunk" })
end

local function setup_fugitive_keymaps()
    vim.keymap.set("n", "<leader>gc", "<cmd>Git commit<CR>", { desc = "Git commit" })
    vim.keymap.set("n", "<leader>gl", "<cmd>Git log --oneline<CR>", { desc = "Git log" })
    vim.keymap.set("n", "<leader>gd", "<cmd>Gvdiffsplit<CR>", { desc = "Git diff current file" })
    vim.keymap.set("n", "<leader>gh", function()
        vim.cmd("Git log --oneline --graph --decorate --all")
    end, { desc = "Git history (graph)" })
    vim.keymap.set("n", "<leader>gv", function()
        vim.cmd("Git")
    end, { desc = "Git status" })
end

local function setup_fugitive_autocmds()
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
end

function M.setup()
    setup_changed_file_keymaps()
    setup_gitsigns_keymaps()
    setup_fugitive_keymaps()
    setup_fugitive_autocmds()
end

return M

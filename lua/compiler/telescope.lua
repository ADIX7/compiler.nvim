local M = {}

function M.show()
    -- If working directory is home, don't open telescope.
    if vim.loop.os_homedir() == vim.loop.cwd() then
        vim.notify("You must :cd your project dir first.\nHome is not allowed as working dir.", vim.log.levels.WARN, {
            title = "Compiler.nvim"
        })
        return
    end

    -- Get the active compilers
    local compilers = require("compiler.compiler").get_active_compilers()

    -- Dependencies
    local conf = require("telescope.config").values
    local actions = require "telescope.actions"
    local state = require "telescope.actions.state"
    local pickers = require "telescope.pickers"
    local finders = require "telescope.finders"

    -- RUN ACTION ON SELECTED
    -- ========================================================================

    --- On option selected → Run action depending of the language.
    local function on_option_selected(prompt_bufnr)
        actions.close(prompt_bufnr)          -- Close Telescope on selection
        local selection = state.get_selected_entry()
        if selection.value == "" then return end -- Ignore separators

        selection.value.handler(selection.value)

        if selection then
            vim.notify("Compiling " .. selection.value.title, vim.log.levels.INFO, {
                title = "Compiler.nvim"
            })
        end
    end

    -- SHOW TELESCOPE
    -- ========================================================================
    local function open_telescope()
        pickers
            .new({}, {
                prompt_title = "Compiler",
                results_title = "Options",
                finder = finders.new_table {
                    results = compilers,
                    entry_maker = function(entry)
                        return {
                            display = entry.title,
                            value = entry,
                            ordinal = entry.title,
                        }
                    end,
                },
                sorter = conf.generic_sorter(),
                attach_mappings = function(_, map)
                    map(
                        "i",
                        "<CR>",
                        function(prompt_bufnr) on_option_selected(prompt_bufnr) end
                    )
                    map(
                        "n",
                        "<CR>",
                        function(prompt_bufnr) on_option_selected(prompt_bufnr) end
                    )
                    return true
                end,
            })
            :find()
    end
    open_telescope() -- Entry point
end

return M

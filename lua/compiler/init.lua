local cmd = vim.api.nvim_create_user_command

local init_languages = function()
    local langs = {
        require("compiler.languages.csharp")
    }

    local compilers_module = require("compiler.compiler")
    compilers_module.compilers = langs
end

local M = {}

M.setup = function(opts)
    init_languages()

    cmd("CompilerOpen", function()
        require("compiler.telescope").show()
    end, { desc = "Open Compiler" })

    -- define the component used by the tasks
    require("overseer").register_alias("default_extended", {
        "on_complete_dispose",
        "default",
        "open_output",
    })
end

return M

local M = {}

M.compilers = {}

M.get_active_compilers = function()
    local path = vim.fn.getcwd()
    local results = {}
    for _, lang in ipairs(M.compilers) do
        local options = lang.get_options(path)
        if #options > 0 then
            for _, option in ipairs(options) do
                table.insert(results, option)
            end
        end
    end
    return results
end

return M

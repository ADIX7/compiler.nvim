local M = {
    title = "C#",
    extensions = { "cs" },
}

local function get_csproj_options(path, results)
    local csproj = vim.fn.glob(path .. "/**/*.csproj", true, true)

    for _, file in ipairs(csproj) do
        if file ~= "" then
            local file_display_name = vim.fn.fnamemodify(file, ":t")
            table.insert(results, {
                title = "Build " .. file_display_name,
                handler = M.handle_build,
                name = file_display_name,
                csproj = file,
            })

            table.insert(results, {
                title = "Clean " .. file_display_name,
                handler = M.handle_clean,
                name = file_display_name,
                csproj = file,
            })

            local file_contents = vim.fn.readfile(file)
            for _, line in ipairs(file_contents) do
                if string.find(line, "Microsoft.NET.Test.Sdk") then
                    table.insert(results, {
                        title = "Test " .. file_display_name,
                        handler = M.handle_test,
                        name = file_display_name,
                        csproj = file,
                    })
                    break
                end
            end
        end
    end
end

local function get_sln_options(path, results)
    local csproj = vim.fn.glob(path .. "/**/*.sln", true, true)

    for _, file in ipairs(csproj) do
        if file ~= "" then
            local file_display_name = vim.fn.fnamemodify(file, ":t")
            table.insert(results, {
                title = "Build " .. file_display_name .. " (sln)",
                handler = M.handle_build,
                name = file_display_name,
                csproj = file,
            })

            table.insert(results, {
                title = "Clean " .. file_display_name .. " (sln)",
                handler = M.handle_clean,
                name = file_display_name,
                csproj = file,
            })
        end
    end
end

M.get_options = function(path)
    local results = {}

    get_sln_options(path, results)
    get_csproj_options(path, results)

    return results
end

M.handle_build = function(selection)
    local overseer = require("overseer")

    local task = overseer.new_task({
        name = selection.title,
        strategy = {
            "orchestrator",
            tasks = {
                {
                    name = "Restore nuget packages → \"" .. selection.name .. "\"",
                    cmd = "dotnet restore " .. selection.csproj,
                    components = { "default_extended" }
                },
                {
                    name = "Build program → \"" .. selection.name .. "\"",
                    cmd = "dotnet build " .. selection.csproj,
                    components = { "default_extended" }
                },
            },
        },
    })
    task:start()
end

M.handle_clean = function(selection)
    local overseer = require("overseer")

    local task = overseer.new_task({
        name = selection.title,
        strategy = {
            "orchestrator",
            tasks = {
                {
                    name = "Build program → \"" .. selection.name .. "\"",
                    cmd = "dotnet clean " .. selection.csproj,
                    components = { "default_extended" }
                },
            },
        },
    })
    task:start()
end

M.handle_test = function(selection)
    local overseer = require("overseer")

    local task = overseer.new_task({
        name = selection.title,
        strategy = {
            "orchestrator",
            tasks = {
                {
                    name = "Test program → \"" .. selection.name .. "\"",
                    cmd = "dotnet test " .. selection.csproj,
                    components = { "default_extended" }
                },
            },
        },
    })
    task:start()
end

return M

local M = {}

-- Resolve from the buffer rather than changing :pwd. Git worktrees use a
-- .git file, so use vim.fs.root instead of assuming .git is a directory.
function M.directory(bufnr)
    bufnr = bufnr or 0
    if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == "" then
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name ~= "" and not name:match("^%a[%w+.-]*://") then
            local directory = vim.fs.dirname(name)
            -- New files can have parents which do not exist yet.
            while directory and vim.fn.isdirectory(directory) ~= 1 do
                local parent = vim.fs.dirname(directory)
                if parent == directory then
                    break
                end
                directory = parent
            end
            if directory and vim.fn.isdirectory(directory) == 1 then
                return directory
            end
        end
    end
    return vim.fn.getcwd()
end

function M.root(bufnr)
    local directory = M.directory(bufnr)
    return vim.fs.root(directory, ".git")
        or vim.fs.root(directory, {
            "package.json",
            "pyproject.toml",
            "go.work",
            "go.mod",
            "Cargo.toml",
            "pom.xml",
            "build.gradle",
            "build.gradle.kts",
            "CMakeLists.txt",
            "Makefile",
            ".project-root",
        })
        or vim.fn.getcwd()
end

return M

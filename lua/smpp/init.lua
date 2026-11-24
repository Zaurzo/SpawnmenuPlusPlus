-- Spawnmenu++
-- Zaurzo, 2026
---@realm client

SpawnmenuPP = {}

---@param dir string
function SpawnmenuPP:LoadDir(dir)
    dir = 'smpp/' .. dir .. '/'

    local files, folders = file.Find('lua/' .. dir .. '*', 'GAME')

    for _, file_name in ipairs(files) do
        include(dir .. file_name)
    end

    for _, folder in ipairs(folders) do
        include(dir .. folder .. 'init.lua')
    end
end

include('options.lua')

SpawnmenuPP:LoadDir('extensions')
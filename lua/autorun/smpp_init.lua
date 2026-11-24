-- Spawnmenu++
-- Zaurzo, 2026

SpawnmenuPP = {}

---@param dir string
function SpawnmenuPP:LoadDir(dir)
    dir = 'smpp/' .. dir .. '/'

    local files, folders = file.Find('lua/' .. dir .. '*', 'GAME')

    for _, file_name in ipairs(files) do
        local prefix = file_name:sub(1, 3)
        local path = dir .. file_name

        if prefix == 'sv_' and SERVER then
            include(path)
        elseif prefix == 'cl_' and CLIENT then
            include(path)
        else
            include(path)
        end
    end

    for _, folder in ipairs(folders) do
        if SERVER then
            include(dir .. folder .. '/init.lua')
        else
            include(dir .. folder .. '/cl_init.lua')
        end
    end
end

if CLIENT then
    include('smpp/cl_options.lua')
end

SpawnmenuPP:LoadDir('extensions')
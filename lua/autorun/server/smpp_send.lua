local function add_cs_recursive(folder)
    local files, dirs = file.Find('lua/' .. folder .. '/*', 'GAME')

    for _, file_name in ipairs(files) do
        AddCSLuaFile(folder .. '/' .. file_name)
    end

    for _, dir in ipairs(dirs) do
        add_cs_recursive(folder .. '/' .. dir)
    end
end

add_cs_recursive('smpp')
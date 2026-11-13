-- Spawnmenu++
-- Zaurzo, 2026
---@realm shared

if CLIENT then
    SpawnmenuPP = {}
    SpawnmenuPP.Options = {}

    function SpawnmenuPP:RegisterOption(id, name, build)
        self.Options[id] = {
            name = name,
            build = build
        }
    end

    file.CreateDir('smpp')

    hook.Add('AddToolMenuTabs', 'myHookClass', function()
	    spawnmenu.AddToolTab('Options', 'Options', 'icon16/cog.png')
        spawnmenu.AddToolCategory('Options', 'Spawnmenu++', 'Spawnmenu++')

        for id, option in pairs(SpawnmenuPP.Options) do
            spawnmenu.AddToolMenuOption(
                'Options', 
                'Spawnmenu++', 
                id, 
                option.name, 
                '',
                nil,
                option.build
            )
        end
    end)

    RunConsoleCommand('spawnmenu_reload')
end

local files, folders = file.Find('lua/smpp/addons/*', 'GAME')

local function load_file(file_name)
    file_name = 'smpp/addons/' .. file_name

    if SERVER then
        AddCSLuaFile(file_name)
    else
        include(file_name)
    end
end

for _, file_name in ipairs(files) do
    load_file(file_name)
end

for _, folder in ipairs(folders) do
    load_file(folder .. '/init.lua')
end
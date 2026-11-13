local function init()
    hook.Remove('PostGamemodeLoaded', 'SpawnmenuPlusPlus')

    if GAMEMODE.IsSandboxDerived then -- Sandbox family only
        include('smpp/init.lua')
    end
end

hook.Add('PostGamemodeLoaded', 'SpawnmenuPlusPlus', init)
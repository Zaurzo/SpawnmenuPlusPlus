util.AddNetworkString('smpp_spawn_as_npc')

net.Receive('smpp_spawn_as_npc', function(len, ply)
    local mdl = net.ReadString()
    local friendly = net.ReadBool()

    local data = {
        Class = 'npc_citizen',
        Model = mdl,
        Spawnable = true,
        Friendly = friendly
    }

    if not friendly then
        data.KeyValues = { Hostile = '1' }
    end

    list.Set('NPC', 'smpp_npc_' .. ply:EntIndex(), data)
end)
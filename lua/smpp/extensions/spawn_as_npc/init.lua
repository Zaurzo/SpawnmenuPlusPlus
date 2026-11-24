util.AddNetworkString('smpp_spawn_as_npc')

net.Receive('smpp_spawn_as_npc', function(len, ply)
    local mdl = net.ReadString()
    
    if not util.IsValidModel(mdl) then 
        return 
    end

    local data = {
        Class = 'npc_citizen',
        Model = mdl,
        Spawnable = true
    }

    local is_friendly = net.ReadBool()

    if not is_friendly then
        data.KeyValues = { Hostile = '1' }
    end

    list.Set('NPC', 'smpp_npc_' .. ply:EntIndex(), data)
end)

hook.Add('PlayerDisconnected', 'smpp_remove_npc_data', function(ply)
    list.RemoveEntry('NPC', 'smpp_npc_' .. ply:EntIndex())
end)
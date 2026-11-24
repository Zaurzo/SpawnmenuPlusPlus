local valve_biped_models = {}
local is_friendly = true

local function is_model_valve_biped(mdl)
    local is_biped = valve_biped_models[mdl]

    if is_biped ~= nil then
        return is_biped
    end

    local ent = ClientsideModel(mdl)

    if not IsValid(ent) then
        return false
    end

    ent:SetupBones()

    is_biped = ent:LookupBone('ValveBiped.Bip01_Pelvis') ~= nil
    valve_biped_models[mdl] = is_biped

    ent:Remove()

    return is_biped
end

---@return DMenuOption
local function create_option(label, menu, on_changed)
    local opt = menu:AddOption(label)

    opt:SetIsMenu(true)

    function opt:OnMouseReleased(key_code)
        DButton.OnMouseReleased(self, key_code)

        on_changed(self)
    end

    opt.Label = label

    return opt
end

local function set_npc(mdl, weapon)
    RunConsoleCommand('gmod_tool', 'creator')
    RunConsoleCommand('creator_type', '2')
    RunConsoleCommand('creator_name', 'smpp_npc_' .. LocalPlayer():EntIndex())
    RunConsoleCommand('creator_override', weapon or '')

    net.Start('smpp_spawn_as_npc')
    net.WriteString(mdl)
    net.WriteBool(is_friendly)
    net.SendToServer()
end

---@param menu DMenu
---@param icon SpawnIcon
hook.Add('SpawnmenuIconMenuOpen', 'smpp_spawn_as_npc', function(menu, icon, content_type)
    if content_type ~= 'model' then return end

    local mdl = icon:GetModelName():lower()
    if not is_model_valve_biped(mdl) then return end

    local menu2, option = menu:AddSubMenu('Spawn as NPC using Tool Gun')
    option:SetIcon('icon16/monkey.png')

    local options = {}

    local function on_changed(opt, state)
        is_friendly = opt.Label == 'Friendly'
        options[is_friendly and 2 or 1]:SetChecked(false)
        
        opt:SetChecked(true)

        set_npc(mdl)
    end 

    options[1] = create_option('Friendly', menu2, on_changed)
    options[2] = create_option('Hostile', menu2, on_changed)
    options[is_friendly and 1 or 2]:SetChecked(true)

    menu2:AddSpacer()

    menu2:AddOption('None', function()
        set_npc(mdl, '')
    end):SetIcon('icon16/cross.png')

    menu2:AddSpacer()

    local icons = list.GetForEdit('ContentCategoryIcons')
    local npc_weapons = list.GetForEdit('NPCUsableWeapons')

    for _, wep in pairs(npc_weapons) do
        local name = language.GetPhrase(wep.title or wep.class)
        local option_icon = icons[wep.category or ''] or 'icon16/gun.png'

        menu2:AddOption(name, function()
            set_npc(mdl, wep.class)
        end):SetIcon(option_icon)
    end
end)
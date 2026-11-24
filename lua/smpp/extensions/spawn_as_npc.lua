local valve_biped_models = {}

local required_bones = {
    'ValveBiped.Bip01_Pelvis',
    'ValveBiped.Bip01_Spine',
    'ValveBiped.Bip01_Head1',
    'ValveBiped.Bip01_R_Hand',
    'ValveBiped.Bip01_L_Hand',
}

local required_acts = {
    ACT_IDLE, 
    ACT_WALK, 
    ACT_RUN
}

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

local function set_npc(mdl, is_friendly, weapon)
    RunConsoleCommand('gmod_tool', 'creator')
    RunConsoleCommand('creator_type', '2')
    RunConsoleCommand('creator_name', 'smpp_npc')
    RunConsoleCommand('creator_override', weapon or '')

    net.Start('smpp_spawn_as_npc')
    net.WriteString(mdl)
    net.WriteBool(is_friendly)
    net.SendToServer()
end

---@param menu DMenu
---@param icon SpawnIcon
hook.Add('SpawnmenuIconMenuOpen', 'identifier', function(menu, icon, content_type)
    if content_type ~= 'model' then return end

    local mdl = icon:GetModelName():lower()
    if not is_model_valve_biped(mdl) then return end

    local menu2, option = menu:AddSubMenu('Spawn as NPC using Tool Gun')
    option:SetIcon('icon16/monkey.png')

    local options = {}

    local function on_changed(opt, state)
        local is_friendly = opt.Label == 'Friendly'

        if is_friendly then
            options[2]:SetChecked(false)
        else
            options[1]:SetChecked(false)
        end
        
        opt:SetChecked(true)

        set_npc(mdl, is_friendly)
    end 

    options[1] = create_option('Friendly', menu2, on_changed)
    options[2] = create_option('Hostile', menu2, on_changed)
    options[1]:SetChecked(true)

    menu2:AddSpacer()

    menu2:AddOption('None', function()
        set_npc(mdl, options[1]:GetChecked(), '')
    end):SetIcon('icon16/cross.png')

    menu2:AddSpacer()

    local icons = list.Get('ContentCategoryIcons')
    local npc_weapons = list.Get('NPCUsableWeapons')

    for _, wep in pairs(npc_weapons) do
        local name = language.GetPhrase(wep.title or wep.class)
        local option_icon = icons[wep.category or ''] or 'icon16/gun.png'

        menu2:AddOption(name, function()
            set_npc(mdl, options[1]:GetChecked(), wep.class)
        end):SetIcon(option_icon)
    end
end)
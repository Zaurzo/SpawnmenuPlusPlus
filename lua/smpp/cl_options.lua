SpawnmenuPP.Option = SpawnmenuPP.Option or {}

---@class SMPP.Option
---@field Name string
---@field ConVars table<string, string|number>
local Option = {}
Option.__index = Option

---@param panel ControlPanel
function Option:BuildCPanel(panel)
end

---@param name string
---@param old string
---@param new string
function Option:OnConVarChanged(name, old, new)
end

---@return table
function Option:BuildConVarList()
    local list = {}
    
    if self.ConVars then
        for name, default in pairs(self.ConVars) do
            list['smpp_' .. self:GetID() .. '_' .. name] = default
        end
    end

    return list
end

---@return string
function Option:GetID()
    return self._id
end

---@param convar string
---@return string
function Option:GetString(convar)
    return self._cvars[convar]:GetString()
end

---@param convar string
---@return int
function Option:GetInt(convar)
    return self._cvars[convar]:GetInt()
end

---@param convar string
---@return number
function Option:GetFloat(convar)
    return self._cvars[convar]:GetFloat()
end

---@param convar string
---@return bool
function Option:GetBool(convar)
    return self._cvars[convar]:GetBool()
end

---@param id string
---@return SMPP.Option
function SpawnmenuPP.Option:New(id)
    return setmetatable({ _id = id }, Option)
end

---@param option SMPP.Option
function SpawnmenuPP.Option:Register(option)
    local id = option:GetID()
    local prefix = 'smpp_' .. id .. '_'

    local function cvar_callback(name, old, new)
        name = name:sub(#prefix + 1)

        option:OnConVarChanged(name, old, new)
    end

    if option.ConVars then
        for name, default in pairs(option.ConVars) do
            local cvar_name = prefix .. name
            local convar = CreateClientConVar(cvar_name, default, true)

            option._cvars = option._cvars or {}
            option._cvars[name] = convar

            cvars.AddChangeCallback(cvar_name, cvar_callback)
        end
    end

    self._options = self._options or {}
    self._options[id] = option
end

---@return SMPP.Option[]
function SpawnmenuPP.Option:GetAll()
    local options = {}

    if self._options then
        for _, option in pairs(self._options) do
            table.insert(options, option)
        end
    end

    return options
end

---@param id string
---@param name string
---@return ConVar?
function SpawnmenuPP.Option:GetConVar(id, name)
    local option = self._options and self._options[id]
    if not option then return end
    
    return option._cvars and option._cvars[name]
end

-- Load options

SpawnmenuPP:LoadDir('options')

hook.Add('AddToolMenuTabs', 'myHookClass', function()
    spawnmenu.AddToolTab('Options', 'Options', 'icon16/cog.png')
    spawnmenu.AddToolCategory('Options', 'Spawnmenu++', 'Spawnmenu++')

    for _, option in pairs(SpawnmenuPP.Option:GetAll()) do
        spawnmenu.AddToolMenuOption(
            'Options', 
            'Spawnmenu++', 
            option:GetID(), 
            option.Name, 
            '',
            nil,
            function(panel) option:BuildCPanel(panel) end
        )
    end
end)
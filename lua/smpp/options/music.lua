---@realm client

---@class SMPP.Options.Music : SMPP.Option
local Music = SpawnmenuPP.Option:New('music')

Music.Name = 'Music'
Music.Path = 'sound/smpp/music/'

Music.ConVars = {
    enabled = 0,
    volume = 1,
    rate = 1,
    wait = 0,
    fade = 0,
    song = ''
}

local is_spawnmenu_open = false
local audio_channel ---@type IGModAudioChannel

local function get_songs()
    local songs = {}

    local files = file.Find(Music.Path .. '*', 'GAME')
    local valid_extensions = {
        wav = true,
        mp3 = true,
        ogg = true,
        flac = true
    }

    for _, file_name in ipairs(files) do
        local extension = file_name:GetExtensionFromFilename()

        if extension and valid_extensions[extension] then
            table.insert(songs, file_name)
        end
    end

    return songs
end

function Music:Play()
    if not is_spawnmenu_open or not self:GetBool('enabled') then return end

    local wait = (self:GetFloat('wait') or 0) + 0.25

    timer.Create('smpp_start_song', wait, 1, function()
        local path = self.Path .. self:GetString('song')

        sound.PlayFile(path, 'noblock', function(channel)
            local vol = 0

            if self:GetBool('fade') then
                local start = SysTime()

                hook.Add('Think', 'smpp_music_fade', function()
                    if vol >= 1 then
                        hook.Remove('Think', 'smpp_music_fade')
                        
                        return
                    end

                    vol = Lerp(SysTime() - start, 0, 1)

                    channel:SetVolume(vol * self:GetFloat('volume'))
                end)
            else
                channel:SetVolume(self:GetFloat('volume'))
            end

            channel:EnableLooping(true)
            channel:SetPlaybackRate(self:GetFloat('rate'))

            audio_channel = channel
        end)
    end)
end

function Music:Stop()
    timer.Stop('smpp_start_song')
    hook.Remove('Think', 'smpp_music_fade')

    if audio_channel then
        audio_channel:Stop()
        audio_channel = nil
    end
end

function Music:OnConVarChanged(name, old, new)
    if name == 'enabled' then
        if new == '1' then
            self:Play()
        else
            self:Stop()
        end
    elseif name == 'volume' or name == 'rate' then
        if not audio_channel then return end

        local value = tonumber(new)

        if value then
            if name == 'volume' then
                audio_channel:SetVolume(value)
            else
                audio_channel:SetPlaybackRate(value)
            end
        end
    elseif name == 'song' then
        self:Stop()
        self:Play()
    end
end

local cvar_list = Music:BuildConVarList()

function Music:BuildCPanel(panel)
    panel:ToolPresets('smpp_music', cvar_list)

    local combo_box = panel:ComboBox('Song', 'smpp_music_song')
    local current_song = self:GetString('song')

    for _, song in ipairs(get_songs()) do
        combo_box:AddChoice(song, nil, song == current_song, 'icon16/music.png')
    end

    panel:TextEntry('Wait Time (seconds)', 'smpp_music_wait')
    panel:NumSlider('Volume', 'smpp_music_volume', 0, 1)
    panel:NumSlider('Playback Rate', 'smpp_music_rate', 0.01, 2)
    panel:CheckBox('Enabled', 'smpp_music_enabled')
    panel:CheckBox('Fade In', 'smpp_music_fade')
end

hook.Add('SpawnMenuOpened', 'smpp_music', function()
    is_spawnmenu_open = true

    Music:Play()
end)

hook.Add('SpawnMenuClosed', 'smpp_music', function()
    is_spawnmenu_open = false

    Music:Stop()
end)

SpawnmenuPP.Option:Register(Music)
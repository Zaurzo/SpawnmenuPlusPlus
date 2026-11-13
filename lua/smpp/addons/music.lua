---@realm client

local enabled = CreateClientConVar('smpp_song_enabled', '0', true, false, '', 0, 1)
local song_path = CreateClientConVar('smpp_song', '', true, false)
local volume = CreateClientConVar('smpp_song_volume', '1', true, false)
local speed = CreateClientConVar('smpp_song_speed', '1', true, false)
local wait_time = CreateClientConVar('smpp_song_wait', '0', true, false)
local fade = CreateClientConVar('smpp_song_fade', '0', true, false, '', 0, 1)

local function get_songs()
    local songs = {}

    local files = file.Find('data_static/smpp/music/*', 'GAME')
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

---@param cpanel ControlPanel
local function build(cpanel)
    local combo_box = cpanel:ComboBox('Song', 'smpp_song')
    local current_song = song_path:GetString()

    for _, song in ipairs(get_songs()) do
        combo_box:AddChoice(song, nil, song == current_song, 'icon16/music.png')
    end

    cpanel:TextEntry('Wait Time (seconds)', 'smpp_song_wait')
    cpanel:NumSlider('Volume', 'smpp_song_volume', 0, 1)
    cpanel:NumSlider('Playback Rate', 'smpp_song_speed', 0.01, 2)
    cpanel:CheckBox('Enabled', 'smpp_song_enabled')
    cpanel:CheckBox('Fade In', 'smpp_song_fade')
end

local audio_channel ---@type IGModAudioChannel
local spawnmenu_open = false

local function stop()
    timer.Stop('smpp_start_song')
    hook.Remove('Think', 'smpp_song_fade')

    if audio_channel then
        audio_channel:Stop()
        audio_channel = nil
    end
end

local function play()
    if not spawnmenu_open or not enabled:GetBool() then return end

    local wait = (wait_time:GetFloat() or 0) + 0.1

    timer.Create('smpp_start_song', wait, 1, function()
        local path = 'data_static/smpp/music/' .. song_path:GetString()

        sound.PlayFile(path, 'noblock', function(channel)
            local vol = 0

            if fade:GetBool() then
                local start = SysTime()

                hook.Add('Think', 'smpp_song_fade', function()
                    if vol >= 1 then
                        hook.Remove('Think', 'smpp_song_fade')
                        
                        return
                    end

                    vol = Lerp(SysTime() - start, 0, 1)

                    channel:SetVolume(vol * volume:GetFloat())
                end)
            else
                channel:SetVolume(volume:GetFloat())
            end

            channel:EnableLooping(true)
            channel:SetPlaybackRate(speed:GetFloat())

            audio_channel = channel
        end)
    end)
end

hook.Add('SpawnMenuOpened', 'smpp_song', function()
    spawnmenu_open = true

    play()
end)

hook.Add('SpawnMenuClosed', 'smpp_song', function()
    spawnmenu_open = false

    stop()
end)

cvars.AddChangeCallback('smpp_song_enabled', function(_, old, new)
    if new == '1' then
        play()
    else
        stop()
    end
end)

cvars.AddChangeCallback('smpp_song_volume', function(_, _, new)
    if not audio_channel then return end

    local vol = tonumber(new)

    if vol then
        audio_channel:SetVolume(vol)
    end
end)

cvars.AddChangeCallback('smpp_song_speed', function(_, _, new)
    if not audio_channel then return end

    local rate = tonumber(new)

    if rate then
        audio_channel:SetPlaybackRate(rate)
    end
end)

cvars.AddChangeCallback('smpp_song', function(_, _, new)
    stop()
    play()
end)

SpawnmenuPP:RegisterOption('music', 'Music', build)
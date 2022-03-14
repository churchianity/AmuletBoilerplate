
SOUNDS = {
    -- sfxr_synth seeds
    --RANDOM1         = 85363309,

    -- audio buffers
    --MAIN_THEME = am.track(am.load_audio("res/maintheme.ogg"), true, 1, SETTINGS.music_volume)
}

-- doesn't get unset when a track is 'done' playing automatically
CURRENT_TRACK = nil

function update_sfx_volume() end
function update_music_volume(volume)
    if CURRENT_TRACK then
        CURRENT_TRACK.volume = math.clamp(volume, 0, 1)
    end
end

-- play sound effect with variable pitch
function vplay_sfx(sound, pitch_range)
    local pitch = (math.random() + 0.5)/(pitch_range and 1/pitch_range or 2)
    win.scene:action(am.play(sound, false, pitch, SETTINGS.sfx_volume))
end

function play_sfx(sound)
    win.scene:action(am.play(sound, false, 1, SETTINGS.sfx_volume))
end

function play_track(track, loop)
    CURRENT_TRACK = track
    win.scene:action(am.play(track, loop or true))
end


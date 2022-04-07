
local sound_file_prefix = "res/ogg/"
local fartverb = am.load_audio("res/fartverb.ogg")
local fail_count = 0

local function load_sound(sound)
    local t = type(sound)
    if t == "number" then
        -- should be an sfxr seed
        return sound

    elseif t == "string" then
        -- path to a .ogg file. we'll load an audio buffer
        return am.load_audio(sound_file_prefix .. sound)
    else

        fail_count = fail_count + 1
        -- placeholder sound
        return fartverb
    end
end

-- table of all the audio buffers in the game.
-- we also store sfxr synth seeds, which are lua numbers, and get converted to audio buffers before they are played
SOUNDS = {
    -- sfxr_synth seeds
    --RANDOM1           = load_sound(85363309),

    -- .ogg files
    --MAIN_THEME        = load_sound("res/maintheme.ogg")
}

if fail_count > 0 then
    log("failed to load %d sound buffers or sfxr seed\n", fail_count)
end

-- note that updating sfx volume does not apply to sfx that have started playing before the update.
function update_sfx_volume(volume)
    SETTINGS.sfx_volume = math.clamp(volume, 0, 1)
end

-- all the currently running tracks.
local tracks = {}

-- note that updating track volume (usually used for things like theme songs, instead of sound effects)
-- will take place immediately, and tracks that are playing will have their volume adjusted.
-- volume should be between 0 and 1, but is clamped to be safe.
function update_track_volume(volume)
    for _,t in pairs(tracks) do
        if t then
            t.volume = math.clamp(volume, 0, SETTINGS.track_volume)
        end
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

-- constructs a track from an audio buffer.
-- tracks can be reset mid-play, they can loop, and their volume can be updated as they play.
function play_sound_as_track(sound, loop)
    local track = am.track(sound, loop or true, 1, SETTINGS.track_volume)
    table.insert(tracks, track)

    -- run two actions in order.
    win.scene:action(
        am.series(
            am.play(track, loop or true, 1, SETTINGS.track_volume),
            function()
                -- @TODO set the track to nil in the tracks table
                log('hey!')
            end
        )
    )
end


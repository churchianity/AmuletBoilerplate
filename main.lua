
-- a bunch of common 4:3 aspect ratios
local RESOLUTION_OPTIONS = {
    { width = 1440, height = 1080 },
    { width = 1400, height = 1050 },
    { width = 1280, height = 960 },
    { width = 1152, height = 864 },
    { width = 1024, height = 768 },
    { width = 960, height = 720 },
    { width = 832, height = 624 },
    { width = 800, height = 600 },
}
local DEFAULT_RESOLUTION = RESOLUTION_OPTIONS[6]

SETTINGS = am.load_state("settings", "json") or {
    fullscreen = false,
    window_width = DEFAULT_RESOLUTION.width,
    window_height = DEFAULT_RESOLUTION.height,
    music_volume = 0.2,
    sfx_volume = 0.1,
    sound_on = true
}

require "conf"
win = am.window{
    width     = SETTINGS.window_width,
    height    = SETTINGS.window_height,
    title     = title,
    mode      = SETTINGS.fullscreen and "fullscreen" or "windowed",
    resizable = false,
    highdpi   = true,
    letterbox = true,
    show_cursor = true,
    clear_color = vec4(0),
}

-- asset interfaces, defined constants, and/or trivial code
require "color"
require "sound"
require "texture"

-- library/standard code (ours)
require "lib/random"
require "lib/extra"
require "lib/memory"
require "lib/geometry"
require "lib/gui"

-- other internal dependencies
--require "src/game"

function switch_context(scene, action)
    if action then
        win.scene:replace("context", scene:action(action):tag"context")
    else
        win.scene:replace("context", scene:tag"context")
    end
end

function init()
end

win.scene = am.group(am.group():tag"context")
init()
noglobals()



local texture_file_prefix = "res/img/"

local fail_count = 0
local function load_texture(filepath)
    local status, texture = pcall(am.texture2d, texture_file_prefix .. filepath)

    if status then
        return texture
    else
        fail_count = fail_count + 1
        return am.texture2d("res/bagel.jpg")
    end
end

-- table of all the textures used by the game
TEXTURES = {
    -- note that in amulet, if you prefix paths with './', they fail to be found in the exported data.pak
    WHITE = load_texture("white-texture.png"),
}

if fail_count > 0 then
    log("failed to load %d texture(s)", fail_count)
end

-- given some texture, and optionally width, height, color, and/or coordinates return an am.sprite
-- with those fields filled out. useful because we load all our textures ahead of time and turn them into
-- sprites later.
function pack_texture_into_sprite(
    texture,
    width,
    height,
    color,
    s1,
    s2,
    t1,
    t2
)
    local width = width or texture.width
    local height = height or texture.height

    local sprite = am.sprite{
        texture = texture,
        s1 = s1 or 0, s2 = s2 or 1, t1 = t1 or 0, t2 = t2 or 1,
        x1 = 0, x2 = width, width = width,
        y1 = 0, y2 = height, height = height
    }

    if color then sprite.color = color end

    return sprite
end

-- useful for animating sprite sheets. still feels kind of annoying and like there must be a better way.
function update_sprite_texture_region(sprite, texture, width, height, s1, t1, s2, t2)
    local s1, t1, s2, t2 = s1 or 0, t1 or 0, s2 or 1, t2 or 1
    local width, height = width or texture.width, height or texture.height

    sprite.source = {
        texture = texture,
        s1 = s1, t1 = t1, s2 = s2, t2 = t2,
        x1 = 0, x2 = width, width = width,
        y1 = 0, y2 = height, height = height
    }
end


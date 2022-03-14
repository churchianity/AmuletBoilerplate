
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

TEXTURES = {
    -- note that in amulet, if you prefix paths with './', they fail to be found in the exported data.pak
    WHITE = load_texture("white-texture.png"),
}

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

if fail_count > 0 then
    log("failed to load %d texture(s)", fail_count)
end


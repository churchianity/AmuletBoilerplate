
local function box_size(box)
    local margin, border, padding, content = box.margin, box.border, box.padding, box.content
    local x = margin.left + border.left + padding.left + content.width + padding.right + border.right + margin.right
    local y = margin.bottom + border.bottom + padding.bottom + content.height + padding.top + border.top + margin.top

    return vec2(x, y)
end
local function correct_for_missing_edge_values(top, left, bottom, right)
    if not top then
        return { top = nil, left = nil, bottom = nil, right = nil } -- same as {}

    elseif not left then
        return { top = top, left = top, bottom = top, right = top }

    elseif not bottom then
        return { top = left, left = top, bottom = left, right = top }

    elseif not right then
        return { top = top, left = left, bottom = bottom, right = left }

    else
        return { top = top, left = left, bottom = bottom, right = right }
    end
end
local function margin(top, left, bottom, right)
    return correct_for_missing_edge_values(top, left, bottom, right)
end
local function border(top, left, bottom, right)
    return correct_for_missing_edge_values(top, left, bottom, right)
end
local function rect_dimensions(rect)
    return vec2(math.abs(rect.x2 - rect.x1), math.abs(rect.y2 - rect.y1))
end
local function infer_node_type(node)
    if node.center then
        return "circle"

    elseif node.x1 then
        return "rect"

    elseif node.width then
        return "text"

    else
        log('unknown node type')
        log(table.tostring(node))
    end
end
local function dimensions(node)
    local _type = infer_node_type(node)

    if _type == "text" then
        return vec2(node.width, node.height)

    elseif _type == "circle" then
        local diameter = node.radius * 2
        return vec2(diameter)

    elseif _type == "rect" then
        return rect_dimensions(node)

    else
        log("unknown content type, can't get dimensions!")
    end
end
local function find_centerpoint(node)
    local _type = infer_node_type(node)
end
local function column(group)
    local _group = am.group()
    local position = vec2(0)

    for i,node in group:child_pairs() do
        _group:append(am.translate(position) ^ node)
        position = position - dimensions(node){x=0}
    end

    return _group
end
local function row(group)
    local _group = am.group()
    local position = vec2(0)

    for i,node in group:child_pairs() do
        _group:append(am.translate(position) ^ node)
        position = position + dimensions(node){y=0}
    end

    return _group
end
local function normalize_positions(group)
    for i,node in group:child_pairs() do
        local t = infer_node_type(node)

        if t == "circle" then
            node.center = vec2(node.radius, -node.radius)

        elseif t == "rect" then
            local dimensions = rect_dimensions(node)
            node.x1 = 0
            node.y1 = -dimensions.y
            node.x2 = dimensions.x
            node.y2 = 0

        elseif t == "text" then
            log('TODO')

        else
            log('can\'t normalize this node')
        end
    end
    return group
end
local function layout(group, direction)
    local group = normalize_positions(group)

    if not direction or direction == "column" then
        return column(group)

    elseif direction == "row" then
        return row(group)

    else
        log(string.format('unknown layout type %s', direction))
    end
end

-- args {
--  position vec2
--  label string
--  onclick function
--  padding number
--
--  font {
--    size number
--    color vec4
--    horizontal_align "center" | "left" | "right"
--    vertical_align "center" | "top" | "bottom"
--  }
-- }
function gui_button(args)
    local args = args or {}
    local position = args.position or vec2(0)
    local label = args.label or ""
    local onclick = args.onclick
    local padding = args.padding or 6

    local scene = am.group()

    local text = am.text(args.label or "")
    scene:append(am.translate(args.position) ^ text)


    local content_width = text.width
    local content_height = text.height
    local half_width = text.width/2
    local half_height = text.height/2

    local x1 = position[1] - half_width - padding
    local y1 = position[2] - half_height - padding
    local x2 = position[1] + half_width + padding
    local y2 = position[2] + half_height + padding

    local back_rect = am.rect(x1 - padding/2, y1, x2, y2 + padding/2, vec4(0, 0, 0, 1))
    local front_rect = am.rect(x1, y1, x2, y2, vec4(0.4))
    scene:prepend(front_rect)
    scene:prepend(back_rect)

    scene:action(function(self)
        if point_in_rect(win:mouse_position(), back_rect) then
            if win:mouse_pressed"left" then
                front_rect.color = vec4(0.4)

                if onclick then
                    onclick()
                end
            else
                front_rect.color = vec4(0, 0, 0, 1)
            end
        else
            front_rect.color = vec4(0.4)
        end
    end)

    return scene
end

function gui_textfield(
    position,
    dimensions,
    max,
    disallowed_chars
)
    local width, height = dimensions.x, dimensions.y
    local disallowed_chars = disallowed_chars or {}
    local max = max or 10
    local padding = padding or 6
    local half_width = width/2
    local half_height = height/2

    local x1 = position[1] - half_width - padding
    local y1 = position[2] - half_height - padding
    local x2 = position[1] + half_width + padding
    local y2 = position[2] + half_height + padding

    local back_rect = am.rect(x1 - padding/2, y1, x2, y2 + padding/2, vec4(0, 0, 0, 1))
    local front_rect = am.rect(x1, y1, x2, y2, vec4(0.4))

    local group = am.group{
        back_rect,
        front_rect,
        am.translate(-width/2 + padding, 0) ^ am.scale(2) ^ am.text("", vec4(0, 0, 0, 1), "left"),
        am.translate(-width/2 + padding, -8) ^ am.line(vec2(0, 0), vec2(16, 0), 2, vec4(0, 0, 0, 1))
    }

    group:action(function(self)
        local keys = win:keys_pressed()
        if #keys == 0 then return end

        local chars = {}
        local shift = win:key_down("lshift") or win:key_down("rshift")
        for i,k in pairs(keys) do
            if k:len() == 1 then -- @HACK alphabetical or digit characters
                if string.match(k, "%a") then
                    if shift then
                        table.insert(chars, k:upper())
                    else
                        table.insert(chars, k)
                    end
                elseif string.match(k, "%d") then
                    if shift then
                        if k == "1" then table.insert(chars, "!")
                        elseif k == "2" then table.insert(chars, "@")
                        elseif k == "3" then table.insert(chars, "#")
                        elseif k == "4" then table.insert(chars, "$")
                        elseif k == "5" then table.insert(chars, "%")
                        elseif k == "6" then table.insert(chars, "^")
                        elseif k == "7" then table.insert(chars, "&")
                        elseif k == "8" then table.insert(chars, "*")
                        elseif k == "9" then table.insert(chars, "(")
                        elseif k == "0" then table.insert(chars, ")")
                        end
                    else
                        table.insert(chars, k)
                    end
                end
            -- begin non-alphabetical/digit
            elseif k == "minus" then
                if shift then table.insert(chars, "_")
                else          table.insert(chars, "-") end
            elseif k == "equals" then
                if shift then table.insert(chars, "=")
                else          table.insert(chars, "+") end
            elseif k == "leftbracket" then
                if shift then table.insert(chars, "{")
                else          table.insert(chars, "[") end
            elseif k == "rightbracket" then
                if shift then table.insert(chars, "}")
                else          table.insert(chars, "]") end
            elseif k == "backslash" then
                if shift then table.insert(chars, "|")
                else          table.insert(chars, "\\") end
            elseif k == "semicolon" then
                if shift then table.insert(chars, ":")
                else          table.insert(chars, ";") end
            elseif k == "quote" then
                if shift then table.insert(chars, "\"")
                else          table.insert(chars, "'") end
            elseif k == "backquote" then
                if shift then table.insert(chars, "~")
                else          table.insert(chars, "`") end
            elseif k == "comma" then
                if shift then table.insert(chars, "<")
                else          table.insert(chars, ",") end
            elseif k == "period" then
                if shift then table.insert(chars, ">")
                else          table.insert(chars, ".") end
            elseif k == "slash" then
                if shift then table.insert(chars, "?")
                else          table.insert(chars, "/") end

            -- control characters
            elseif k == "backspace" then
                -- @NOTE this doesn't preserve the order of chars in the array so if
                -- someone presses a the key "a" then the backspace key in the same frame, in that order
                -- the backspace occurs first
                self"text".text = self"text".text:sub(1, self"text".text:len() - 1)

            elseif k == "tab" then
                -- @TODO

            elseif k == "space" then
                table.insert(chars, " ")

            elseif k == "capslock" then
                -- @TODO
            end
        end

        for _,c in pairs(chars) do
            if not disallowed_chars[c] then
                if self"text".text:len() <= max then
                    self"text".text = self"text".text .. c
                end
            end
        end
    end)

    return group
end

function gui_open_modal()

end

